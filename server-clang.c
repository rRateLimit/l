#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <dispatch/dispatch.h>

#define PORT 8080
#define BUFFER_SIZE 1024

// Using Clang-specific features and Grand Central Dispatch (macOS)
static int server_fd;
static dispatch_queue_t server_queue;

void handle_sigint(int sig) {
    printf("\nShutting down server...\n");
    close(server_fd);
    exit(0);
}

void handle_client(int client_fd) {
    char buffer[BUFFER_SIZE] = {0};
    
    // Read request
    ssize_t bytes_read = read(client_fd, buffer, BUFFER_SIZE - 1);
    if (bytes_read > 0) {
        printf("Request received:\n%s\n", buffer);
        
        // Prepare HTTP response
        const char *response = 
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/plain\r\n"
            "Content-Length: 13\r\n"
            "Connection: close\r\n"
            "Server: Clang HTTP Server\r\n"
            "\r\n"
            "Hello, World!";
        
        // Send response
        send(client_fd, response, strlen(response), 0);
    }
    
    // Close connection
    close(client_fd);
}

int main(void) {
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
    
    signal(SIGINT, handle_sigint);
    
    // Create dispatch queue for concurrent handling
    server_queue = dispatch_queue_create("com.httpserver.queue", DISPATCH_QUEUE_CONCURRENT);
    
    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }
    
    // Allow socket reuse
    int opt = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }
    
    // Configure server address
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);
    
    // Bind socket
    if (bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }
    
    // Listen for connections
    if (listen(server_fd, 10) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }
    
    printf("HTTP Server (Clang/GCD) listening on port %d\n", PORT);
    
    // Use Clang blocks for cleaner syntax
    void (^accept_connections)(void) = ^{
        while (1) {
            int client_fd = accept(server_fd, (struct sockaddr *)&client_addr, &client_len);
            if (client_fd < 0) {
                perror("accept");
                continue;
            }
            
            // Handle client in concurrent queue using blocks
            dispatch_async(server_queue, ^{
                handle_client(client_fd);
            });
        }
    };
    
    // Run the accept loop
    accept_connections();
    
    return 0;
}
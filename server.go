package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
    log.Printf("Request received: %s %s\n", r.Method, r.URL.Path)
    w.Header().Set("Content-Type", "text/plain")
    fmt.Fprintf(w, "Hello, World!")
}

func main() {
    port := ":8080"
    
    // Setup HTTP server
    http.HandleFunc("/", helloHandler)
    
    // Setup graceful shutdown
    sigChan := make(chan os.Signal, 1)
    signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
    
    go func() {
        <-sigChan
        fmt.Println("\nShutting down server...")
        os.Exit(0)
    }()
    
    fmt.Printf("HTTP Server listening on port %s\n", port)
    
    // Start server
    if err := http.ListenAndServe(port, nil); err != nil {
        log.Fatal(err)
    }
}
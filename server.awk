#!/usr/bin/awk -f
# Simple HTTP server using GNU AWK's networking features
# Usage: gawk -f server.awk

BEGIN {
    port = 8080
    host = "/inet/tcp/" port "/0/0"
    
    print "HTTP Server listening on port", port
    print "Note: This requires GNU AWK (gawk) with networking support"
    print "Press Ctrl-C to stop the server"
    
    # HTTP response
    response = "HTTP/1.1 200 OK\r\n" \
               "Content-Type: text/plain\r\n" \
               "Content-Length: 13\r\n" \
               "Connection: close\r\n" \
               "\r\n" \
               "Hello, World!"
    
    while (1) {
        # Accept connection and read request
        if ((getline request < host) > 0) {
            print "Request received:", request
            
            # Read remaining headers
            while ((getline line < host) > 0 && line != "\r")
                ;
            
            # Send response
            print response |& host
            close(host)
        }
    }
}
#!/usr/bin/env ruby

require 'socket'

PORT = 8080

server = TCPServer.new(PORT)
puts "HTTP Server listening on port #{PORT}"

# Handle SIGINT (Ctrl-C)
trap("INT") do
  puts "\nShutting down server..."
  server.close
  exit
end

loop do
  client = server.accept
  request = client.gets
  
  puts "Request received:"
  puts request
  
  # Read rest of headers
  while (line = client.gets) != "\r\n"
    # Skip headers
  end
  
  # HTTP response
  response = "HTTP/1.1 200 OK\r\n" +
             "Content-Type: text/plain\r\n" +
             "Content-Length: 13\r\n" +
             "Connection: close\r\n" +
             "\r\n" +
             "Hello, World!"
  
  client.print response
  client.close
end
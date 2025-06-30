#!/usr/bin/env perl

use strict;
use warnings;
use IO::Socket::INET;

my $port = 8080;

# Create server socket
my $server = IO::Socket::INET->new(
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 5,
    Reuse     => 1
) or die "Cannot create socket: $!\n";

print "HTTP Server listening on port $port\n";

# Handle SIGINT (Ctrl-C)
$SIG{INT} = sub {
    print "\nShutting down server...\n";
    close($server);
    exit(0);
};

while (1) {
    # Accept client connection
    my $client = $server->accept();
    
    # Read request
    my $request = <$client>;
    print "Request received:\n$request\n";
    
    # Read rest of headers
    while (my $line = <$client>) {
        last if $line =~ /^\r\n$/;
    }
    
    # HTTP response
    my $response = "HTTP/1.1 200 OK\r\n" .
                   "Content-Type: text/plain\r\n" .
                   "Content-Length: 13\r\n" .
                   "Connection: close\r\n" .
                   "\r\n" .
                   "Hello, World!";
    
    # Send response
    print $client $response;
    
    # Close connection
    close($client);
}
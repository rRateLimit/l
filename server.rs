use std::io::prelude::*;
use std::net::{TcpListener, TcpStream};
use std::thread;

const PORT: &str = "127.0.0.1:8080";

fn handle_client(mut stream: TcpStream) {
    let mut buffer = [0; 1024];
    
    match stream.read(&mut buffer) {
        Ok(_) => {
            println!("Request received:");
            println!("{}", String::from_utf8_lossy(&buffer[..]));
            
            let response = "HTTP/1.1 200 OK\r\n\
                           Content-Type: text/plain\r\n\
                           Content-Length: 13\r\n\
                           Connection: close\r\n\
                           \r\n\
                           Hello, World!";
            
            stream.write_all(response.as_bytes()).unwrap();
            stream.flush().unwrap();
        }
        Err(e) => {
            eprintln!("Failed to read from connection: {}", e);
        }
    }
}

fn main() {
    let listener = TcpListener::bind(PORT).unwrap();
    println!("HTTP Server listening on {}", PORT);
    
    // Handle Ctrl-C gracefully
    ctrlc::set_handler(move || {
        println!("\nShutting down server...");
        std::process::exit(0);
    }).expect("Error setting Ctrl-C handler");
    
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                thread::spawn(move || {
                    handle_client(stream);
                });
            }
            Err(e) => {
                eprintln!("Connection failed: {}", e);
            }
        }
    }
}
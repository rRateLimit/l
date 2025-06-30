" HTTP Server in Vim Script
" Usage: vim -S server.vim

function! StartHTTPServer()
    let port = 8080
    echo "Starting HTTP Server on port " . port
    echo "Note: This requires Vim compiled with +job and +channel features"
    echo "Press Ctrl-C to stop the server"
    
    " Start listening on the port
    let s:server = ch_open('localhost:' . port, {
        \ 'mode': 'raw',
        \ 'callback': function('HandleRequest'),
        \ 'waittime': 0
        \ })
    
    if ch_status(s:server) != 'open'
        " Alternative: Use job_start with netcat
        let s:job = job_start(['nc', '-l', port], {
            \ 'callback': function('HandleNetcatRequest'),
            \ 'out_cb': function('HandleNetcatRequest'),
            \ 'err_cb': function('HandleError')
            \ })
    endif
endfunction

function! HandleRequest(channel, msg)
    echo "Request received: " . a:msg
    
    " HTTP response
    let response = "HTTP/1.1 200 OK\r\n" .
        \ "Content-Type: text/plain\r\n" .
        \ "Content-Length: 13\r\n" .
        \ "Connection: close\r\n" .
        \ "\r\n" .
        \ "Hello, World!"
    
    call ch_sendraw(a:channel, response)
    call ch_close(a:channel)
endfunction

function! HandleNetcatRequest(channel, msg)
    echo "Request received via netcat: " . a:msg
endfunction

function! HandleError(channel, msg)
    echoerr "Error: " . a:msg
endfunction

" Alternative simple server using Python integration
function! StartPythonHTTPServer()
    if !has('python3')
        echo "Python 3 support not available"
        return
    endif
    
python3 << EOF
import socket
import threading

def handle_client(client_socket, address):
    try:
        request = client_socket.recv(1024).decode()
        print(f"Request from {address}:\n{request}")
        
        response = b"HTTP/1.1 200 OK\r\n"
        response += b"Content-Type: text/plain\r\n"
        response += b"Content-Length: 13\r\n"
        response += b"Connection: close\r\n"
        response += b"\r\n"
        response += b"Hello, World!"
        
        client_socket.send(response)
    finally:
        client_socket.close()

def run_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('localhost', 8080))
    server.listen(5)
    
    print("HTTP Server listening on port 8080")
    vim.command('echo "HTTP Server started on port 8080 (Python)"')
    
    while True:
        client_socket, address = server.accept()
        client_thread = threading.Thread(target=handle_client, args=(client_socket, address))
        client_thread.start()

# Start server in a separate thread
server_thread = threading.Thread(target=run_server)
server_thread.daemon = True
server_thread.start()
EOF
endfunction

" Try to start the server
if has('channel') && has('job')
    call StartHTTPServer()
elseif has('python3')
    call StartPythonHTTPServer()
else
    echo "Neither channel/job nor Python support available"
    echo "Please use a Vim version with +channel +job or +python3"
endif

" Keep Vim running
while 1
    sleep 1
endwhile
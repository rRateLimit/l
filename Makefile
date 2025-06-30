CC = gcc
CXX = g++
CLANG = clang
RUSTC = rustc
CFLAGS = -Wall -O2
CXXFLAGS = -Wall -O2 -std=c++11
CLANGFLAGS = -Wall -O2 -framework Foundation

.PHONY: all clean c cpp ruby rust go perl python awk servers

all: l-c l-cpp l-rust l perl python awk

servers: server-c server-cpp server-rust server-go server-clang

l-c: l.c
	$(CC) $(CFLAGS) -o $@ $<

l-cpp: l.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

l-rust: l.rs
	$(RUSTC) -O -o $@ $<

l: main.go
	go build -o $@ $<

c: l-c

cpp: l-cpp

ruby: l.rb
	chmod +x l.rb

rust: l-rust

go: l

perl: l.pl
	chmod +x l.pl

python: l.py
	chmod +x l.py

awk: l.awk
	chmod +x l.awk

server-c: server.c
	$(CC) $(CFLAGS) -o $@ $<

server-cpp: server.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

server-rust: server.rs
	cargo build --release --bin server-rust
	cp target/release/server-rust .

server-go: server.go
	go build -o $@ $<

server-clang: server-clang.c
	$(CLANG) $(CLANGFLAGS) -o $@ $<

server-awk: server.awk
	chmod +x server.awk

clean:
	rm -f l-c l-cpp l-rust l server-c server-cpp server-rust server-go server-clang
	rm -rf target
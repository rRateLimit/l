#include <iostream>
#include <vector>
#include <cstdlib>
#include <unistd.h>
#include <cstring>

int main(int argc, char* argv[]) {
    std::vector<char*> args;
    args.push_back(const_cast<char*>("ls"));
    
    for (int i = 1; i < argc; ++i) {
        args.push_back(argv[i]);
    }
    args.push_back(nullptr);
    
    execvp("ls", args.data());
    
    std::cerr << "execvp failed: " << std::strerror(errno) << std::endl;
    return 127;
}
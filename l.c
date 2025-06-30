#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main(int argc, char *argv[]) {
    char **new_argv = malloc((argc + 1) * sizeof(char*));
    if (new_argv == NULL) {
        perror("malloc");
        return 1;
    }
    
    new_argv[0] = "ls";
    for (int i = 1; i < argc; i++) {
        new_argv[i] = argv[i];
    }
    new_argv[argc] = NULL;
    
    execvp("ls", new_argv);
    
    perror("execvp");
    free(new_argv);
    return 127;
}
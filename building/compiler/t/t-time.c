#include <stdio.h>
#include <time.h>
#include <sys/types.h>

int main(int argc, char *argv[])
{
    time_t t = time(NULL);
    printf("time: %u\n", (int) t);
    printf("sizeof(time_t): %d\n", (int) sizeof(time_t));
    printf("sizeof(off_t): %d\n", (int) sizeof(off_t));
    printf("sizeof(size_t): %d\n", (int) sizeof(size_t));
    return 0;
}

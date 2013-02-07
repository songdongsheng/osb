#include <stdio.h>
#include <time.h>

int main(int argc, char *argv[])
{
    time_t t = _time64(NULL);
    printf("time: %u\n", (int) t);
    return 0;
}

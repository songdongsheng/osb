/*
 * g++ -std=c++11 -pthread -O2 test_future.cpp
 */
#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif

#include <future>
#include <iostream>

#ifdef _WIN32
void sleep(int sec)
{
    Sleep(sec * 1000);
}
#endif

int find_the_answer_to_ltuae()
{
    std::cout << "Finding answers ..." << std::endl;
    sleep(2);
    return 42;
}

void do_other_stuff()
{
    std::cout << "Other stuff starts" << std::endl;
    sleep(1);
    std::cout << "Other stuff done" << std::endl;
}

int main()
{
    std::future<int> the_answer = std::async(std::launch::async, find_the_answer_to_ltuae);
    do_other_stuff();
    std::cout << "The answer is " << the_answer.get() << std::endl;
}

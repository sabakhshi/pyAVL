#include <iostream>
#include <omp.h>
#include <unistd.h>
#define THREAD_NUM 4

int main()
{
    omp_set_thread_num(THREAD_NUM); // set number of threads in "parallel" blocks
    #pragma omp parallel
    {
        usleep(5000 * omp_get_thread_num()); // do this to avoid race condition while printing
        std::cout << "Number of available threads: " << omp_get_num_thread() << std::endl;
        // each thread can also get its own number
        std::cout << "Current thread number: " << omp_get_thread_num() << std::endl;
        std::cout << "Hello, World!" << std::endl;
    }
    return 0;
}
// g++ hello_omp_world.cpp -Xpreprocessor -fopenmp -o hello_cpp -lomp
// clang  -fopenmp
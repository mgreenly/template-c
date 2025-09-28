#include "bench_utils.h"
#include <stdio.h>

void bench_start(bench_timer_t* timer) {
    clock_gettime(CLOCK_MONOTONIC, &timer->start);
}

void bench_end(bench_timer_t* timer) {
    clock_gettime(CLOCK_MONOTONIC, &timer->end);
}

double bench_elapsed_ns(bench_timer_t* timer) {
    long seconds = timer->end.tv_sec - timer->start.tv_sec;
    long nanoseconds = timer->end.tv_nsec - timer->start.tv_nsec;
    return (double)seconds * 1000000000.0 + (double)nanoseconds;
}

void bench_print_header(void) {
    printf("%-15s\t%-8s\t%-12s\t%-12s\t%-12s\n",
           "Operation", "Size", "Iterations", "Time/op(ns)", "Ops/sec");
    printf("%-15s\t%-8s\t%-12s\t%-12s\t%-12s\n",
           "===============", "========", "============", "============", "============");
}

void bench_print_result(const char* operation, size_t size,
                       size_t iterations, double elapsed_ns) {
    double time_per_op = elapsed_ns / (double)iterations;
    double ops_per_sec = 1000000000.0 / time_per_op;

    printf("%-15s\t%-8zu\t%-12zu\t%-12.1f\t%-12.0f\n",
           operation, size, iterations, time_per_op, ops_per_sec);
}
#ifndef BENCH_UTILS_H
#define BENCH_UTILS_H

#include <time.h>
#include <stddef.h>

typedef struct {
    struct timespec start;
    struct timespec end;
} bench_timer_t;

void bench_start(bench_timer_t* timer);
void bench_end(bench_timer_t* timer);
double bench_elapsed_ns(bench_timer_t* timer);

void bench_print_header(void);
void bench_print_result(const char* operation, size_t size,
                       size_t iterations, double elapsed_ns);

#endif
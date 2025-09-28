#include <stdio.h>
#include <stdlib.h>
#include "bench_utils.h"
#include "foo.h"

int main(void) {
    bench_timer_t timer;

    int warmup = 1000;
    for (int i = 0; i < warmup; i++) {
        volatile int result = foo_add(i, i + 1);
        (void)result;
    }

    bench_print_header();

    size_t sizes[] = {100, 1000, 10000, 100000, 1000000, 10000000};
    int num_sizes = sizeof(sizes) / sizeof(sizes[0]);

    for (int s = 0; s < num_sizes; s++) {
        size_t iterations = sizes[s];

        bench_start(&timer);

        for (size_t i = 0; i < iterations; i++) {
            volatile int result = foo_add((int)i, (int)(i + 1));
            (void)result;
        }

        bench_end(&timer);

        bench_print_result("foo_add", 1, iterations, bench_elapsed_ns(&timer));
    }

    printf("\nScaling test (fixed total operations = 100M):\n");
    bench_print_header();

    size_t total_ops = 100000000;
    size_t batch_sizes[] = {1, 10, 100, 1000};
    int num_batches = sizeof(batch_sizes) / sizeof(batch_sizes[0]);

    for (int b = 0; b < num_batches; b++) {
        size_t batch_size = batch_sizes[b];
        size_t iterations = total_ops / batch_size;

        bench_start(&timer);

        for (size_t i = 0; i < iterations; i++) {
            for (size_t j = 0; j < batch_size; j++) {
                volatile int result = foo_add((int)j, (int)(j + 1));
                (void)result;
            }
        }

        bench_end(&timer);

        bench_print_result("foo_add_batch", batch_size, total_ops, bench_elapsed_ns(&timer));
    }

    return 0;
}
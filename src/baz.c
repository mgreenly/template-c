#include "baz.h"

#include <limits.h>

int baz_max(const int *array, int size) {
  if (!array || size <= 0)
    return INT_MIN;

  int max = array[0];
  for (int i = 1; i < size; i++) {
    if (array[i] > max) {
      max = array[i];
    }
  }
  return max;
}

double baz_average(const int *array, int size) {
  if (!array || size <= 0)
    return 0.0;

  long sum = 0;
  for (int i = 0; i < size; i++) {
    sum += array[i];
  }
  return (double) sum / (double) size;
}

int baz_factorial(int n) {
  if (n < 0)
    return -1; // Error case
  if (n == 0 || n == 1)
    return 1;

  int result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

#include <glib.h>
#include <limits.h>
#include "../src/baz.h"

static void test_baz_max_normal(void) {
  int arr[] = {3, 7, 2, 9, 1};
  g_assert_cmpint(baz_max(arr, 5), ==, 9);
}

static void test_baz_max_negative(void) {
  int arr[] = {-3, -7, -2, -9, -1};
  g_assert_cmpint(baz_max(arr, 5), ==, -1);
}

static void test_baz_max_single(void) {
  int arr[] = {42};
  g_assert_cmpint(baz_max(arr, 1), ==, 42);
}

static void test_baz_max_null(void) {
  g_assert_cmpint(baz_max(NULL, 5), ==, INT_MIN);
}

static void test_baz_average_normal(void) {
  int arr[] = {2, 4, 6, 8, 10};
  g_assert_cmpfloat_with_epsilon(baz_average(arr, 5), 6.0, 0.01);
}

static void test_baz_average_mixed(void) {
  int arr[] = {-5, 0, 5, 10};
  g_assert_cmpfloat_with_epsilon(baz_average(arr, 4), 2.5, 0.01);
}

static void test_baz_average_single(void) {
  int arr[] = {7};
  g_assert_cmpfloat_with_epsilon(baz_average(arr, 1), 7.0, 0.01);
}

static void test_baz_average_null(void) {
  g_assert_cmpfloat_with_epsilon(baz_average(NULL, 5), 0.0, 0.01);
}

static void test_baz_factorial_normal(void) {
  g_assert_cmpint(baz_factorial(5), ==, 120);
}

static void test_baz_factorial_zero(void) {
  g_assert_cmpint(baz_factorial(0), ==, 1);
}

static void test_baz_factorial_one(void) {
  g_assert_cmpint(baz_factorial(1), ==, 1);
}

static void test_baz_factorial_negative(void) {
  g_assert_cmpint(baz_factorial(-5), ==, -1);
}

int main(int argc, char *argv[]) {
  g_test_init(&argc, &argv, NULL);

  g_test_add_func("/baz/max_normal", test_baz_max_normal);
  g_test_add_func("/baz/max_negative", test_baz_max_negative);
  g_test_add_func("/baz/max_single", test_baz_max_single);
  g_test_add_func("/baz/max_null", test_baz_max_null);
  g_test_add_func("/baz/average_normal", test_baz_average_normal);
  g_test_add_func("/baz/average_mixed", test_baz_average_mixed);
  g_test_add_func("/baz/average_single", test_baz_average_single);
  g_test_add_func("/baz/average_null", test_baz_average_null);
  g_test_add_func("/baz/factorial_normal", test_baz_factorial_normal);
  g_test_add_func("/baz/factorial_zero", test_baz_factorial_zero);
  g_test_add_func("/baz/factorial_one", test_baz_factorial_one);
  g_test_add_func("/baz/factorial_negative", test_baz_factorial_negative);

  return g_test_run();
}

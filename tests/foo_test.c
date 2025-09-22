#include <glib.h>
#include "../src/foo.h"

static void test_foo_add_positive_numbers(void) {
  g_assert_cmpint(foo_add(5, 3), ==, 8);
}

static void test_foo_add_negative_numbers(void) {
  g_assert_cmpint(foo_add(-5, -3), ==, -8);
}

static void test_foo_add_mixed_numbers(void) {
  g_assert_cmpint(foo_add(5, -3), ==, 2);
}

static void test_foo_add_zero(void) {
  g_assert_cmpint(foo_add(5, 0), ==, 5);
  g_assert_cmpint(foo_add(0, 0), ==, 0);
}

int main(int argc, char *argv[]) {
  g_test_init(&argc, &argv, NULL);

  g_test_add_func("/foo/add_positive_numbers", test_foo_add_positive_numbers);
  g_test_add_func("/foo/add_negative_numbers", test_foo_add_negative_numbers);
  g_test_add_func("/foo/add_mixed_numbers", test_foo_add_mixed_numbers);
  g_test_add_func("/foo/add_zero", test_foo_add_zero);

  return g_test_run();
}

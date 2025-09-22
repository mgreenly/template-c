#include <glib.h>
#include <string.h>
#include "../src/bar.h"

static void test_bar_reverse_simple(void) {
  GString *result = bar_reverse("hello");
  g_assert_nonnull(result);
  g_assert_cmpstr(result->str, ==, "olleh");
  g_string_free(result, TRUE);
}

static void test_bar_reverse_empty(void) {
  GString *result = bar_reverse("");
  g_assert_nonnull(result);
  g_assert_cmpstr(result->str, ==, "");
  g_string_free(result, TRUE);
}

static void test_bar_reverse_null(void) {
  GString *result = bar_reverse(NULL);
  g_assert_null(result);
}

static void test_bar_count_vowels_simple(void) {
  g_assert_cmpint(bar_count_vowels("hello world"), ==, 3);
}

static void test_bar_count_vowels_uppercase(void) {
  g_assert_cmpint(bar_count_vowels("AEIOU"), ==, 5);
}

static void test_bar_count_vowels_none(void) {
  g_assert_cmpint(bar_count_vowels("xyz"), ==, 0);
}

static void test_bar_count_vowels_empty(void) {
  g_assert_cmpint(bar_count_vowels(""), ==, 0);
}

static void test_bar_count_vowels_null(void) {
  g_assert_cmpint(bar_count_vowels(NULL), ==, 0);
}

int main(int argc, char *argv[]) {
  g_test_init(&argc, &argv, NULL);

  g_test_add_func("/bar/reverse_simple", test_bar_reverse_simple);
  g_test_add_func("/bar/reverse_empty", test_bar_reverse_empty);
  g_test_add_func("/bar/reverse_null", test_bar_reverse_null);
  g_test_add_func("/bar/count_vowels_simple", test_bar_count_vowels_simple);
  g_test_add_func("/bar/count_vowels_uppercase", test_bar_count_vowels_uppercase);
  g_test_add_func("/bar/count_vowels_none", test_bar_count_vowels_none);
  g_test_add_func("/bar/count_vowels_empty", test_bar_count_vowels_empty);
  g_test_add_func("/bar/count_vowels_null", test_bar_count_vowels_null);

  return g_test_run();
}

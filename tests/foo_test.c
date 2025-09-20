#include "unity.h"
#include "../src/foo.h"

void setUp(void) {
}

void tearDown(void) {
}

void test_foo_add_positive_numbers(void) {
  TEST_ASSERT_EQUAL(8, foo_add(5, 3));
}

void test_foo_add_negative_numbers(void) {
  TEST_ASSERT_EQUAL(-8, foo_add(-5, -3));
}

void test_foo_add_mixed_numbers(void) {
  TEST_ASSERT_EQUAL(2, foo_add(5, -3));
}

void test_foo_add_zero(void) {
  TEST_ASSERT_EQUAL(5, foo_add(5, 0));
  TEST_ASSERT_EQUAL(0, foo_add(0, 0));
}

int main(void) {
  UNITY_BEGIN();

  RUN_TEST(test_foo_add_positive_numbers);
  RUN_TEST(test_foo_add_negative_numbers);
  RUN_TEST(test_foo_add_mixed_numbers);
  RUN_TEST(test_foo_add_zero);

  return UNITY_END();
}

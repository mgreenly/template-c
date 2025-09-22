#include <stdio.h>
#include <glib.h>
#include "config.h"
#include "foo.h"
#include "bar.h"
#include "baz.h"

int main(void) {
  printf("%s\n", PROGRAM_MESSAGE);
  printf("Using libfoo version: %s\n", foo_get_version());

  // Use foo library
  int result = foo_add(5, 3);
  printf("\nFoo library: 5 + 3 = %d\n", result);

  // Use bar library
  printf("\nBar library:\n");
  const char *test_str = "Hello, World!";
  GString *reversed    = bar_reverse(test_str);
  if (reversed) {
    printf("  Reverse of \"%s\" is \"%s\"\n", test_str, reversed->str);
    g_string_free(reversed, TRUE);
  }
  printf("  Vowel count in \"%s\" is %d\n", test_str, bar_count_vowels(test_str));

  // Use baz library
  printf("\nBaz library:\n");
  int numbers[] = {3, 7, 2, 9, 1, 5};
  printf("  Max of [3,7,2,9,1,5] is %d\n", baz_max(numbers, 6));
  printf("  Average is %.2f\n", baz_average(numbers, 6));
  printf("  Factorial of 5 is %d\n", baz_factorial(5));

  return 0;
}

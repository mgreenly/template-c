#include "bar.h"
#include <string.h>
#include <ctype.h>

GString *bar_reverse(const char *str) {
  if (!str)
    return NULL;

  size_t len        = strlen(str);
  GString *reversed = g_string_sized_new(len);

  for (size_t i = len; i > 0; i--) {
    g_string_append_c(reversed, str[i - 1]);
  }

  return reversed;
}

int bar_count_vowels(const char *str) {
  if (!str)
    return 0;

  int count = 0;
  for (const char *p = str; *p; p++) {
    char c = (char) tolower(*p);
    if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') {
      count++;
    }
  }

  return count;
}

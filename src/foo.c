#include "foo.h"
#include <png.h>

int foo_add(int a, int b) {
  return a + b;
}

const char* foo_get_png_version(void) {
  return png_get_libpng_ver(NULL);
}

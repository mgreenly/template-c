#include "foo.h"
#include <png.h>
#include <jpeglib.h>
#include <stdio.h>

int foo_add(int a, int b) {
  return a + b;
}

const char *foo_get_png_version(void) {
  return png_get_libpng_ver(NULL);
}

const char *foo_get_jpeg_version(void) {
  static char version_str[32];
  snprintf(version_str, sizeof(version_str), "%d", JPEG_LIB_VERSION);
  return version_str;
}

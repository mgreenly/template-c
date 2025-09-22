#include "foo.h"
#include "foo_version.h"

int foo_add(int a, int b) {
  return a + b;
}

const char *foo_get_version(void) {
  return FOO_VERSION_STRING;
}

int foo_get_version_major(void) {
  return FOO_VERSION_MAJOR;
}

int foo_get_version_minor(void) {
  return FOO_VERSION_MINOR;
}

int foo_get_version_patch(void) {
  return FOO_VERSION_PATCH;
}

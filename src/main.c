#include <stdio.h>
#include "config.h"
#include "foo.h"

int main(void) {
  printf("%s\n", PROGRAM_MESSAGE);

  int result = foo_add(5, 3);
  printf("5 + 3 = %d\n", result);

  return 0;
}

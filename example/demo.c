#include <stdio.h>
#include <foo.h>
#include <version.h>

int main() {
    printf("libfoo Demo Program\n");
    printf("===================\n");
    printf("Library version: %s\n", FOO_VERSION_STRING);
    printf("Version number: %d\n", FOO_VERSION);
    printf("\n");

    printf("Testing foo_add function:\n");
    printf("foo_add(10, 5) = %d\n", foo_add(10, 5));
    printf("foo_add(-3, 7) = %d\n", foo_add(-3, 7));
    printf("foo_add(0, 0) = %d\n", foo_add(0, 0));
    printf("\n");

    printf("Library dependencies:\n");
    printf("PNG library version: %s\n", foo_get_png_version());
    printf("JPEG library version: %s\n", foo_get_jpeg_version());

    return 0;
}
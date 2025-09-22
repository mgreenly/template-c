#ifndef FOO_H
#define FOO_H

int foo_add(int a, int b);

/* Version information */
const char *foo_get_version(void);
int foo_get_version_major(void);
int foo_get_version_minor(void);
int foo_get_version_patch(void);

#endif

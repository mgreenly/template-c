#ifndef FOO_VERSION_H
#define FOO_VERSION_H

#define FOO_VERSION_MAJOR 0
#define FOO_VERSION_MINOR 1
#define FOO_VERSION_PATCH 0

#define FOO_VERSION_STRING "0.1.0"

#define FOO_MAKE_VERSION(major, minor, patch) \
    ((major) * 10000 + (minor) * 100 + (patch))

#define FOO_VERSION \
    FOO_MAKE_VERSION(FOO_VERSION_MAJOR, FOO_VERSION_MINOR, FOO_VERSION_PATCH)

#endif
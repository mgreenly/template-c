# libfoo

Run `./rename foo yourlib` to set your library's name then delete the `rename` script.

After renaming, update these files for your project:

- `LICENSE` - replace with your license.
- `pkgconfig/foo.pc.in` - Update the Description and URL fields
- `Makefile` - Update VERSION_MAJOR/MINOR/PATCH (lines 3-5) - this generates version.h automatically
- `mk/debian.mk` and `mk/darwin.mk` - Remove PNG/JPEG dependencies, add your own:
  - Remove PNG_NAME, JPEG_NAME sections
  - Add your library dependencies (follow the same pattern)
  - Update LIB_DEPS_LIBS, LIB_DEPS_CFLAGS, LIB_DEPS_PC with your libs
  - Update DEV_PACKAGES with your development packages
- `src/foo.c` - Remove PNG/JPEG includes and example functions
- Replace this README with your own documentation

## Install

```
make check; make install PREFIX=/usr/local
```
## Uninstall
```
make uninstall PREFIX=$HOME/.local
```

## Dynamic Linking

```
gcc -std=c17 -Wall -Wextra -g demo.c $(pkg-config --cflags --libs foo) -o demo
```

## Static Linking

```bash
gcc -std=c17 -Wall -Wextra -g -static demo.c $(pkg-config --cflags --libs --static foo) -o demo
```

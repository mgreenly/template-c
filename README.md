# libfoo

Run `./rename foo foo` to set your libraries name then delete the `rename` script.  Then create your own README.

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

# libfoo

Run `rename.sh foo foo` to set your libraries name then delete the `rename.sh` script.

## Description

It doesn't matter what it does it will get replaced by your code ;-)

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

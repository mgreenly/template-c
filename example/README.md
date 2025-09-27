# libfoo Example

## Install

```bash
sudo make install PREFIX=/usr/local
```

## Use Dynamically

```bash
gcc -std=c17 -Wall -Wextra -g demo.c $(pkg-config --cflags --libs foo) -o demo
```

## Use Statically

```bash
gcc -std=c17 -Wall -Wextra -g -static demo.c $(pkg-config --cflags --libs --static foo) -o demo
./demo
```

## Troubleshooting

Verify that pkg-config is installed and can find the installed library.

```bash
pkg-config --exists foo && echo "Found" || echo "Not found"
pkg-config --modversion foo
pkg-config --cflags --libs foo
```

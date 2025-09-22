# Compiler selection (macOS default is clang)
CC := clang

# Libraries to include - ADD NEW LIBRARIES HERE
# To add a new library, define its _LIBS and _CFLAGS below

# Library configurations (Homebrew paths)
ifneq (,$(wildcard /opt/homebrew/lib))
    # Apple Silicon Macs
    SSL_LIBS := -L/opt/homebrew/lib -lssl -lcrypto
    SSL_CFLAGS := -I/opt/homebrew/include
    PNG_LIBS := -L/opt/homebrew/lib -lpng
    PNG_CFLAGS := -I/opt/homebrew/include
else ifneq (,$(wildcard /usr/local/lib))
    # Intel Macs
    SSL_LIBS := -L/usr/local/lib -lssl -lcrypto
    SSL_CFLAGS := -I/usr/local/include
    PNG_LIBS := -L/usr/local/lib -lpng
    PNG_CFLAGS := -I/usr/local/include
else
    # System default
    SSL_LIBS := -lssl -lcrypto
    SSL_CFLAGS :=
    PNG_LIBS := -lpng
    PNG_CFLAGS :=
endif

# Testing framework
GLIB_LIBS := $(shell pkg-config --libs glib-2.0 2>/dev/null)
GLIB_CFLAGS := $(shell pkg-config --cflags glib-2.0 2>/dev/null)

# Distribution and compiler specific flags
DISTRO_CFLAGS := -D_DARWIN_C_SOURCE \
  -fcolor-diagnostics \
  -Wno-gnu-zero-variadic-macro-arguments \
  $(SSL_CFLAGS) $(PNG_CFLAGS) $(GLIB_CFLAGS)
DISTRO_LDFLAGS := -Wl,-dead_strip -Wl,-pie \
  $(SSL_LIBS) $(PNG_LIBS) $(GLIB_LIBS)

DEV_PACKAGES := openssl libpng glib pkg-config clang-format
INSTALL_DEPS_CMD := xcode-select --install; brew install $(DEV_PACKAGES)

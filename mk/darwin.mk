# Compiler selection (macOS default is clang)
CC := clang

# macOS doesn't use multiarch tuples - libraries go directly in lib/
MULTIARCH_TUPLE :=

# Libraries to include - ADD NEW LIBRARIES HERE
# To add a new library, define its _LIBS and _CFLAGS below

# Library configurations (Homebrew paths)
ifneq (,$(wildcard /opt/homebrew/lib))
    # Apple Silicon Macs
    SSL_LIBS := -L/opt/homebrew/lib -lssl -lcrypto
    SSL_CFLAGS := -I/opt/homebrew/include
    PNG_NAME := png
    PNG_LIBS := -L/opt/homebrew/lib -l$(PNG_NAME)
    PNG_CFLAGS := -I/opt/homebrew/include
    PNG_PC_REQUIRES := lib$(PNG_NAME)
else ifneq (,$(wildcard /usr/local/lib))
    # Intel Macs
    SSL_LIBS := -L/usr/local/lib -lssl -lcrypto
    SSL_CFLAGS := -I/usr/local/include
    PNG_NAME := png
    PNG_LIBS := -L/usr/local/lib -l$(PNG_NAME)
    PNG_CFLAGS := -I/usr/local/include
    PNG_PC_REQUIRES := lib$(PNG_NAME)
else
    # System default
    SSL_LIBS := -lssl -lcrypto
    SSL_CFLAGS :=
    PNG_NAME := png
    PNG_LIBS := -l$(PNG_NAME)
    PNG_CFLAGS := $(shell pkg-config --cflags lib$(PNG_NAME) 2>/dev/null)
    PNG_PC_REQUIRES := lib$(PNG_NAME)
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

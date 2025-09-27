# Compiler selection (macOS default is clang)
CC := clang

# macOS doesn't use multiarch tuples - libraries go directly in lib/
MULTIARCH_TUPLE :=

# Library configurations (Homebrew paths)
ifneq (,$(wildcard /opt/homebrew/lib))
    # Apple Silicon Macs
    PNG_NAME := png
    PNG_LIBS := -L/opt/homebrew/lib -l$(PNG_NAME)
    PNG_CFLAGS := -I/opt/homebrew/include
    JPEG_NAME := jpeg
    JPEG_LIBS := -L/opt/homebrew/lib -l$(JPEG_NAME)
    JPEG_CFLAGS := -I/opt/homebrew/include
else
    # Intel Macs
    PNG_NAME := png
    PNG_LIBS := -L/usr/local/lib -l$(PNG_NAME)
    PNG_CFLAGS := -I/usr/local/include
    JPEG_NAME := jpeg
    JPEG_LIBS := -L/usr/local/lib -l$(JPEG_NAME)
    JPEG_CFLAGS := -I/usr/local/include
endif

# Aggregated runtime dependencies
LIB_DEPS_LIBS := $(PNG_LIBS) $(JPEG_LIBS)
LIB_DEPS_CFLAGS := $(PNG_CFLAGS) $(JPEG_CFLAGS)
LIB_DEPS_PC := lib$(PNG_NAME) lib$(JPEG_NAME)

# This is what goes into pkg-config
PC_REQUIRES := $(LIB_DEPS_PC)

# Test-only dependencies (not linked into the library)
TEST_GLIB_LIBS := $(shell pkg-config --libs glib-2.0 2>/dev/null)
TEST_GLIB_CFLAGS := $(shell pkg-config --cflags glib-2.0 2>/dev/null)
TEST_PC_REQUIRES := glib-2.0

# All pkg-config packages we need to check for
CHECK_PC_PACKAGES := $(LIB_DEPS_PC) $(TEST_PC_REQUIRES)

# Optional tools to check for
CHECK_OPTIONAL_TOOLS := clang-format ctags

# Compile flags for the library
DISTRO_CFLAGS := -D_DARWIN_C_SOURCE \
  -fcolor-diagnostics \
  -Wno-gnu-zero-variadic-macro-arguments \
  $(LIB_DEPS_CFLAGS)

# Linker flags for the library
DISTRO_LDFLAGS := -Wl,-dead_strip -Wl,-pie \
  $(LIB_DEPS_LIBS)

# Test-specific compile flags (includes test framework headers)
TEST_CFLAGS := $(DISTRO_CFLAGS) $(TEST_GLIB_CFLAGS)

# Test-specific linker flags (includes all libraries needed for tests)
TEST_LDFLAGS := $(DISTRO_LDFLAGS) $(TEST_GLIB_LIBS)

DEV_PACKAGES := libpng jpeg glib pkg-config clang-format
INSTALL_DEPS_CMD := xcode-select --install; brew install $(DEV_PACKAGES)

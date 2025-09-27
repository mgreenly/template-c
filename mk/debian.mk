CC := gcc

# Debian multiarch tuple
MULTIARCH_TUPLE := $(shell dpkg --print-architecture 2>/dev/null || echo "amd64")-linux-gnu

PNG_NAME := png16
PNG_LIBS := -l$(PNG_NAME)
PNG_CFLAGS := $(shell pkg-config --cflags lib$(PNG_NAME) 2>/dev/null)
PNG_PC_REQUIRES := lib$(PNG_NAME)

# GLib only for tests (not linked into the library itself)
GLIB_LIBS := $(shell pkg-config --libs glib-2.0 2>/dev/null)
GLIB_CFLAGS := $(shell pkg-config --cflags glib-2.0 2>/dev/null)

DISTRO_CFLAGS := -D_DEFAULT_SOURCE \
  -fanalyzer -fstack-clash-protection \
  -Wduplicated-cond -Wduplicated-branches \
  -Wformat-signedness -fdiagnostics-color \
  $(PNG_CFLAGS)

DISTRO_LDFLAGS := -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -Wl,--as-needed -pie \
  $(PNG_LIBS)

DEV_PACKAGES := build-essential libpng-dev libglib2.0-dev pkg-config cppcheck

INSTALL_DEPS_CMD := sudo apt-get install $(DEV_PACKAGES)

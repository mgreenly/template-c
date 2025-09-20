LIB_SSL := -lssl -lcrypto
CFLAG_SSL := 

LIB_PNG := -lpng
CFLAG_PNG := 

PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
MANDIR := $(PREFIX)/share/man

DISTRO_CFLAGS := -D_DARWIN_C_SOURCE

DEV_PACKAGES := openssl libpng

INSTALL_DEPS_CMD := xcode-select --install; brew install $(DEV_PACKAGES)

DISTRO_LDFLAGS := -Wl,-dead_strip

# macOS Homebrew library paths (if using Homebrew)
ifneq (,$(wildcard /opt/homebrew/lib))
    # Apple Silicon Macs
    LIB_SSL := -L/opt/homebrew/lib -lssl -lcrypto
    CFLAG_SSL := -I/opt/homebrew/include
    LIB_PNG := -L/opt/homebrew/lib -lpng
    CFLAG_PNG := -I/opt/homebrew/include
else ifneq (,$(wildcard /usr/local/lib))
    # Intel Macs
    LIB_SSL := -L/usr/local/lib -lssl -lcrypto
    CFLAG_SSL := -I/usr/local/include
    LIB_PNG := -L/usr/local/lib -lpng
    CFLAG_PNG := -I/usr/local/include
endif

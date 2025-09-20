LIB_SSL := -lssl -lcrypto
CFLAG_SSL :=

LIB_PNG := -lpng
CFLAG_PNG :=

DISTRO_CFLAGS := -D_DEFAULT_SOURCE

DISTRO_LDFLAGS := -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -Wl,--as-needed

DEV_PACKAGES := build-essential libssl-dev libpng-dev

INSTALL_DEPS_CMD := sudo apt-get install $(DEV_PACKAGES)

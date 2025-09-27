DISTRO := $(shell if [ "$(shell uname -s)" = "Darwin" ]; then echo "darwin"; elif [ -f /etc/os-release ]; then . /etc/os-release && echo $$ID; else echo "unknown"; fi)
-include mk/$(DISTRO).mk

CFLAGS_COMMON = -std=c17 -pedantic \
  -Wshadow -Wstrict-prototypes -Wmissing-prototypes -Wwrite-strings \
  -Werror -Wall -Wextra -Wformat=2 -Wconversion -Wcast-qual -Wundef \
  -Wdate-time -Winit-self -Wstrict-overflow=2 \
  -MMD -MP -fstack-protector-strong -fPIC \
  -Wimplicit-fallthrough -Walloca -Wvla \
  -Wnull-dereference -Wdouble-promotion

CFLAGS_DEBUG = -D_FORTIFY_SOURCE=2 -g -O0

CFLAGS_RELEASE_OPTS = -DNDEBUG -g -O3

CFLAGS_BASE = $(CFLAGS_COMMON) $(CFLAGS_DEBUG)
CFLAGS_RELEASE = $(CFLAGS_COMMON) $(CFLAGS_RELEASE_OPTS)

CFLAGS_TEST = $(filter-out -Wmissing-prototypes,$(CFLAGS_COMMON)) $(CFLAGS_DEBUG) $(DISTRO_CFLAGS) $(GLIB_CFLAGS)

CFLAGS = $(CFLAGS_BASE) $(DISTRO_CFLAGS) $(PNG_CFLAGS)

LDFLAGS = $(DISTRO_LDFLAGS)

ifeq ($(PREFIX),)
PREFIX = /usr/local
endif

SRCDIR := src
OBJDIR := obj
LIBDIR := lib
REPORTSDIR := reports
TMPDIR := tmp

# Library name and version
LIBNAME := foo
VERSION_MAJOR := 0
VERSION_MINOR := 1
VERSION_PATCH := 0
VERSION := $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
SOVERSION := $(VERSION_MAJOR)

# Library source files (only foo.c)
LIB_SOURCES := $(SRCDIR)/foo.c
LIB_OBJECTS := $(LIB_SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
LIB_DEPS := $(LIB_OBJECTS:.o=.d)

# All objects and dependencies
OBJECTS := $(LIB_OBJECTS)
DEPS := $(LIB_DEPS)

# Library files
STATIC_LIB := $(LIBDIR)/lib$(LIBNAME).a
DYNAMIC_LIB := $(LIBDIR)/lib$(LIBNAME).so.$(VERSION)
DYNAMIC_LIB_SONAME := $(LIBDIR)/lib$(LIBNAME).so.$(SOVERSION)
DYNAMIC_LIB_LINK := $(LIBDIR)/lib$(LIBNAME).so

# Library installation directory (set by distro-specific makefile)
# On Debian: $(PREFIX)/lib/amd64-linux-gnu, on macOS: $(PREFIX)/lib
LIBDIR_INSTALL := $(PREFIX)/lib$(if $(MULTIARCH_TUPLE),/$(MULTIARCH_TUPLE))

all: $(STATIC_LIB) $(DYNAMIC_LIB) $(LIBNAME).pc

release: CFLAGS = $(CFLAGS_RELEASE) $(DISTRO_CFLAGS)
release: clean all

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(LIBDIR):
	mkdir -p $(LIBDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Static library
$(STATIC_LIB): $(LIB_OBJECTS) | $(LIBDIR)
	ar rcs $@ $^

# Dynamic library
$(DYNAMIC_LIB): $(LIB_OBJECTS) | $(LIBDIR)
	$(CC) -shared -Wl,-soname,lib$(LIBNAME).so.$(SOVERSION) $(LIB_OBJECTS) $(PNG_LIBS) -o $@
	cd $(LIBDIR) && ln -sf lib$(LIBNAME).so.$(VERSION) lib$(LIBNAME).so.$(SOVERSION)
	cd $(LIBDIR) && ln -sf lib$(LIBNAME).so.$(VERSION) lib$(LIBNAME).so


clean:
	rm -rf $(OBJDIR) $(LIBDIR) $(REPORTSDIR) $(TMPDIR) tags $(LIBNAME).pc

-include $(DEPS)

.PHONY: all release clean check install uninstall tags fmt help deps check-deps coverage sanitize analyze check-all

check: require-glib
	@mkdir -p $(TMPDIR)
	@echo "Running tests..."
	@for test in tests/*_test.c; do \
		echo ""; \
		testname=$$(basename $$test .c); \
		libname=$${testname%_test}; \
		if [ "$$libname" = "foo" ]; then \
			echo "testing $$libname..."; \
			$(CC) $(CFLAGS_TEST) -I./src $$test src/$$libname.c $(GLIB_LIBS) -MF $(TMPDIR)/$$testname.d -o $(TMPDIR)/$$testname; \
			$(TMPDIR)/$$testname || exit 1; \
		fi; \
	done
	@echo ""

# Generate pkg-config file
$(LIBNAME).pc: pkgconfig/$(LIBNAME).pc.in
	sed -e 's|@PREFIX@|$(PREFIX)|g' \
	    -e 's|@LIBDIR_INSTALL@|$(LIBDIR_INSTALL)|g' \
	    -e 's|@VERSION@|$(VERSION)|g' \
	    -e 's|@PNG_PC_REQUIRES@|$(PNG_PC_REQUIRES)|g' \
	    $< > $@

install: $(STATIC_LIB) $(DYNAMIC_LIB) $(LIBNAME).pc
	@mkdir -p $(LIBDIR_INSTALL)
	@mkdir -p $(PREFIX)/include/$(LIBNAME)
	@mkdir -p $(PREFIX)/lib/pkgconfig
	install -m 644 $(STATIC_LIB) $(LIBDIR_INSTALL)/
	install -m 755 $(DYNAMIC_LIB) $(LIBDIR_INSTALL)/
	cd $(LIBDIR_INSTALL) && ln -sf lib$(LIBNAME).so.$(VERSION) lib$(LIBNAME).so.$(SOVERSION)
	cd $(LIBDIR_INSTALL) && ln -sf lib$(LIBNAME).so.$(VERSION) lib$(LIBNAME).so
	install -m 644 src/$(LIBNAME).h $(PREFIX)/include/$(LIBNAME)/
	install -m 644 src/version.h $(PREFIX)/include/$(LIBNAME)/
	install -m 644 $(LIBNAME).pc $(PREFIX)/lib/pkgconfig/

uninstall:
	rm -f $(LIBDIR_INSTALL)/lib$(LIBNAME).a
	rm -f $(LIBDIR_INSTALL)/lib$(LIBNAME).so*
	rm -rf $(PREFIX)/include/$(LIBNAME)
	rm -f $(PREFIX)/lib/pkgconfig/$(LIBNAME).pc

tags:
	@command -v ctags >/dev/null 2>&1 || { \
		echo "Error: ctags is not installed."; \
		exit 1; \
	}
	ctags -R $(SRCDIR)


fmt:
	@find $(SRCDIR) tests \( -name "*.c" -o -name "*.h" \) -type f \
		| while read file; do \
			echo "Formatting: $$file"; \
			clang-format -i "$$file"; \
		done

help:
	@echo "Available targets:"
	@echo "  all       - Build static and dynamic libraries (default, debug mode)"
	@echo "  release   - Build optimized release version"
	@echo "  clean     - Remove build artifacts"
	@echo "  deps      - Show package installation instructions"
	@echo "  check-deps - Check if build dependencies are available"
	@echo "  install   - Install the library"
	@echo "  uninstall - Uninstall the library"
	@echo "  check     - Run tests"
	@echo "  coverage  - Run tests with coverage analysis"
	@echo "  sanitize  - Run tests with AddressSanitizer and UBSan"
	@echo "  analyze   - Run static analysis (clang or cppcheck)"
	@echo "  check-all - Run comprehensive checks (check + analyze + sanitize + coverage)"
	@echo "  tags      - Generate ctags file"
	@echo "  fmt       - Format code with clang-format"
	@echo "  help      - Show this help message"

deps:
	@echo ""
	@echo "To install required development packages:"
	@echo ""
	@echo "  $(INSTALL_DEPS_CMD)"
	@echo ""
	@echo "To check if all dependencies are available:"
	@echo ""
	@echo "  make check-deps"
	@echo ""

check-deps:
	@echo "Checking build dependencies..."
	@command -v pkg-config >/dev/null 2>&1 || { \
		echo "Error: pkg-config not found. Please install pkg-config."; \
		exit 1; \
	}
	@echo "✓ pkg-config found"
	@echo "All dependencies satisfied!"

require-glib:
	@pkg-config --exists glib-2.0 || { \
		echo "Error: GLib 2.0 not found. Please install libglib2.0-dev"; \
		echo "Run: $(INSTALL_DEPS_CMD)"; \
		exit 1; \
	}

coverage: require-glib
	@mkdir -p $(REPORTSDIR) $(TMPDIR)
	@echo "Running tests with coverage..."
	@for test in tests/*_test.c; do \
		testname=$$(basename $$test .c); \
		libname=$${testname%_test}; \
		if [ "$$libname" = "foo" ]; then \
			echo "Testing $$libname with coverage..."; \
			$(CC) $(CFLAGS_TEST) -I./src $$test src/$$libname.c $(GLIB_LIBS) --coverage -MF $(TMPDIR)/$$testname.d -o $(TMPDIR)/$$testname; \
			$(TMPDIR)/$$testname || exit 1; \
		fi; \
	done
	@echo "Generating coverage report..."
	@for file in src/foo.c tests/foo_test.c; do \
		if [ -f "$$file" ]; then \
			base=$$(basename $$file .c); \
			for testfile in $(TMPDIR)/*_test-$${base}.gcda $(TMPDIR)/$${base}.gcda; do \
				if [ -f "$$testfile" ]; then \
					cd $(TMPDIR) && gcov "$$(basename $$testfile)"; \
				fi; \
			done; \
		fi; \
	done
	@mv $(TMPDIR)/*.gcov $(REPORTSDIR)/ 2>/dev/null || true
	@echo "Coverage files: $(REPORTSDIR)/*.gcov"

sanitize: CFLAGS = $(filter-out -D_FORTIFY_SOURCE=2,$(CFLAGS_COMMON) $(CFLAGS_DEBUG)) $(DISTRO_CFLAGS) -fsanitize=address,undefined
sanitize: LDFLAGS = $(DISTRO_LDFLAGS) -fsanitize=address,undefined
sanitize: require-glib clean
	@mkdir -p $(TMPDIR)
	@echo "Running tests with sanitizers..."
	@for test in tests/*_test.c; do \
		testname=$$(basename $$test .c); \
		libname=$${testname%_test}; \
		if [ "$$libname" = "foo" ]; then \
			echo "Testing $$libname with sanitizers..."; \
			$(CC) $(filter-out -D_FORTIFY_SOURCE=2,$(CFLAGS_TEST)) -I./src $$test src/$$libname.c $(GLIB_LIBS) -fsanitize=address,undefined -MF $(TMPDIR)/$$testname.d -o $(TMPDIR)/$$testname; \
			$(TMPDIR)/$$testname || exit 1; \
		fi; \
	done

analyze:
	@echo "Running static analysis..."
	@mkdir -p $(REPORTSDIR) $(TMPDIR)
	@command -v clang >/dev/null 2>&1 && { \
		echo "Using clang static analyzer..."; \
		if clang --analyze $(filter-out -MMD -MP -fanalyzer,$(CFLAGS)) src/foo.c tests/foo_test.c; then \
			echo "Static analysis completed - no issues found!"; \
		fi; \
		mv *.plist $(REPORTSDIR)/ 2>/dev/null || true; \
	} || { \
		echo "clang not found, trying cppcheck..."; \
		command -v cppcheck >/dev/null 2>&1 && { \
			cppcheck --enable=all --std=c17 --suppress=missingIncludeSystem --suppress=missingInclude src/foo.c --quiet && \
			echo "Static analysis completed - no issues found!"; \
		} || { \
			echo "No static analysis tools found. Install clang or cppcheck."; \
		}; \
	}

check-all:
	@echo "=== Running comprehensive checks ==="
	@echo "1/4: Running unit tests..."
	@$(MAKE) check
	@echo ""
	@echo "2/4: Running static analysis..."
	@$(MAKE) analyze
	@echo ""
	@echo "3/4: Running sanitizer tests..."
	@$(MAKE) sanitize
	@echo ""
	@echo "4/4: Running coverage analysis..."
	@$(MAKE) coverage
	@echo ""
	@echo "=== All checks completed successfully! ==="

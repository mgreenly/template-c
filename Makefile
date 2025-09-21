DISTRO := $(shell if [ "$(shell uname -s)" = "Darwin" ]; then echo "macos"; elif [ -f /etc/os-release ]; then . /etc/os-release && echo $$ID; else echo "unknown"; fi)
-include mk/$(DISTRO).mk

ifeq ($(CC),)
	CC := gcc
endif

CFLAGS_COMMON = -std=c17 -pedantic \
  -Wshadow -Wstrict-prototypes -Wmissing-prototypes -Wwrite-strings \
  -Werror -Wall -Wextra -Wformat=2 -Wconversion -Wcast-qual -Wundef \
  -Wdate-time -Winit-self -Wstrict-overflow=2 \
  -MMD -MP -fstack-protector-strong -fPIE \
  -Wimplicit-fallthrough -Walloca -Wvla \
  -Wnull-dereference -Wdouble-promotion

CFLAGS_DEBUG = -D_FORTIFY_SOURCE=2 -g -O0

CFLAGS_RELEASE_ONLY = -DNDEBUG -g -O3

CFLAGS_BASE = $(CFLAGS_COMMON) $(CFLAGS_DEBUG)
CFLAGS_RELEASE = $(CFLAGS_COMMON) $(CFLAGS_RELEASE_ONLY)

# Test-specific flags (removes -Wmissing-prototypes for Unity tests)
CFLAGS_TEST = $(filter-out -Wmissing-prototypes,$(CFLAGS_COMMON)) $(CFLAGS_DEBUG)

ifneq (,$(findstring clang,$(shell $(CC) --version 2>/dev/null)))
	CFLAGS_COMPILER = -fcolor-diagnostics \
	  -Wno-gnu-zero-variadic-macro-arguments
else
	CFLAGS_COMPILER = -fanalyzer -fstack-clash-protection \
	  -Wduplicated-cond -Wduplicated-branches \
	  -Wformat-signedness -fdiagnostics-color
endif

CFLAGS = $(CFLAGS_BASE) $(CFLAGS_COMPILER) $(DISTRO_CFLAGS)

LDFLAGS_COMMON = 

LDFLAGS = $(LDFLAGS_COMMON) $(DISTRO_LDFLAGS) $(LIB_SSL) $(LIB_PNG)

# Installation paths
PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin

CFLAG_UNITY := -Ivendor/Unity/src
UNITY_SRC := vendor/Unity/src/unity.c

SRCDIR := src
OBJDIR := obj
BINDIR_LOCAL := bin
REPORTSDIR := reports
TMPDIR := tmp
SOURCES := $(wildcard $(SRCDIR)/*.c)
OBJECTS := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
DEPS := $(OBJECTS:.o=.d)
TARGET := $(BINDIR_LOCAL)/myapp

all: $(TARGET)

release: CFLAGS = $(CFLAGS_RELEASE) $(CFLAGS_COMPILER)
release: clean $(TARGET)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR_LOCAL):
	mkdir -p $(BINDIR_LOCAL)

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS) | $(BINDIR_LOCAL)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

clean:
	rm -rf $(OBJDIR) $(REPORTSDIR) $(BINDIR_LOCAL) $(TMPDIR)

distclean: clean
	rm -rf vendor/ .gitmodules

-include $(DEPS)

.PHONY: all release clean distclean check install uninstall tags fmt help print-install-cmd coverage sanitize analyze validate

check:
	@if [ ! -d "vendor" ]; then \
		echo "Error: Dependencies not found. Run './configure' first."; \
		exit 1; \
	fi
	@mkdir -p $(TMPDIR)
	@echo "Running tests..."
	$(CC) $(CFLAGS_TEST) $(CFLAGS_COMPILER) $(DISTRO_CFLAGS) -I./vendor/Unity/src tests/foo_test.c src/foo.c $(UNITY_SRC) -MF $(TMPDIR)/test_runner.d -o $(TMPDIR)/test_runner
	$(TMPDIR)/test_runner

install: $(TARGET)
	@mkdir -p $(BINDIR)
	install -m 755 $(TARGET) $(BINDIR)/
	@echo "Installed to $(BINDIR)/myapp"

uninstall:
	rm -f $(BINDIR)/myapp
	@echo "Removed $(BINDIR)/myapp"

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
	@echo "  all       - Build the project (default, debug mode)"
	@echo "  release   - Build optimized release version"
	@echo "  clean     - Remove build artifacts"
	@echo "  distclean - Remove build artifacts and vendor dependencies"
	@echo "  install   - Install the program"
	@echo "  uninstall - Uninstall the program"
	@echo "  check     - Run tests"
	@echo "  coverage  - Run tests with coverage analysis"
	@echo "  sanitize  - Run tests with AddressSanitizer and UBSan"
	@echo "  analyze   - Run static analysis (clang or cppcheck)"
	@echo "  validate  - Run comprehensive validation (check + analyze + sanitize + coverage)"
	@echo "  tags      - Generate ctags file"
	@echo "  fmt       - Format code with clang-format"
	@echo "  help      - Show this help message"

print-install-cmd:
	@echo "$(INSTALL_DEPS_CMD)"

coverage:
	@if [ ! -d "vendor" ]; then \
		echo "Error: Dependencies not found. Run './configure' first."; \
		exit 1; \
	fi
	@mkdir -p $(REPORTSDIR) $(TMPDIR)
	@echo "Running tests with coverage..."
	$(CC) $(CFLAGS_TEST) $(CFLAGS_COMPILER) $(DISTRO_CFLAGS) -I./vendor/Unity/src tests/foo_test.c src/foo.c $(UNITY_SRC) --coverage -MF $(TMPDIR)/test_runner.d -o $(TMPDIR)/test_runner
	$(TMPDIR)/test_runner
	@echo "Generating coverage report..."
	@for file in src/*.c tests/*.c; do \
		base=$$(basename $$file .c); \
		if [ -f "$(TMPDIR)/$${base}.gcda" ]; then \
			cd $(TMPDIR) && gcov "$${base}.gcda"; \
		elif [ -f "$(TMPDIR)/test_runner-$${base}.gcda" ]; then \
			cd $(TMPDIR) && gcov "test_runner-$${base}.gcda"; \
		fi; \
	done
	@mv $(TMPDIR)/*.gcov $(REPORTSDIR)/ 2>/dev/null || true
	@echo "Coverage files: $(REPORTSDIR)/*.gcov (only our source code)"

sanitize: CFLAGS = $(filter-out -D_FORTIFY_SOURCE=2,$(CFLAGS_COMMON) $(CFLAGS_DEBUG)) $(CFLAGS_COMPILER) $(DISTRO_CFLAGS) -fsanitize=address,undefined
sanitize: LDFLAGS = $(LDFLAGS_COMMON) $(DISTRO_LDFLAGS) $(LIB_SSL) $(LIB_PNG) -fsanitize=address,undefined
sanitize: clean $(TARGET)
	@if [ ! -d "vendor" ]; then \
		echo "Error: Dependencies not found. Run './configure' first."; \
		exit 1; \
	fi
	@mkdir -p $(TMPDIR)
	@echo "Running tests with sanitizers..."
	$(CC) $(filter-out -D_FORTIFY_SOURCE=2,$(CFLAGS_TEST)) $(CFLAGS_COMPILER) $(DISTRO_CFLAGS) -I./vendor/Unity/src tests/foo_test.c src/foo.c $(UNITY_SRC) -fsanitize=address,undefined -MF $(TMPDIR)/test_runner.d -o $(TMPDIR)/test_runner
	$(TMPDIR)/test_runner

analyze:
	@if [ ! -d "vendor" ]; then \
		echo "Error: Dependencies not found. Run './configure' first."; \
		exit 1; \
	fi
	@echo "Running static analysis..."
	@mkdir -p $(REPORTSDIR) $(TMPDIR)
	@command -v clang >/dev/null 2>&1 && { \
		echo "Using clang static analyzer..."; \
		if clang --analyze $(filter-out -MMD -MP,$(CFLAGS_COMMON)) -I./vendor/Unity/src $(DISTRO_CFLAGS) src/*.c tests/*.c; then \
			echo "Static analysis completed - no issues found!"; \
		fi; \
		mv *.plist $(REPORTSDIR)/ 2>/dev/null || true; \
	} || { \
		echo "clang not found, trying cppcheck..."; \
		command -v cppcheck >/dev/null 2>&1 && { \
			cppcheck --enable=all --std=c17 --suppress=missingIncludeSystem --suppress=missingInclude src/ --quiet && \
			echo "Static analysis completed - no issues found!"; \
			echo "Note: Unity test functions are expected to be non-static and unused by cppcheck"; \
		} || { \
			echo "No static analysis tools found. Install clang or cppcheck."; \
		}; \
	}

validate:
	@echo "=== Running comprehensive validation ==="
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
	@echo "=== Validation completed successfully! ==="

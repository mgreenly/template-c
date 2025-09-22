# C Project Template

A C project template for Linux distributions and macOS with simple Makefile.

## Features

- **Standard C17**: Clean, portable C code
- **Cross-platform support**: Linux distributions and macOS
- **Manual distribution configuration**: Easy-to-understand makefiles for each distribution you want to support
- **Simple project setup**: Easy renaming script for new projects

## Quick Start

1. **Clone this template**:
   ```bash
   git clone https://github.com/mgreenly/template-c myapp
   cd myapp
   ```
2. **Rename your project**:
   ```bash
   ./rename.sh myapp
   ```
3. **Delete the rename script**:
   ```bash
   rm rename.sh
   ```
4. **Build the project**:
   ```bash
   ./configure; make
   ```

## Project Structure

```
├── src/           # Source files
├── mk/            # Distribution-specific makefiles
│   └── debian.mk  # Debian/Ubuntu configuration
├── Makefile       # Main makefile
├── configure      # Configuration script
└── rename.sh      # Project renaming script
```

## Distribution Support

The build system detects your distribution and loads the corresponding configuration file:

- **Debian/Ubuntu**: `mk/debian.mk`
- **macOS (Darwin)**: `mk/darwin.mk`

To add support for a new distribution, simply create `mk/{distro-id}.mk` and define the library flags and paths for that system. The makefile structure is straightforward and easy to understand.

## Building

Check `make help` for all available make targets.

## Testing

The project uses GLib's test framework for unit testing. Tests are automatically discovered from `tests/*_test.c` files.

### Running Tests

```bash
# Run all tests
make check

# Run tests with coverage analysis
make coverage

# Run tests with sanitizers (AddressSanitizer and UBSan)
make sanitize
```

### Running Specific Tests

GLib tests support targeting specific test functions, which is useful for debugging:

```bash
# Build the tests first
make check

# List all available tests in a test executable
tmp/foo_test -l

# Run a specific test function
tmp/foo_test -p /foo/add_positive_numbers

# Run multiple specific tests
tmp/foo_test -p /foo/add_negative_numbers -p /foo/add_zero

# Skip specific tests
tmp/foo_test -s /foo/add_zero

# Run with verbose output
tmp/foo_test --verbose

# Use a specific random seed for reproducibility
tmp/foo_test --seed R02S1234567890abcdef
```

### Adding New Tests

To add tests for a new library:
1. Create `src/mylib.c` with your library code
2. Create `tests/mylib_test.c` with GLib test cases
3. Run `make check` - the test will be automatically discovered and run

## Adding Dependencies

Edit the appropriate distribution makefile in `mk/` to add library dependencies:

```makefile
# Example: Adding a new library
LIB_CURL := -lcurl
CFLAG_CURL := -DUSE_CURL
```

Then update the main `Makefile` to use the new variables.

## License

MIT No Attribution License (MIT-0)

Copyright (c) 2025 Michael Greenly

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

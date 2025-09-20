#!/bin/bash

if [ $# -eq 1 ]; then
    OLD_NAME="myprogram"
    NEW_NAME="$1"
elif [ $# -eq 2 ]; then
    OLD_NAME="$1"
    NEW_NAME="$2"
else
    echo "Usage: $0 [old-project-name] <new-project-name>"
    echo "Examples:"
    echo "  $0 myapp                 # Renames 'myprogram' to 'myapp'"
    echo "  $0 myprogram myapp       # Renames 'myprogram' to 'myapp'"
    exit 1
fi

# Validate project name (alphanumeric and hyphens only)
if ! [[ "$NEW_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Project name can only contain letters, numbers, underscores, and hyphens"
    exit 1
fi

echo "Renaming project from '$OLD_NAME' to '$NEW_NAME'..."

# Update Makefile (binary is now in bin/ directory)
sed -i "s/TARGET := \$(BINDIR_LOCAL)\/$OLD_NAME/TARGET := \$(BINDIR_LOCAL)\/$NEW_NAME/" Makefile

# Rename the binary if it exists
if [ -f "bin/$OLD_NAME" ]; then
    mv "bin/$OLD_NAME" "bin/$NEW_NAME"
    echo "Renamed binary: bin/$OLD_NAME -> bin/$NEW_NAME"
elif [ -f "$OLD_NAME" ]; then
    mv "$OLD_NAME" "$NEW_NAME"
    echo "Renamed binary: $OLD_NAME -> $NEW_NAME"
fi

# Update any source files that might reference the old name
find src/ tests/ mk/ -name "*.c" -o -name "*.h" -o -name "*.mk" | xargs sed -i "s/$OLD_NAME/$NEW_NAME/g" 2>/dev/null || true

# Update config.h if it exists and contains program name references
if [ -f "src/config.h" ]; then
    sed -i "s/$OLD_NAME/$NEW_NAME/g" src/config.h 2>/dev/null || true
fi

# Update configure script if it contains project name references
if [ -f "configure" ]; then
    sed -i "s/$OLD_NAME/$NEW_NAME/g" configure 2>/dev/null || true
fi

# Update any documentation files
find . -maxdepth 1 -name "*.md" -o -name "*.txt" | xargs sed -i "s/$OLD_NAME/$NEW_NAME/g" 2>/dev/null || true

echo "Project renamed successfully!"
echo "Note: The following files were automatically updated if they contained '$OLD_NAME':"
echo "  - Makefile, configure script"
echo "  - Source files in src/ and tests/"
echo "  - Build configuration in mk/"
echo "  - README.md and other documentation files"
echo ""
echo "You may want to manually review and update:"
echo "  - Project description in README.md"
echo "  - License files (author/project name)"
echo ""

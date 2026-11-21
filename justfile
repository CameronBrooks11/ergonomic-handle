# ergonomic-handle task runner

set dotenv-load := false

# Default: show available recipes
default:
    @just --list

# Render the library, examples and presets, and check the handle's height
test:
    python3 tests/test_ergonomic_handle.py

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl)
fmt:
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

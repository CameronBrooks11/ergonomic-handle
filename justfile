# ergonomic-handle task runner

set dotenv-load := false

# Default: show available recipes
default:
    @just --list

# Render the library, every example and every preset, failing on any OpenSCAD warning
test:
    @for f in ergonomic_handle.scad examples/*.scad; do echo "render $f"; log=$(openscad --hardwarnings --export-format binstl -o - "$f" 2>&1 >/dev/null) || { echo "$log"; exit 1; }; done
    @for p in $(python3 -c "import json; print(' '.join(json.load(open('ergonomic_handle.json'))['parameterSets']))"); do echo "render preset $p"; log=$(openscad --hardwarnings --export-format binstl -o - -p ergonomic_handle.json -P "$p" ergonomic_handle.scad 2>&1 >/dev/null) || { echo "$log"; exit 1; }; done

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl)
fmt:
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

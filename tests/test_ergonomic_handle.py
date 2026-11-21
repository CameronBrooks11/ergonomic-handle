"""Check ergonomic_handle.scad by rendering it.

usage: python3 tests/test_ergonomic_handle.py [OPENSCAD]

- The library, every example and every preset render with --hardwarnings.
  OpenSCAD exits 0 on a failed assert when exporting, so a WARNING or ERROR
  line fails the check, whatever the exit status.
- The handle's top is at z = 0 and its bottom ergonomic_handle_height() below
  it: hand_width x metacarpal_expansion. topext and bottomcapext add to that.
- metacarpal_expansion outside 1.10 to 1.15 is clamped, with a warning.
"""

import json
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "ergonomic_handle.scad")
results = []


def check(label, ok, got):
    results.append(bool(ok))
    print(f"{'ok  ' if ok else 'FAIL'} {label}: {got}")


def render(openscad, out, *args):
    r = subprocess.run([openscad, "--hardwarnings", "-o", out, *args], capture_output=True, text=True)
    bad = [l for l in r.stderr.splitlines() if l.startswith(("WARNING", "ERROR"))]
    return r, (bad[:1] or ([f"exit {r.returncode}"] if r.returncode else []))


def z_range(stl):
    zs = [float(l.split()[3]) for l in open(stl) if l.strip().startswith("vertex")]
    return min(zs), max(zs)


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    with tempfile.TemporaryDirectory() as tmp:
        stl = os.path.join(tmp, "out.stl")
        probe = os.path.join(tmp, "probe.scad")

        files = ["ergonomic_handle.scad"] + sorted(
            "examples/" + f for f in os.listdir(os.path.join(ROOT, "examples")) if f.endswith(".scad"))
        for f in files:
            _, bad = render(openscad, stl, "--export-format", "binstl", os.path.join(ROOT, f))
            check(f"{f} renders", not bad, bad[0] if bad else "no warnings")
        presets = json.load(open(os.path.join(ROOT, "ergonomic_handle.json")))["parameterSets"]
        for p in presets:
            _, bad = render(openscad, stl, "--export-format", "binstl",
                            "-p", os.path.join(ROOT, "ergonomic_handle.json"), "-P", p, LIB)
            check(f"preset {p} renders", not bad, bad[0] if bad else "no warnings")

        for args, want in [
            ("", (-95.2, 0)),
            ("hand_width = 76, metacarpal_expansion = 1.15", (-87.4, 0)),
            ("bottomcapext = 6, topext = 10", (-101.2, 10)),
            ("metacarpal_expansion = 1.2", (-97.75, 0)),
        ]:
            with open(probe, "w") as f:
                f.write(f"use <{LIB}>\nergonomic_handle({args});\n")
            r, bad = render(openscad, stl, "--export-format", "asciistl", probe)
            got = z_range(stl) if not bad else None
            ok = got and all(abs(g - w) < 1e-3 for g, w in zip(got, want))
            check(f"handle({args}) spans z {want[0]} to {want[1]}", ok,
                  bad[0] if bad else f"z {got[0]:.3f} to {got[1]:.3f}")

        clamped = "WARNING: metacarpal_expansion must be between 1.10 and 1.15" in r.stderr
        check("metacarpal_expansion 1.2 warns that it is clamped", clamped,
              "warned" if clamped else "no warning")

    print(f"{sum(results)} of {len(results)} checks passed")
    sys.exit(0 if all(results) else 1)


main()

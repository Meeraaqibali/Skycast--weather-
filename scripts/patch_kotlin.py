import os
import re
import sys

KOTLIN_VERSION = "1.9.0"

def pick(*candidates):
    """Return the first existing path, else None."""
    for p in candidates:
        if os.path.exists(p):
            return p
    return None

def bump_groovy_root(path):
    with open(path) as f:
        c = f.read()
    # replace any old ext.kotlin_version
    c = re.sub(r"ext\.kotlin_version\s*=\s*'[\d.]+'",
               f"ext.kotlin_version = '{KOTLIN_VERSION}'", c)
    if "ext.kotlin_version" not in c and "buildscript" in c:
        c = c.replace("buildscript {",
                      f"buildscript {{\n    ext.kotlin_version = '{KOTLIN_VERSION}'")
    with open(path, "w") as f:
        f.write(c)
    print(f"Bumped (groovy): {path}")

def bump_kts_root(path):
    with open(path) as f:
        c = f.read()
    # Kotlin DSL: `id("org.jetbrains.kotlin.android") version "X"` or similar
    c = re.sub(r'(id\("org\.jetbrains\.kotlin\.android"\)\s*version\s*")[\d.]+(")',
               rf'\g<1>{KOTLIN_VERSION}\g<2>', c)
    # Alternative: `kotlinVersion = "X"` variable
    c = re.sub(r'(kotlinVersion\s*=\s*")[\d.]+(")',
               rf'\g<1>{KOTLIN_VERSION}\g<2>', c)
    with open(path, "w") as f:
        f.write(c)
    print(f"Bumped (kts): {path}")

def bump_app_groovy(path):
    with open(path) as f:
        a = f.read()
    a = re.sub(r"id 'org\.jetbrains\.kotlin\.android' version '[\d.]+'",
               f"id 'org.jetbrains.kotlin.android' version '{KOTLIN_VERSION}'", a)
    with open(path, "w") as f:
        f.write(a)
    print(f"App (groovy) updated: {path}")

def bump_app_kts(path):
    with open(path) as f:
        a = f.read()
    a = re.sub(r'(id\("org\.jetbrains\.kotlin\.android"\)\s*version\s*")[\d.]+(")',
               rf'\g<1>{KOTLIN_VERSION}\g<2>', a)
    with open(path, "w") as f:
        f.write(a)
    print(f"App (kts) updated: {path}")

# ---- root build file -------------------------------------------------------
root = pick("android/build.gradle.kts", "android/build.gradle")
if not root:
    print("neither android/build.gradle.kts nor android/build.gradle found")
    sys.exit(1)

if root.endswith(".kts"):
    bump_kts_root(root)
else:
    bump_groovy_root(root)

# ---- app build file --------------------------------------------------------
app = pick("android/app/build.gradle.kts", "android/app/build.gradle")
if app:
    if app.endswith(".kts"):
        bump_app_kts(app)
    else:
        bump_app_groovy(app)

print(f"Kotlin version updated to {KOTLIN_VERSION}")

import re, os

path = "android/build.gradle"
if not os.path.exists(path):
    print("android/build.gradle not found")
    exit(1)

with open(path, "r") as f:
    c = f.read()

# Update Kotlin version from old to 1.9.0
old_versions = ["1.7.1", "1.7.0", "1.6.21", "1.5.31", "1.4.32", "1.3.72"]
for v in old_versions:
    c = c.replace(f"ext.kotlin_version = '{v}'", "ext.kotlin_version = '1.9.0'")

# If not present at all, add it
if "ext.kotlin_version" not in c:
    if "buildscript" in c:
        c = c.replace(
            "buildscript {",
            "buildscript {\n    ext.kotlin_version = '1.9.0'"
        )

with open(path, "w") as f:
    f.write(c)

print("Kotlin version updated to 1.9.0")

# Also update app/build.gradle Kotlin plugin if present
app_path = "android/app/build.gradle"
if os.path.exists(app_path):
    with open(app_path, "r") as f:
        a = f.read()
    a = re.sub(r"id 'org\.jetbrains\.kotlin\.android' version '[\d.]+'",
               "id 'org.jetbrains.kotlin.android' version '1.9.0'", a)
    with open(app_path, "w") as f:
        f.write(a)
    print("App Kotlin plugin updated")

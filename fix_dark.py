with open("lib/main.dart") as f:
    c = f.read()

# Make dark mode truly dark — near-black with subtle blue tint
c = c.replace(
    "Color _bg1() => _isLight ? const Color(0xFFB8D4F0) : const Color(0xFF1E3C4F);",
    "Color _bg1() => _isLight ? const Color(0xFFB8D4F0) : const Color(0xFF0A1418);"
)
c = c.replace(
    "Color _bg2() => _isLight ? const Color(0xFF8CB0D8) : const Color(0xFF3A6B8A);",
    "Color _bg2() => _isLight ? const Color(0xFF8CB0D8) : const Color(0xFF1A2A34);"
)

# Also fix _bgMid if it exists
c = c.replace(
    "Color _bgMid() => _isLight ? const Color(0xFFB8D4F0) : const Color(0xFF2C5364);",
    "Color _bgMid() => _isLight ? const Color(0xFFB8D4F0) : const Color(0xFF132028);"
)

# Update _DetailPage _isLight check to match new dark bg
c = c.replace(
    "bool get _isLight => bg1 == const Color(0xFFB8D4F0) || bg1 == const Color(0xFFDCE8F5);",
    "bool get _isLight => bg1.r > 0.7 || bg1 == const Color(0xFFB8D4F0) || bg1 == const Color(0xFFDCE8F5);"
)

# Fallback with alternate form
c = c.replace(
    "bool get _isLight => bg1 == const Color(0xFFDCE8F5);",
    "bool get _isLight => bg1 == const Color(0xFFB8D4F0) || bg1 == const Color(0xFFDCE8F5);"
)

with open("lib/main.dart", "w") as f:
    f.write(c)

print("=== APPLIED ===")
print("bg1 dark fixed:", "0xFF0A1418" in c)
print("bg2 dark fixed:", "0xFF1A2A34" in c)

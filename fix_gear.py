with open("lib/main.dart") as f:
    c = f.read()

# 1. Make FAB (gear button) solid in dark mode
old_fab = "backgroundColor: _cardBg(),\n        onPressed: _openSettings,"
new_fab = "backgroundColor: _isLight ? const Color(0xFF1E3C4F) : const Color(0xFF2C5364),\n        onPressed: _openSettings,"
c = c.replace(old_fab, new_fab)

# Also handle if already partially changed
old_fab2 = "backgroundColor: _isLight ? const Color(0xFF1E3C4F) : _cardBg(),\n        onPressed: _openSettings,"
c = c.replace(old_fab2, new_fab)

with open("lib/main.dart", "w") as f:
    f.write(c)

# Verify
print("FAB fixed:", "backgroundColor: _isLight ? const Color(0xFF1E3C4F) : const Color(0xFF2C5364),\n        onPressed: _openSettings," in c)

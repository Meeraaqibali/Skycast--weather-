with open("lib/main.dart") as f:
    c = f.read()

# Reduce the bottom padding from 40 to 20
c = c.replace(
    "                _lifeCard(),\n                const SizedBox(height: 40),",
    "                _lifeCard(),\n                const SizedBox(height: 20),"
)

# Also reduce card padding slightly (from 20 to 16)
c = c.replace(
    "  Widget _card({required Widget child}) => Container(\n    padding: const EdgeInsets.all(20),",
    "  Widget _card({required Widget child}) => Container(\n    padding: const EdgeInsets.all(16),"
)

# Reduce spacing between cards in main column
c = c.replace(
    "                _searchBar(),\n                const SizedBox(height: 12),\n                _mainCard(),\n                const SizedBox(height: 12),\n                _hourlyCard(),\n                const SizedBox(height: 12),\n                _dailyCard(),\n                const SizedBox(height: 12),\n                _extrasCard(),\n                const SizedBox(height: 12),\n                _lifeCard(),\n                const SizedBox(height: 20),",
    "                _searchBar(),\n                const SizedBox(height: 10),\n                _mainCard(),\n                const SizedBox(height: 10),\n                _hourlyCard(),\n                const SizedBox(height: 10),\n                _dailyCard(),\n                const SizedBox(height: 10),\n                _extrasCard(),\n                const SizedBox(height: 10),\n                _lifeCard(),\n                const SizedBox(height: 16),"
)

with open("lib/main.dart", "w") as f:
    f.write(c)

print("=== CHECK ===")
print("Bottom space 20:", "const SizedBox(height: 20)," in c or "const SizedBox(height: 16)," in c)
print("Card padding 16:", "padding: const EdgeInsets.all(16)," in c)
print("Card gap 10:", c.count("const SizedBox(height: 10),"))

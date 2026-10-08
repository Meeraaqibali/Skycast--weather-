with open("lib/main.dart") as f:
    c = f.read()

# Fix the button text
old = "child: Text(_allDays ? '▲  ${T('daily').split(' ').first}' : '▼  More',\n            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),"
new = "child: Text(_allDays ? '▲  Less' : '▼  More',\n            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),"

if old in c:
    c = c.replace(old, new)
    print("Fixed button text")
else:
    print("Pattern not found - showing what's there:")
    # Find the line
    for line in c.split('\n'):
        if '▲' in line:
            print("  ", line)

with open("lib/main.dart", "w") as f:
    f.write(c)

print("Success:", "'▲  Less'" in c)

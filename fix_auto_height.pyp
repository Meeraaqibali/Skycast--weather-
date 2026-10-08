with open("lib/main.dart") as f:
    c = f.read()

# Find and replace the whole AnimatedContainer block with AnimatedSize + Column
start = c.find("        AnimatedContainer(")
if start == -1:
    print("[!] AnimatedContainer not found")
    exit(1)

# Find the end — look for the closing at the same indentation
end = c.find("        ),", start)
# Find the next "        )," after the itemBuilder content (approx)
# Actually find the closing of AnimatedContainer by bracket matching
depth = 0
i = start
started = False
while i < len(c):
    if c[i] == '(':
        depth += 1
        started = True
    elif c[i] == ')':
        depth -= 1
        if depth == 0 and started:
            end = i + 1
            break
    i += 1

new_block = '''        AnimatedSize(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < days.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == days.length - 1 ? 0 : 8),
                  child: GestureDetector(
                    onTap: () => _showDayDetail(days[i], i == 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _itemBg(),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _cardBorder()),
                      ),
                      child: Row(children: [
                        SizedBox(width: 60, child: Text(
                          i == 0 ? T('today') : _day(days[i]['date']),
                          style: TextStyle(color: _txt(), fontSize: 14, fontWeight: FontWeight.w500))),
                        Text(_icon(days[i]['code']), style: const TextStyle(fontSize: 20)),
                        const Spacer(),
                        Text('${_fmtT((days[i]['max'] as num).toDouble())} / ${_fmtT((days[i]['min'] as num).toDouble())}',
                          style: TextStyle(color: _muted(), fontSize: 14)),
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right, size: 16, color: _faint()),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
        )'''

c = c[:start] + new_block + c[end:]
print("[✓] Replaced with AnimatedSize + Column (measures real content)")

with open("lib/main.dart", "w") as f:
    f.write(c)

print()
print("AnimatedSize count:", c.count("AnimatedSize"))
print("AnimatedContainer gone:", "AnimatedContainer(" not in c or c.count("AnimatedContainer") == 0)
print()
print("Braces:", c.count('{'), '=', c.count('}'))
print("Parens:", c.count('('), '=', c.count(')'))
print("Balanced:", c.count('{') == c.count('}') and c.count('(') == c.count(')'))

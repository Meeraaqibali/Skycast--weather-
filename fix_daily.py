with open("lib/main.dart") as f:
    c = f.read()

# Match the actual daily code
old = """      ...days.asMap().entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: _isLight ? Colors.white : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.15))),
        child: Row(children: [
          SizedBox(width: 60, child: Text(e.key == 0 ? T('today') : _day(e.value['date']),
            style: TextStyle(color: _txt(), fontSize: 14, fontWeight: FontWeight.w500))),
          Text(_icon(e.value['code']), style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text('${_fmtT((e.value['max'] as num).toDouble())} / ${_fmtT((e.value['min'] as num).toDouble())}',
            style: TextStyle(color: _muted(), fontSize: 14)),
        ]),
      )),"""

new = """      ...days.asMap().entries.map((e) => GestureDetector(
        onTap: () => _showDayDetail(e.value, e.key == 0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: _isLight ? Colors.white : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.15))),
          child: Row(children: [
            SizedBox(width: 60, child: Text(e.key == 0 ? T('today') : _day(e.value['date']),
              style: TextStyle(color: _txt(), fontSize: 14, fontWeight: FontWeight.w500))),
            Text(_icon(e.value['code']), style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text('${_fmtT((e.value['max'] as num).toDouble())} / ${_fmtT((e.value['min'] as num).toDouble())}',
              style: TextStyle(color: _muted(), fontSize: 14)),
          ]),
        ),
      )),"""

if old in c:
    c = c.replace(old, new)
    print("Daily wrapped successfully")
else:
    print("Still not matching - let me try a different approach")
    # Try simpler approach: find the line and modify
    lines = c.split('\n')
    for i, line in enumerate(lines):
        if 'days.asMap().entries.map((e) => Container(' in line:
            lines[i] = line.replace('Container(', 'GestureDetector(\n        onTap: () => _showDayDetail(e.value, e.key == 0),\n        child: Container(')
            # Find where this Container ends — need to add closing paren
            depth = 0
            started = False
            for j in range(i, min(i + 30, len(lines))):
                for ch in lines[j]:
                    if ch == '(':
                        depth += 1
                        started = True
                    elif ch == ')':
                        depth -= 1
                if started and depth == 0 and j > i:
                    lines[j] = lines[j] + ')'
                    break
            c = '\n'.join(lines)
            print(f"Modified line {i+1}")
            break

with open("lib/main.dart", "w") as f:
    f.write(c)

print()
print("Daily tap:", "_showDayDetail(e.value," in c)

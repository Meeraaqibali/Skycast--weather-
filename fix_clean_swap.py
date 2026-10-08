with open("lib/main.dart") as f:
    c = f.read()

# 1. Replace _onExploreTap with simple version — no fade
old_tap = c.find("  void _onExploreTap(String key) async {")
if old_tap != -1:
    old_tap_end = c.find("\n  }\n", old_tap) + 4
    new_tap = '''  void _onExploreTap(String key) async {
    if (key == _currentType) return;
    if (_isTransitioning) return;
    _isTransitioning = true;

    // Scroll to top first
    if (_scrollCtrl.hasClients && _scrollCtrl.offset > 0) {
      await _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }

    // Instant swap — no fade, no overlap
    if (mounted) {
      setState(() {
        _currentType = key;
        _content = _parseContent(widget.getContent(key));
      });
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _isTransitioning = false;
  }
'''
    c = c[:old_tap] + new_tap + c[old_tap_end:]
    print("Replaced _onExploreTap")

# 2. Remove _contentOpacity field
c = c.replace("  double _contentOpacity = 1.0;\n", "")

# 3. Find AnimatedOpacity in build and remove it
start = c.find("AnimatedOpacity(")
if start != -1:
    # Find the end (matching paren)
    depth = 0
    i = start
    while i < len(c):
        if c[i] == '(':
            depth += 1
        elif c[i] == ')':
            depth -= 1
            if depth == 0:
                end = i + 1
                break
        i += 1
    
    # Extract the child parameter content
    block = c[start:end]
    # Find "child: Column("
    child_start = block.find("child: Column(")
    if child_start != -1:
        # Extract column's children starting after "children: ["
        children_start = block.find("children: [", child_start)
        if children_start != -1:
            # Find the matching ]
            cdepth = 0
            j = children_start + len("children: [")
            while j < len(block):
                if block[j] == '[':
                    cdepth += 1
                elif block[j] == ']':
                    if cdepth == 0:
                        children_end = j
                        break
                    cdepth -= 1
                j += 1
            
            children = block[children_start + len("children: ["):children_end]
            
            # Replace the entire AnimatedOpacity block with just Column
            replacement = "Column(\n                    crossAxisAlignment: CrossAxisAlignment.start,\n                    children: [" + children + "],\n                  ),"
            c = c[:start] + replacement + c[end:]
            print("Removed AnimatedOpacity wrapper")

with open("lib/main.dart", "w") as f:
    f.write(c)

print()
print("=== CHECK ===")
print("AnimatedOpacity removed:", "AnimatedOpacity" not in c)
print("_contentOpacity removed:", "_contentOpacity" not in c)
print("Simple _onExploreTap:", "if (_isTransitioning) return;" in c and "Instant swap" in c)

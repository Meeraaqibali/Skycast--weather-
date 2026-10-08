with open("lib/main.dart") as f:
    c = f.read()

# ============================================================
# 1. Make daily items tappable — check if already wired
# ============================================================
if "onTap: () => _showDayDetail" not in c:
    # Wrap daily items in GestureDetector
    old_d = "      ...days.asMap().entries.map((e) => Container(\n        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),"
    new_d = "      ...days.asMap().entries.map((e) => GestureDetector(\n        onTap: () => _showDayDetail(e.value, e.key == 0),\n        child: Container(\n          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),"
    if old_d in c:
        c = c.replace(old_d, new_d)
        print("Daily items wrapped with GestureDetector")
    else:
        print("WARN: daily items pattern not found")

# ============================================================
# 2. Add weather prediction description to _showDayDetail
# ============================================================
# Find _showDayDetail function
start = c.find("  void _showDayDetail(")
end = c.find("\n  }\n", start)
if end != -1:
    end += 5

if start != -1 and end != -1:
    new_day_detail = '''  String _dayPrediction(int code) {
    if (code == 0) return 'Clear sunny day. Perfect for outdoor activities.';
    if (code == 1) return 'Mostly clear. Great weather to be outside.';
    if (code == 2) return 'Partly cloudy with some sunshine.';
    if (code == 3) return 'Overcast skies. Might feel a bit gloomy.';
    if (code == 45 || code == 48) return 'Foggy conditions. Drive carefully.';
    if (code >= 51 && code <= 55) return 'Light drizzle expected. Carry an umbrella.';
    if (code >= 61 && code <= 65) return 'Rain expected. Bring an umbrella and wear waterproof shoes.';
    if (code >= 71 && code <= 75) return 'Snow expected. Dress warmly and drive carefully.';
    if (code >= 95) return 'Thunderstorms expected. Stay indoors if possible.';
    return 'Mixed conditions throughout the day.';
  }

  void _showDayDetail(Map<String, dynamic> d, bool isToday) {
    final code = d['code'] as int;
    final max = (d['max'] as num).toDouble();
    final min = (d['min'] as num).toDouble();
    final date = DateTime.parse(d['date']);
    _smoothBottomSheet(
      context: context,
      backgroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(_icon(code), style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isToday ? T('today') : _day(d['date']),
                style: TextStyle(color: _txt(), fontSize: 22, fontWeight: FontWeight.w600)),
              Text('${date.day}/${date.month}/${date.year}',
                style: TextStyle(color: _muted(), fontSize: 13)),
              Text(_desc(code), style: TextStyle(color: _muted(), fontSize: 14)),
            ])),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _itemBg(),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder()),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, color: _muted(), size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(_dayPrediction(code),
                style: TextStyle(color: _txt(), fontSize: 13, height: 1.5))),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _itemBg(),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder()),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('High', style: TextStyle(color: _muted(), fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(_fmtT(max), style: TextStyle(color: _txt(), fontSize: 32, fontWeight: FontWeight.w300, height: 1)),
              ]),
            )),
            const SizedBox(width: 12),
            Expanded(child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _itemBg(),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder()),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Low', style: TextStyle(color: _muted(), fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(_fmtT(min), style: TextStyle(color: _txt(), fontSize: 32, fontWeight: FontWeight.w300, height: 1)),
              ]),
            )),
          ]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                foregroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0),
              child: Text(T('done'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            )),
        ]),
      ),
    );
  }
'''
    c = c[:start] + new_day_detail + c[end:]
    print("Rewrote _showDayDetail with weather prediction")
else:
    print("WARN: _showDayDetail not found")

# ============================================================
# 3. Make Done button in Settings more visible
# ============================================================
# The Done button in settings uses old style — make it solid black/white
old_done = """                    backgroundColor: _theme == 'light' ? const Color(0xFF1A1A1A) : Colors.white,
                    foregroundColor: _theme == 'light' ? Colors.white : const Color(0xFF1A1A1A),"""
new_done = """                    backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                    foregroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                    elevation: 0,"""
if old_done in c:
    c = c.replace(old_done, new_done)
    print("Fixed Done button in settings")
else:
    print("WARN: Done button pattern not found")

# Also add solid shape to Done button
c = c.replace(
    "shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),\n                  child: Text(T('done'), style: const TextStyle(\n                    fontWeight: FontWeight.w600, fontSize: 16)),",
    "shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),\n                    minimumSize: const Size(double.infinity, 52)),\n                  child: Text(T('done'), style: const TextStyle(\n                    fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.5)),"
)

with open("lib/main.dart", "w") as f:
    f.write(c)

# Verify
print()
print("=== CHECK ===")
print("Daily tap wired:", "onTap: () => _showDayDetail" in c)
print("_dayPrediction added:", "_dayPrediction" in c)
print("Done button solid:", "backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF)" in c)

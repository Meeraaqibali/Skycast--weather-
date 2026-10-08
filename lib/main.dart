import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCast Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90E2), brightness: Brightness.dark)),
      home: const WeatherHome(),
    );
  }
}

const Map<String, Map<String, String>> TR = {
  'en': {
    'search':'Search city...','go':'Go','wind':'Wind','humidity':'Humidity','feels':'Feels Like',
    'hourly':'Hourly Forecast','daily':'7-Day Forecast','details':'More Details','life':'Life Index',
    'settings':'App Settings','theme':'Theme','temp_unit':'Temperature','wind_unit':'Wind Speed',
    'time_format':'Time Format','language':'Language','done':'Done',
    'auto':'Auto','dark':'Dark','light':'Light','now':'Now','today':'Today',
    'precip':'Precipitation','aqi':'Air Quality','uv':'UV Index','sun':'Sun',
    'sunrise':'Sunrise','sunset':'Sunset','chance':'chance',
    'outdoor':'Outdoor Activity','clothing':'Clothing Advice','cold':'Cold & Flu Risk','drive':'Driving Conditions',
    'great_out':'Nice weather! Great day outside.','bad_out':'Severe weather. Stay indoors.',
    'light_cloth':'Wear light, breathable clothing.','ok_cloth':'Comfortable clothing recommended.',
    'warm_cloth':'Wear a jacket or sweater.','high_cold':'Higher cold risk. Stay warm.',
    'low_cold':'Stable weather, low risk.','bad_drive':'Wet roads or low visibility.',
    'ok_drive':'Excellent road conditions.','about':'About this metric','context':'Current Context',
    'explore':'Explore Other Details','weather_metrics':'Weather Metrics','lifestyle':'Lifestyle Index',
    'light_breeze':'Light breeze','strong_winds':'Strong winds','muggy':'Muggy','comfortable':'Comfortable',
    'low':'Low','moderate':'Moderate','high':'High','very_high':'Very High',
    'good':'Good','fair':'Fair','poor':'Poor','dry':'Currently dry','raining':'It is currently raining.',
  },
  'ur': {
    'search':'شہر تلاش کریں...','go':'جائیں','wind':'ہوا','humidity':'نمی','feels':'محسوس',
    'hourly':'گھنٹہ وار پیش گوئی','daily':'7 دن کی پیش گوئی','details':'مزید تفصیلات','life':'لائف انڈیکس',
    'settings':'ترتیبات','theme':'تھیم','temp_unit':'درجہ حرارت','wind_unit':'ہوا کی رفتار',
    'time_format':'وقت کی ترتیب','language':'زبان','done':'مکمل',
    'auto':'خودکار','dark':'ڈارک','light':'لائٹ','now':'ابھی','today':'آج',
    'precip':'بارش','aqi':'فضائی معیار','uv':'یووی انڈیکس','sun':'سورج',
    'sunrise':'طلوع','sunset':'غروب','chance':'امکان',
    'outdoor':'بیرونی سرگرمی','clothing':'لباس کا مشورہ','cold':'زکام اور فلو','drive':'ڈرائیونگ',
    'great_out':'اچھا موسم! باہر جائیں۔','bad_out':'شدید موسم۔ گھر میں رہیں۔',
    'light_cloth':'ہلکے کپڑے پہنیں۔','ok_cloth':'آرام دہ کپڑے بہترین ہیں۔',
    'warm_cloth':'جیکٹ یا سویٹر پہنیں۔','high_cold':'زکام کا زیادہ خطرہ۔ گرم رہیں۔',
    'low_cold':'زکام کا خطرہ کم ہے۔','bad_drive':'گیلی سڑکیں، احتیاط کریں۔',
    'ok_drive':'بہترین سڑک کے حالات۔','about':'اس پیمائش کے بارے میں','context':'موجودہ سیاق',
    'explore':'مزید تفصیلات','weather_metrics':'موسمی پیمائش','lifestyle':'لائف اسٹائل',
    'light_breeze':'ہلکی ہوا','strong_winds':'تیز ہوا','muggy':'مرطوب','comfortable':'آرام دہ',
    'low':'کم','moderate':'معتدل','high':'زیادہ','very_high':'بہت زیادہ',
    'good':'اچھا','fair':'منصفانہ','poor':'خراب','dry':'فی الحال خشک','raining':'بارش ہو رہی ہے',
  },
  'sd': {
    'search':'شهر ڳوليو...','go':'وڃو','wind':'هوا','humidity':'نمي','feels':'محسوس',
    'hourly':'ڪلاڪوار اڳڪٿي','daily':'7 ڏينهن جي اڳڪٿي','details':'وڌيڪ تفصيل','life':'لائف انڊيڪس',
    'settings':'سيٽنگون','theme':'ٿيم','temp_unit':'درجه حرارت','wind_unit':'هوا جي رفتار',
    'time_format':'وقت جي ترتيب','language':'ٻولي','done':'مڪمل',
    'auto':'خودڪار','dark':'ڊارڪ','light':'لائيٽ','now':'هاڻي','today':'اڄ',
    'precip':'برسات','aqi':'فضائي معيار','uv':'يووي انڊيڪس','sun':'سج',
    'sunrise':'سج اڀرڻ','sunset':'سج لهڻ','chance':'امڪان',
    'outdoor':'ٻاهرين سرگرمي','clothing':'ڪپڙن جو مشورو','cold':'زڪام ۽ فلو','drive':'ڊرائيونگ',
    'great_out':'سٺو موسم! ٻاهر وڃو.','bad_out':'شديد موسم. گهر ۾ رهو.',
    'light_cloth':'هلڪا ڪپڙا پائو.','ok_cloth':'آرامده ڪپڙا بهترين آهن.',
    'warm_cloth':'جيڪٽ يا سويٽر پائو.','high_cold':'زڪام جو وڌيڪ خطرو. گرم رهو.',
    'low_cold':'زڪام جو خطرو گهٽ آهي.','bad_drive':'گلي روڊ، احتياط ڪريو.',
    'ok_drive':'بهترين روڊ جا حالتون.','about':'هن ماپ بابت','context':'موجوده حوالي',
    'explore':'وڌيڪ تفصيل','weather_metrics':'موسمي ماپ','lifestyle':'لائف اسٽائل',
    'light_breeze':'هلڪي هوا','strong_winds':'تيز هوا','muggy':'مرطوب','comfortable':'آرامده',
    'low':'گهٽ','moderate':'وچولو','high':'وڌيڪ','very_high':'تمام وڌيڪ',
    'good':'سٺو','fair':'منصفانه','poor':'خراب','dry':'في الحال خشڪ','raining':'مينهن پيو پوي',
  },
  'es': {
    'search':'Buscar ciudad...','go':'Ir','wind':'Viento','humidity':'Humedad','feels':'Sensación',
    'hourly':'Por Hora','daily':'7 Días','details':'Más Detalles','life':'Índice de Vida',
    'settings':'Ajustes','theme':'Tema','temp_unit':'Temperatura','wind_unit':'Viento',
    'time_format':'Hora','language':'Idioma','done':'Listo',
    'auto':'Auto','dark':'Oscuro','light':'Claro','now':'Ahora','today':'Hoy',
    'precip':'Precipitación','aqi':'Calidad Aire','uv':'Índice UV','sun':'Sol',
    'sunrise':'Amanecer','sunset':'Atardecer','chance':'probabilidad',
    'outdoor':'Actividad Exterior','clothing':'Consejo de Ropa','cold':'Riesgo Resfriado','drive':'Conducción',
    'great_out':'¡Buen clima! Día perfecto.','bad_out':'Clima severo. Quédese en casa.',
    'light_cloth':'Use ropa ligera.','ok_cloth':'Ropa cómoda recomendada.',
    'warm_cloth':'Use chaqueta o suéter.','high_cold':'Mayor riesgo de resfriado.',
    'low_cold':'Bajo riesgo de resfriado.','bad_drive':'Carreteras mojadas.',
    'ok_drive':'Excelentes condiciones.','about':'Sobre esto','context':'Contexto',
    'explore':'Explorar Detalles','weather_metrics':'Métricas','lifestyle':'Estilo de Vida',
    'light_breeze':'Brisa ligera','strong_winds':'Vientos fuertes','muggy':'Húmedo','comfortable':'Cómodo',
    'low':'Bajo','moderate':'Moderado','high':'Alto','very_high':'Muy Alto',
    'good':'Buena','fair':'Aceptable','poor':'Mala','dry':'Seco actualmente','raining':'Está lloviendo',
  },
};

const List<String> DAYS_EN = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
const List<String> DAYS_UR = ['اتوار','پیر','منگل','بدھ','جمعرات','جمعہ','ہفتہ'];
const List<String> DAYS_SD = ['آچر','سومر','اڱارو','اربع','خميس','جمع','ڇنڇر'];
const List<String> DAYS_ES = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'];

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});
  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  String _lang = 'en', _theme = 'auto', _unit = 'C', _windUnit = 'kmh', _timeFmt = '12h';
  String _city = 'Karachi', _country = 'Pakistan';
  double _temp = 0, _feels = 0, _wind = 0, _precip = 0, _uv = 0;
  int _humidity = 0, _wcode = 0, _precipChance = 0, _aqi = 0;
  String _sunrise = '', _sunset = '';
  bool _loading = true, _allDays = false;
  List<dynamic> _hourly = [], _daily = [];

  late AnimationController _animCtrl;
  late Animation<double> _anim;

  String T(String k) => TR[_lang]?[k] ?? TR['en']?[k] ?? k;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _loadSettings();
    _fetch('Karachi');
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _lang = p.getString('lang') ?? 'en';
      _theme = p.getString('theme') ?? 'auto';
      _unit = p.getString('unit') ?? 'C';
      _windUnit = p.getString('windUnit') ?? 'kmh';
      _timeFmt = p.getString('timeFmt') ?? '12h';
    });
  }

  Future<void> _saveSettings() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', _lang);
    await p.setString('theme', _theme);
    await p.setString('unit', _unit);
    await p.setString('windUnit', _windUnit);
    await p.setString('timeFmt', _timeFmt);
    if (mounted) setState(() {});
  }

  Future<void> _fetch(String city) async {
    setState(() => _loading = true);
    try {
      final geo = await http.get(Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=10&language=en&format=json')).timeout(const Duration(seconds: 10));
      final gd = json.decode(geo.body);
      if (gd['results'] == null) {
        setState(() { _city = 'Not found'; _loading = false; });
        return;
      }
      final pk = (gd['results'] as List).firstWhere(
        (r) => r['country_code'] == 'PK', orElse: () => gd['results'][0]);
      final lat = pk['latitude'], lon = pk['longitude'];

      final wr = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,precipitation&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max&timezone=auto')).timeout(const Duration(seconds: 10));
      final wd = json.decode(wr.body);
      final c = wd['current'];

      final ar = await http.get(Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=european_aqi&timezone=auto')).timeout(const Duration(seconds: 10));
      final ad = json.decode(ar.body);

      setState(() {
        _city = pk['name'] ?? city;
        _country = pk['country'] ?? '';
        _temp = (c['temperature_2m'] as num).toDouble();
        _feels = (c['apparent_temperature'] as num).toDouble();
        _humidity = (c['relative_humidity_2m'] as num).toInt();
        _wind = (c['wind_speed_10m'] as num).toDouble();
        _precip = (c['precipitation'] as num).toDouble();
        _wcode = (c['weather_code'] as num).toInt();
        _aqi = ((ad['current']?['european_aqi'] ?? 0) as num).toInt();
        _uv = (wd['daily']['uv_index_max'][0] as num).toDouble();
        _precipChance = (wd['daily']['precipitation_probability_max'][0] as num).toInt();
        _sunrise = wd['daily']['sunrise'][0];
        _sunset = wd['daily']['sunset'][0];
        _hourly = List.generate(wd['hourly']['time'].length, (i) => {
          'time': wd['hourly']['time'][i],
          'temp': wd['hourly']['temperature_2m'][i],
          'code': wd['hourly']['weather_code'][i],
        });
        _daily = List.generate(wd['daily']['time'].length, (i) => {
          'date': wd['daily']['time'][i],
          'max': wd['daily']['temperature_2m_max'][i],
          'min': wd['daily']['temperature_2m_min'][i],
          'code': wd['daily']['weather_code'][i],
        });
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _city = e.toString().contains('TimeoutException') ? 'Request timed out' : 'Connection error';
        _country = '';
        _loading = false;
      });
    }
  }

  String _icon(int c) {
    if (c <= 1) return '☀️';
    if (c <= 3 || c == 45 || c == 48) return '☁️';
    if (c >= 51 && c <= 65) return '🌧️';
    if (c >= 71 && c <= 75) return '❄️';
    if (c >= 95) return '⛈️';
    return '☀️';
  }

  String _desc(int c) {
    const m = {0:'Clear sky',1:'Mainly clear',2:'Partly cloudy',3:'Overcast',45:'Fog',48:'Rime fog',
      51:'Light drizzle',53:'Drizzle',55:'Dense drizzle',61:'Slight rain',63:'Rain',65:'Heavy rain',
      71:'Slight snow',73:'Snow',75:'Heavy snow',95:'Thunderstorm',96:'Storm with hail',99:'Heavy storm'};
    return m[c] ?? 'Unknown';
  }

  // Weather-specific animation widget
  Widget _animatedIcon(int code, double size) {
    // Sunny = spin, Cloud = jiggle, Rain = bob, Storm = flash
    if (code <= 1) {
      return AnimatedBuilder(
        animation: _anim,
        builder: (c, ch) => Transform.rotate(angle: _anim.value * 2 * math.pi, child: ch),
        child: Text(_icon(code), style: TextStyle(fontSize: size)),
      );
    } else if (code >= 51 && code <= 65) {
      // Rain - bob up and down
      return AnimatedBuilder(
        animation: _anim,
        builder: (c, ch) => Transform.translate(
          offset: Offset(0, math.sin(_anim.value * 2 * math.pi) * 8),
          child: ch),
        child: Text(_icon(code), style: TextStyle(fontSize: size)),
      );
    } else if (code >= 95) {
      // Storm - flash
      return AnimatedBuilder(
        animation: _anim,
        builder: (c, ch) => Opacity(
          opacity: 0.6 + (_anim.value > 0.5 ? 0.4 : 0),
          child: ch),
        child: Text(_icon(code), style: TextStyle(fontSize: size)),
      );
    } else {
      // Cloud - gentle scale pulse
      return AnimatedBuilder(
        animation: _anim,
        builder: (c, ch) => Transform.scale(
          scale: 1 + math.sin(_anim.value * 2 * math.pi) * 0.05,
          child: ch),
        child: Text(_icon(code), style: TextStyle(fontSize: size)),
      );
    }
  }

  String _fmtT(double t) => _unit == 'C' ? '${t.round()}°' : '${(t*9/5+32).round()}°';
  String _fmtW(double w) => _windUnit == 'kmh' ? '${w.round()} km/h' : '${(w*0.621).round()} mph';
  String _fmtTime(String iso) {
    final d = DateTime.parse(iso);
    if (_timeFmt == '24h') return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2,'0')} ${d.hour >= 12 ? "PM" : "AM"}';
  }
  String _fmtHour(String iso) => '${DateTime.parse(iso).hour.toString().padLeft(2,'0')}:00';
  List<String> _days() => _lang == 'ur' ? DAYS_UR : _lang == 'sd' ? DAYS_SD : _lang == 'es' ? DAYS_ES : DAYS_EN;
  String _day(String iso) => _days()[DateTime.parse(iso).weekday % 7];

  bool get _isLight {
    if (_theme == "light") return true;
    if (_theme == "dark") return false;
    final h = DateTime.now().hour;
    return h >= 6 && h < 18;
  }

  // ==== BLACK & WHITE THEME ====
  Color _bg1() => _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color _bg2() => _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color _txt() => _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  Color _muted() => _isLight ? const Color(0xFF555555) : const Color(0xFFAAAAAA);
  Color _faint() => _isLight ? const Color(0xFF888888) : const Color(0xFF777777);
  Color _cardBg() => _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  Color _cardBorder() => _isLight ? const Color(0xFFDDDDDD) : const Color(0xFF333333);
  Color _divider() => _isLight ? const Color(0xFFDDDDDD) : const Color(0xFF333333);
  Color _itemBg() => _isLight ? const Color(0xFFF5F5F5) : const Color(0xFF252525);

  String _aqiCategory() {
    if (_aqi <= 20) return T('good');
    if (_aqi <= 40) return T('fair');
    if (_aqi <= 60) return T('moderate');
    return T('poor');
  }
  String _uvCategory() {
    if (_uv <= 2) return T('low');
    if (_uv <= 5) return T('moderate');
    if (_uv <= 7) return T('high');
    return T('very_high');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1(),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_bg1(), _bg2()])),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _fetch(_city),
            color: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _searchBar(),
                const SizedBox(height: 12),
                _mainCard(),
                const SizedBox(height: 12),
                _hourlyCard(),
                const SizedBox(height: 12),
                _dailyCard(),
                const SizedBox(height: 12),
                _extrasCard(),
                const SizedBox(height: 12),
                _lifeCard(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
        onPressed: _openSettings,
        child: Icon(Icons.settings, color: Colors.white),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _cardBg(),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: _cardBorder()),
    ),
    child: child,
  );

  Widget _searchBar() => Row(children: [
    Expanded(child: TextField(
      controller: _ctrl, style: TextStyle(color: _isLight ? const Color(0xFF1A1A1A) : _txt()),
      decoration: InputDecoration(
        hintText: T('search'), hintStyle: TextStyle(color: _faint()),
        filled: true, fillColor: Colors.white.withOpacity(0.13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: _cardBorder())),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      onSubmitted: (v) { if (v.trim().isNotEmpty) _fetch(v.trim()); },
    )),
    const SizedBox(width: 8),
    ElevatedButton(
      onPressed: () { final v = _ctrl.text.trim(); if (v.isNotEmpty) _fetch(v); },
      style: ElevatedButton.styleFrom(
        backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0),
      child: Text(T('go')),
    ),
  ]);

  Widget _mainCard() => _card(child: _loading
    ? Center(child: Padding(padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 50, height: 50,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 4)),
          const SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: _txt(), fontSize: 14)),
        ])))
    : Column(children: [
        Text('$_city, $_country'.toUpperCase(),
          style: TextStyle(color: _muted(), fontSize: 13,
            letterSpacing: 1.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        _animatedIcon(_wcode, 80),
        const SizedBox(height: 10),
        Text(_fmtT(_temp), style: TextStyle(color: _txt(), fontSize: 90,
          fontWeight: FontWeight.w200, height: 1)),
        Text(_desc(_wcode), style: TextStyle(color: _txt(), fontSize: 18)),
        const SizedBox(height: 20),
        Divider(color: _divider()),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _det(T('wind'), _fmtW(_wind)),
          _det(T('humidity'), '$_humidity%'),
          _det(T('feels'), _fmtT(_feels)),
        ]),
      ]));

  Widget _det(String l, String v) => Column(children: [
    Text(l.toUpperCase(), style: TextStyle(color: _faint(), fontSize: 10, letterSpacing: 1.2)),
    const SizedBox(height: 4),
    Text(v, style: TextStyle(color: _txt(), fontSize: 15, fontWeight: FontWeight.w500)),
  ]);

  Widget _hourlyCard() {
    final now = DateTime.now();
    final up = _hourly.where((h) => DateTime.parse(h['time']).isAfter(now)).take(24).toList();
    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(T('hourly').toUpperCase(), style: TextStyle(color: _muted(),
        fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      SizedBox(height: 100, child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: up.length,
        itemBuilder: (c, i) {
          final h = up[i];
          return GestureDetector(
            onTap: () => _showHourDetail(h),
            child: Container(
              width: 72, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _isLight ? const Color(0xFFF0F4F8) : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.15))),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text(i == 0 ? T('now') : _fmtHour(h['time']),
                  style: TextStyle(color: _muted(), fontSize: 12)),
                Text(_icon(h['code']), style: const TextStyle(fontSize: 24)),
                Text(_fmtT((h['temp'] as num).toDouble()),
                  style: TextStyle(color: _txt(), fontSize: 14, fontWeight: FontWeight.w500)),
              ]),
            ),
          );
        },
      )),
    ]));
  }

  Widget _dailyCard() {
    final days = _allDays ? _daily : _daily.take(3).toList();
    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(T('daily').toUpperCase(), style: TextStyle(color: _muted(),
        fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      ...days.asMap().entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: _isLight ? const Color(0xFFF0F4F8) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.15))),
        child: Row(children: [
          SizedBox(width: 60, child: Text(e.key == 0 ? T('today') : _day(e.value['date']),
            style: TextStyle(color: _txt(), fontSize: 14, fontWeight: FontWeight.w500))),
          Text(_icon(e.value['code']), style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text('${_fmtT((e.value['max'] as num).toDouble())} / ${_fmtT((e.value['min'] as num).toDouble())}',
            style: TextStyle(color: _txt().withOpacity(0.85), fontSize: 14)),
        ]),
      )),
      const SizedBox(height: 4),
      // BIG More/Less button
      SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: () => setState(() => _allDays = !_allDays),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
        foregroundColor: Colors.white,
            elevation: 0, shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
          child: Text(_allDays ? '▲  ${T('daily').split(' ').first}' : '▼  More',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
      ),
    ]));
  }

  Widget _extrasCard() => _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(T('details').toUpperCase(), style: TextStyle(color: _muted(),
      fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
    const SizedBox(height: 12),
    GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.35,
      children: [
        _ex('🌧️', T('precip'), '${_precip.round()} mm', '$_precipChance% ${T('chance')}',
          () => _openDetail('precip')),
        _ex('💨', T('wind'), _fmtW(_wind), _wind > 20 ? T('strong_winds') : T('light_breeze'),
          () => _openDetail('wind')),
        _ex('🌍', T('aqi'), '$_aqi', _aqiCategory(), () => _openDetail('aqi')),
        _ex('☀️', T('uv'), '${_uv.round()}', _uvCategory(), () => _openDetail('uv')),
        _ex('💧', T('humidity'), '$_humidity%', _humidity > 60 ? T('muggy') : T('comfortable'),
          () => _openDetail('humidity')),
        _ex('🌅', T('sun'), _fmtTime(_sunrise), _fmtTime(_sunset), () => _openDetail('sun')),
      ],
    ),
  ]));

  Widget _ex(String emoji, String l, String v, String sub, VoidCallback onTap) => _TapCard(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _isLight ? const Color(0xFFF0F4F8) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('$emoji ${l.toUpperCase()}',
            style: TextStyle(color: _faint(), fontSize: 10,
              letterSpacing: 1, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis)),
          Icon(Icons.chevron_right, size: 14, color: _faint()),
        ]),
        const SizedBox(height: 6),
        Text(v, style: TextStyle(color: _txt(), fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(color: _muted(), fontSize: 11),
          overflow: TextOverflow.ellipsis),
      ]),
    ),
  );

  Widget _lifeCard() {
    final isBadOut = _wcode >= 51 || _temp > 38 || _temp < 5;
    final isBadDrv = (_wcode >= 45 && _wcode <= 48) || _wcode >= 61;
    final isHighCold = _feels < 15 || _humidity > 80;
    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('🌿 ${T('life').toUpperCase()}', style: TextStyle(color: _muted(),
        fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      _life('🏃', isBadOut ? T('bad_out') : T('great_out'), () => _openDetail('outdoor')),
      _life('👕', _temp > 30 ? T('light_cloth') : _temp > 20 ? T('ok_cloth') : T('warm_cloth'),
        () => _openDetail('clothing')),
      _life('💊', isHighCold ? T('high_cold') : T('low_cold'), () => _openDetail('cold')),
      _life('🚗', isBadDrv ? T('bad_drive') : T('ok_drive'), () => _openDetail('drive')),
    ]));
  }

  Widget _life(String emoji, String text, VoidCallback onTap) => _TapCard(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _isLight ? const Color(0xFFF0F4F8) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.15))),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: _txt(), fontSize: 13))),
        Icon(Icons.chevron_right, size: 18, color: _faint()),
      ]),
    ),
  );

  Future<T?> _smoothBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: backgroundColor,
      shape: shape,
      isScrollControlled: isScrollControlled,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 350),
      ),
      builder: builder,
    );
  }

  void _showHourDetail(Map<String, dynamic> h) {
    final code = h['code'] as int;
    final temp = (h['temp'] as num).toDouble();
    _smoothBottomSheet(
      context: context,
      backgroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(_icon(code), style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_fmtHour(h['time']), style: TextStyle(color: _txt(), fontSize: 22, fontWeight: FontWeight.w600)),
              Text(_desc(code), style: TextStyle(color: _muted(), fontSize: 14)),
            ])),
          ]),
          const SizedBox(height: 24),
          Text(_fmtT(temp), style: TextStyle(color: _txt(), fontSize: 48, fontWeight: FontWeight.w200, height: 1)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(T('done'), style: const TextStyle(fontWeight: FontWeight.w600)),
            )),
        ]),
      ),
    );
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
            Text(_icon(code), style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isToday ? T('today') : _day(d['date']), style: TextStyle(color: _txt(), fontSize: 22, fontWeight: FontWeight.w600)),
              Text('${date.day}/${date.month}/${date.year}', style: TextStyle(color: _muted(), fontSize: 13)),
              Text(_desc(code), style: TextStyle(color: _muted(), fontSize: 14)),
            ])),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('High', style: TextStyle(color: _muted(), fontSize: 12)),
              Text(_fmtT(max), style: TextStyle(color: _txt(), fontSize: 40, fontWeight: FontWeight.w200, height: 1.2)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Low', style: TextStyle(color: _muted(), fontSize: 12)),
              Text(_fmtT(min), style: TextStyle(color: _txt(), fontSize: 40, fontWeight: FontWeight.w200, height: 1.2)),
            ])),
          ]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(T('done'), style: const TextStyle(fontWeight: FontWeight.w600)),
            )),
        ]),
      ),
    );
  }

  // ============ SMOOTH PAGE ROUTE ============







  PageRouteBuilder _smoothRoute({required WidgetBuilder builder}) {
    return PageRouteBuilder(
      opaque: true,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInOutCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  // ============ FULL-SCREEN DETAIL PAGE ============
  void _openDetail(String type) {
    Navigator.push(context, _smoothRoute(
      builder: (_) => _buildDetailPage(type),
    ));
  }

  Widget _buildDetailPage(String type) {
    String title = '', value = '', label = '', desc = '', ctx = '';

    if (type == 'precip') {
      title = '🌧️ ${T('precip')}';
      value = '${_precip.round()} mm';
      label = '$_precipChance% ${T('chance')}';
      desc = T('desc_precip');
      ctx = _precip > 0 ? T('raining') : T('dry');
    } else if (type == 'wind') {
      title = '💨 ${T('wind')}';
      value = _fmtW(_wind);
      label = '${T('direction')}: ' + ['N','NE','E','SE','S','SW','W','NW'][((_wind / 45).round()) % 8];
      desc = T('desc_wind');
      ctx = _wind > 20 ? T('strong_winds') : T('light_breeze');
    } else if (type == 'aqi') {
      title = '🌍 ${T('aqi')}';
      value = '$_aqi';
      label = '${T('category')}: ${_aqiCategory()}';
      desc = T('desc_aqi');
      ctx = '${T('context')}: ${_aqiCategory()}';
    } else if (type == 'uv') {
      title = '☀️ ${T('uv')}';
      value = '${_uv.round()}';
      label = '${T('category')}: ${_uvCategory()}';
      desc = T('desc_uv');
      ctx = '${T('uv')}: ${_uvCategory()}';
    } else if (type == 'humidity') {
      title = '💧 ${T('humidity')}';
      value = '$_humidity%';
      label = _humidity > 60 ? T('muggy') : T('comfortable');
      desc = T('desc_humidity');
      ctx = '$_humidity%';
    } else if (type == 'sun') {
      title = '🌅 ${T('sun')}';
      value = '${_fmtTime(_sunrise)} / ${_fmtTime(_sunset)}';
      label = '${T('sunrise')} / ${T('sunset')}';
      desc = T('desc_sun');
      ctx = '${T('sunrise')}: ${_fmtTime(_sunrise)} · ${T('sunset')}: ${_fmtTime(_sunset)}';
    } else if (type == 'outdoor') {
      final isBad = _wcode >= 51 || _temp > 38 || _temp < 5;
      title = '🏃 ${T('outdoor')}';
      value = isBad ? T('bad_out').split('.').first : T('great_out').split('.').first;
      label = T('about');
      desc = T('desc_outdoor');
      ctx = isBad ? T('bad_out') : T('great_out');
    } else if (type == 'clothing') {
      title = '👕 ${T('clothing')}';
      value = _temp > 30 ? 'Light' : _temp > 20 ? 'Comfortable' : 'Warm';
      label = T('about');
      desc = T('desc_clothing');
      ctx = _temp > 30 ? T('light_cloth') : _temp > 20 ? T('ok_cloth') : T('warm_cloth');
    } else if (type == 'cold') {
      final isHigh = _feels < 15 || _humidity > 80;
      title = '💊 ${T('cold')}';
      value = isHigh ? 'Higher Risk' : 'Low Risk';
      label = T('about');
      desc = T('desc_cold');
      ctx = isHigh ? T('high_cold') : T('low_cold');
    } else if (type == 'drive') {
      final isBad = (_wcode >= 45 && _wcode <= 48) || _wcode >= 61;
      title = '🚗 ${T('drive')}';
      value = isBad ? 'Caution' : 'Excellent';
      label = T('about');
      desc = T('desc_drive');
      ctx = isBad ? T('bad_drive') : T('ok_drive');
    }

    // Build weather metrics list
    final metrics = [
      {'key': 'precip', 'name': '🌧️ ${T('precip')}', 'val': '${_precip.round()} mm'},
      {'key': 'wind', 'name': '💨 ${T('wind')}', 'val': _fmtW(_wind)},
      {'key': 'aqi', 'name': '🌍 ${T('aqi')}', 'val': '$_aqi'},
      {'key': 'uv', 'name': '☀️ ${T('uv')}', 'val': '${_uv.round()}'},
      {'key': 'humidity', 'name': '💧 ${T('humidity')}', 'val': '$_humidity%'},
      {'key': 'sun', 'name': '🌅 ${T('sun')}', 'val': _fmtTime(_sunrise)},
    ];
    final lifestyle = [
      {'key': 'outdoor', 'name': '🏃 ${T('outdoor')}'},
      {'key': 'clothing', 'name': '👕 ${T('clothing')}'},
      {'key': 'cold', 'name': '💊 ${T('cold')}'},
      {'key': 'drive', 'name': '🚗 ${T('drive')}'},
    ];

    return _DetailPage(
        bg1: _bg1(), bg2: _bg2(), txt: _txt(),
        title: title, value: value, label: label, desc: desc, ctx: ctx,
        metrics: metrics.where((m) => m['key'] != type).toList(),
        lifestyle: lifestyle.where((m) => m['key'] != type).toList(),
        aboutLabel: T('about'),
        contextLabel: T('context'),
        exploreLabel: T('explore'),
        metricsLabel: T('weather_metrics'),
        lifestyleLabel: T('lifestyle'),
        onTapItem: (key) {
          Navigator.pushReplacement(
            context,
            _smoothRoute(builder: (_) => _buildDetailPage(key)),
          );
        },
  );
  }

  void _openSettings() {
    _smoothBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              Text(T('settings'), style: TextStyle(color: _txt(), fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              _settingDrop(T('theme'), _theme, ['auto','dark','light'],
                [T('auto'), T('dark'), T('light')],
                (v) { setSheet(() { _theme = v!; }); _saveSettings(); }),
              _settingDrop(T('temp_unit'), _unit, ['C','F'],
                ['Celsius (°C)','Fahrenheit (°F)'],
                (v) { setSheet(() { _unit = v!; }); _saveSettings(); }),
              _settingDrop(T('wind_unit'), _windUnit, ['kmh','mph'], ['km/h','mph'],
                (v) { setSheet(() { _windUnit = v!; }); _saveSettings(); }),
              _settingDrop(T('time_format'), _timeFmt, ['12h','24h'], ['12-hour','24-hour'],
                (v) { setSheet(() { _timeFmt = v!; }); _saveSettings(); }),
              _settingDrop(T('language'), _lang, ['en','ur','sd','es'],
                ['English','اردو','سنڌي','Español'],
                (v) { setSheet(() { _lang = v!; }); _saveSettings(); }),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _theme == 'light' ? const Color(0xFF1A1A1A) : Colors.white,
                    foregroundColor: _theme == 'light' ? Colors.white : const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(T('done'), style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
                )),
            ],
          )),
        ),
      )),
    );
  }

  Widget _settingDrop(String label, String val, List<String> vals, List<String> disp,
      Function(String?) onChange) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: _txt().withOpacity(0.8),
        fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _theme == 'light' ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _theme == 'light' ? Colors.black.withOpacity(0.15) : Colors.white.withOpacity(0.2))),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: val, dropdownColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
          isExpanded: true, style: TextStyle(color: _txt(), fontSize: 15),
          items: vals.asMap().entries.map((e) => DropdownMenuItem(
            value: e.value, child: Text(disp[e.key]))).toList(),
          onChanged: onChange,
        )),
      ),
    ]),
  );
}


// ============ FULL-SCREEN DETAIL PAGE WIDGET ============
class _DetailPage extends StatelessWidget {
  final Color bg1, bg2, txt;
  final String title, value, label, desc, ctx;
  final List<Map<String, String>> metrics, lifestyle;
  final String aboutLabel, contextLabel, exploreLabel, metricsLabel, lifestyleLabel;
  final Function(String) onTapItem;

  const _DetailPage({
    required this.bg1, required this.bg2, required this.txt,
    required this.title, required this.value, required this.label,
    required this.desc, required this.ctx,
    required this.metrics, required this.lifestyle,
    required this.aboutLabel, required this.contextLabel, required this.exploreLabel,
    required this.metricsLabel, required this.lifestyleLabel,
    required this.onTapItem,
  });

  bool get _isLight => bg1 == const Color(0xFFFFFFFF);
  Color _cardBorder() => _isLight ? const Color(0xFFDDDDDD) : const Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [bg1, bg2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button + title row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
                          shape: BoxShape.circle,
                          border: Border.all(color: _isLight ? Colors.transparent : Colors.white.withOpacity(0.25)),
                        ),
                        child: Icon(Icons.arrow_back, color: _isLight ? Colors.white : txt, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(title,
                      style: TextStyle(color: txt, fontSize: 21, fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 28),

                // Value
                Text(value, style: TextStyle(color: txt, fontSize: 60,
                  fontWeight: FontWeight.w200, height: 1)),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: txt.withOpacity(0.7), fontSize: 14)),
                const SizedBox(height: 32),

                // About section
                Text(aboutLabel, style: TextStyle(color: txt.withOpacity(0.9),
                  fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(desc, style: TextStyle(color: txt.withOpacity(0.8),
                  fontSize: 14, height: 1.6)),
                const SizedBox(height: 28),

                // Context section
                Text(contextLabel, style: TextStyle(color: txt.withOpacity(0.9),
                  fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(ctx, style: TextStyle(color: txt.withOpacity(0.8),
                  fontSize: 14, height: 1.6)),
                const SizedBox(height: 32),

                // Explore
                Divider(color: txt.withOpacity(0.15)),
                const SizedBox(height: 20),
                Text(exploreLabel, style: TextStyle(color: txt.withOpacity(0.9),
                  fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                // Weather Metrics
                if (metrics.isNotEmpty) ...[
                  Text(metricsLabel.toUpperCase(), style: TextStyle(
                    color: txt.withOpacity(0.6), fontSize: 13,
                    fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...metrics.map((m) => _listItem(m['name']!, m['val'] ?? '', txt,
                    () => onTapItem(m['key']!))),
                  const SizedBox(height: 20),
                ],

                // Lifestyle Index
                if (lifestyle.isNotEmpty) ...[
                  Text(lifestyleLabel.toUpperCase(), style: TextStyle(
                    color: txt.withOpacity(0.6), fontSize: 13,
                    fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...lifestyle.map((m) => _listItem(m['name']!, '', txt,
                    () => onTapItem(m['key']!))),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listItem(String name, String val, Color txt, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isLight ? const Color(0xFFF0F4F8) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder()),
        ),
        child: Row(
          children: [
            Expanded(child: Text(name, style: TextStyle(color: txt,
              fontSize: 14, fontWeight: FontWeight.w500))),
            if (val.isNotEmpty) ...[
              Text(val, style: TextStyle(color: txt.withOpacity(0.7), fontSize: 14)),
              const SizedBox(width: 8),
            ],
            Text('›', style: TextStyle(color: txt.withOpacity(0.5), fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

class _TapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TapCard({required this.child, required this.onTap});
  @override
  State<_TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<_TapCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}


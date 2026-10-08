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
      home: const SplashScreen(),
    );
  }
}

const Map<String, Map<String, String>> TR = {
  'en': {
    'search':'Search city...','go':'Go','wind':'Wind','humidity':'Humidity','feels':'Feels Like',
    'hourly':'Hourly Forecast','daily':'7-Day Forecast','details':'More Details','life':'Life Index',
    'settings':'App Settings','theme':'Theme','temp_unit':'Temperature','wind_unit':'Wind Speed',
    'time_format':'Time Format','language':'Language','text_size':'Text Size','done':'Done',
    'text_small':'Small','text_medium':'Medium','text_large':'Large','text_xlarge':'Extra Large',
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
      'desc_precip':'Precipitation includes rain, snow, and hail.',
      'desc_wind':'Wind direction indicates where the wind is coming from.',
      'desc_aqi':'Air quality affects your respiratory health.',
      'desc_uv':'UV radiation from the sun can damage your skin.',
      'desc_humidity':'Humidity is the amount of water vapor in the air.',
      'desc_sun':'The sun provides essential Vitamin D.',
      'desc_outdoor':'Consider the weather before planning outdoor activities.',
      'desc_clothing':'Dress appropriately for the current temperature.',
      'desc_cold':'Weather conditions can affect your risk of catching a cold.',
      'desc_drive':'Weather can significantly impact driving safety.',
  },
  'ur': {
    'search':'شہر تلاش کریں...','go':'جائیں','wind':'ہوا','humidity':'نمی','feels':'محسوس',
    'hourly':'گھنٹہ وار پیش گوئی','daily':'7 دن کی پیش گوئی','details':'مزید تفصیلات','life':'لائف انڈیکس',
    'settings':'ترتیبات','theme':'تھیم','temp_unit':'درجہ حرارت','wind_unit':'ہوا کی رفتار',
    'time_format':'وقت کی ترتیب','language':'زبان','text_size':'متن کا سائز','done':'مکمل',
    'text_small':'چھوٹا','text_medium':'درمیانہ','text_large':'بڑا','text_xlarge':'بہت بڑا',
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
      'desc_precip':'بارش میں بارش، برف اور اولے شامل ہیں۔',
      'desc_wind':'ہوا کی سمت بتاتی ہے کہ ہوا کہاں سے آ رہی ہے۔',
      'desc_aqi':'فضائی معیار آپ کی سانس کی صحت کو متاثر کرتا ہے۔',
      'desc_uv':'سورج سے نکلنے والی UV شعاعیں جلد کو نقصان پہنچا سکتی ہیں۔',
      'desc_humidity':'نمی ہوا میں پانی کے بخارات کی مقدار ہے۔',
      'desc_sun':'سورج ضروری وٹامن ڈی فراہم کرتا ہے۔',
      'desc_outdoor':'بیرونی سرگرمیوں سے پہلے موسم پر غور کریں۔',
      'desc_clothing':'موجودہ درجہ حرارت کے مطابق مناسب لباس پہنیں۔',
      'desc_cold':'موسمی حالات زکام کے خطرے کو متاثر کر سکتے ہیں۔',
      'desc_drive':'موسم ڈرائیونگ کی حفاظت کو متاثر کر سکتا ہے۔',
  },
  'sd': {
    'search':'شهر ڳوليو...','go':'وڃو','wind':'هوا','humidity':'نمي','feels':'محسوس',
    'hourly':'ڪلاڪوار اڳڪٿي','daily':'7 ڏينهن جي اڳڪٿي','details':'وڌيڪ تفصيل','life':'لائف انڊيڪس',
    'settings':'سيٽنگون','theme':'ٿيم','temp_unit':'درجه حرارت','wind_unit':'هوا جي رفتار',
    'time_format':'وقت جي ترتيب','language':'ٻولي','text_size':'متن جي ماپ','done':'مڪمل',
    'text_small':'ننڍو','text_medium':'وچولو','text_large':'وڏو','text_xlarge':'تمام وڏو',
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
      'desc_precip':'برسات ۾ مينهن، برف ۽ اولا شامل آهن.',
      'desc_wind':'هوا جي هدايت ظاهر ڪري ٿي ته هوا ڪٿان اچي رهي آهي.',
      'desc_aqi':'فضائي معيار توهان جي ساهه جي صحت کي متاثر ڪري ٿو.',
      'desc_uv':'سج مان نڪرندڙ UV شعاعون چمڙي کي نقصان پهچائي سگهن ٿيون.',
      'desc_humidity':'نمي هوا ۾ پاڻي جي بخارن جي مقدار آهي.',
      'desc_sun':'سج ضروري وٽامن ڊي فراهم ڪري ٿو.',
      'desc_outdoor':'ٻاهرين سرگرمين کان اڳ موسم تي غور ڪريو.',
      'desc_clothing':'موجوده درجه حرارت مطابق مناسب ڪپڙا پائو.',
      'desc_cold':'موسمي حالتون زڪام جي خطري کي متاثر ڪري سگهن ٿيون.',
      'desc_drive':'موسم ڊرائيونگ جي حفاظت کي متاثر ڪري سگهي ٿو.',
  },
  'es': {
    'search':'Buscar ciudad...','go':'Ir','wind':'Viento','humidity':'Humedad','feels':'Sensación',
    'hourly':'Por Hora','daily':'7 Días','details':'Más Detalles','life':'Índice de Vida',
    'settings':'Ajustes','theme':'Tema','temp_unit':'Temperatura','wind_unit':'Viento',
    'time_format':'Hora','language':'Idioma','text_size':'Tamaño de Texto','done':'Listo',
    'text_small':'Pequeño','text_medium':'Mediano','text_large':'Grande','text_xlarge':'Muy Grande',
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
      'desc_precip':'La precipitación incluye lluvia, nieve y granizo.',
      'desc_wind':'La dirección del viento indica de dónde viene.',
      'desc_aqi':'La calidad del aire afecta su salud respiratoria.',
      'desc_uv':'La radiación UV puede dañar su piel.',
      'desc_humidity':'La humedad es el vapor de agua en el aire.',
      'desc_sun':'El sol proporciona vitamina D esencial.',
      'desc_outdoor':'Considere el clima antes de planificar actividades.',
      'desc_clothing':'Vístase apropiadamente para la temperatura.',
      'desc_cold':'Las condiciones pueden afectar su riesgo de resfriarse.',
      'desc_drive':'El clima puede afectar la seguridad al conducir.',
  },
};

const List<String> DAYS_EN = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
const List<String> DAYS_UR = ['اتوار','پیر','منگل','بدھ','جمعرات','جمعہ','ہفتہ'];
const List<String> DAYS_SD = ['آچر','سومر','اڱارو','اربع','خميس','جمع','ڇنڇر'];
const List<String> DAYS_ES = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _spinCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _textFadeCtrl;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Sequence:
    // 1. Sun fades in and scales up (0-700ms)
    // 2. Text fades in (500-1100ms)
    // 3. Wait until 2200ms then navigate
    _fadeCtrl.forward();
    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textFadeCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (_, __, ___) => const WeatherHome(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _spinCtrl.dispose();
    _scaleCtrl.dispose();
    _textFadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated sun icon
            FadeTransition(
              opacity: _fadeCtrl,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack),
                ),
                child: AnimatedBuilder(
                  animation: _spinCtrl,
                  builder: (c, ch) => Transform.rotate(
                    angle: _spinCtrl.value * 2 * 3.14159,
                    child: ch,
                  ),
                  child: const Text('☀️', style: TextStyle(fontSize: 100)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App name
            FadeTransition(
              opacity: _textFadeCtrl,
              child: Column(
                children: [
                  const Text(
                    'SkyCast',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Weather',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000).withOpacity(0.5),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Loading dots
            FadeTransition(
              opacity: _textFadeCtrl,
              child: SizedBox(
                width: 40,
                height: 8,
                child: AnimatedBuilder(
                  animation: _spinCtrl,
                  builder: (c, ch) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final t = (_spinCtrl.value * 3 + i * 0.3) % 1.0;
                      final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.2, 1.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});
  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  String _lang = 'en', _theme = 'auto', _unit = 'C', _windUnit = 'kmh', _timeFmt = '12h', _textSize = 'medium';
  String _city = 'Karachi', _country = 'Pakistan';
  double _temp = 0, _feels = 0, _wind = 0, _precip = 0, _uv = 0;
  int _humidity = 0, _wcode = 0, _precipChance = 0, _aqi = 0;
  String _sunrise = '', _sunset = '';
  bool _loading = true, _allDays = false, _refreshing = false;
  double _mainOpacity = 1.0;
  List<dynamic> _hourly = [], _daily = [];

  late AnimationController _animCtrl;
  late Animation<double> _anim;

  String T(String k) => TR[_lang]?[k] ?? TR['en']?[k] ?? k;

  double get _textScaleValue {
    switch (_textSize) {
      case 'small': return 0.9;
      case 'large': return 1.15;
      case 'xlarge': return 1.3;
      default: return 1.0;
    }
  }

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
      _textSize = p.getString('textSize') ?? 'medium';
    });
  }

  Future<void> _saveSettings() async {
    if (mounted) setState(() {});  // Rebuild outer IMMEDIATELY
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', _lang);
    await p.setString('theme', _theme);
    await p.setString('unit', _unit);
    await p.setString('windUnit', _windUnit);
    await p.setString('timeFmt', _timeFmt);
    await p.setString('textSize', _textSize);
  }

  Future<void> _fetch(String input) async {
    setState(() => _loading = true);
    try {
      // Normalize input
      final city = input.trim();
      
      // Build variations to try
      final variations = <String>[
        city,
        city.replaceAll(' ', ''),
        city.replaceAll('hass', 'has'),
        city.replaceAll('hass', ' khas'),
        city.replaceAll('pur', 'pur '),
        city.split(' ').first,
      ];
      
      // Remove duplicates and short entries
      final unique = <String>{};
      for (final v in variations) {
        if (v.trim().length >= 3) unique.add(v.trim());
      }
      
      // Try each variation
      List<dynamic> allResults = [];
      for (final v in unique) {
        try {
          final res = await http.get(Uri.parse(
            'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(v)}&count=10&language=en&format=json'
          )).timeout(const Duration(seconds: 8));
          final data = json.decode(res.body);
          if (data['results'] != null) {
            allResults.addAll(data['results'] as List);
          }
        } catch (_) {}
      }
      
      if (allResults.isEmpty) {
        setState(() { _city = 'Not found'; _loading = false; });
        return;
      }
      
      // Remove duplicates by id
      final seen = <int>{};
      allResults = allResults.where((r) {
        final id = r['id'] as int;
        if (seen.contains(id)) return false;
        seen.add(id);
        return true;
      }).toList();
      
      // Only Pakistan results
      var pk = allResults.where((r) => r['country_code'] == 'PK').toList();
      if (pk.isEmpty) pk = allResults;
      
      // Score by name similarity to input
      final target = city.toLowerCase().replaceAll(' ', '');
      pk.sort((a, b) {
        final aName = (a['name'] as String).toLowerCase().replaceAll(' ', '');
        final bName = (b['name'] as String).toLowerCase().replaceAll(' ', '');
        
        // Exact match gets highest score
        int aScore = 0, bScore = 0;
        if (aName == target) aScore = 100;
        else if (aName.startsWith(target) || target.startsWith(aName)) aScore = 80;
        else if (aName.contains(target) || target.contains(aName)) aScore = 60;
        else {
          // Check how many characters match at the start
          int match = 0;
          for (int i = 0; i < aName.length && i < target.length; i++) {
            if (aName[i] == target[i]) match++;
            else break;
          }
          aScore = match * 5;
        }
        
        if (bName == target) bScore = 100;
        else if (bName.startsWith(target) || target.startsWith(bName)) bScore = 80;
        else if (bName.contains(target) || target.contains(bName)) bScore = 60;
        else {
          int match = 0;
          for (int i = 0; i < bName.length && i < target.length; i++) {
            if (bName[i] == target[i]) match++;
            else break;
          }
          bScore = match * 5;
        }
        
        if (aScore != bScore) return bScore - aScore;
        // Tiebreaker: population
        return ((b['population'] ?? 0) as int).compareTo((a['population'] ?? 0) as int);
      });
      
      final pk2 = pk.first;
      final lat = pk2['latitude'], lon = pk2['longitude'];

      final wr = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,precipitation&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max&timezone=auto')).timeout(const Duration(seconds: 10));
      final wd = json.decode(wr.body);
      final cc = wd['current'];

      final ar = await http.get(Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=european_aqi&timezone=auto')).timeout(const Duration(seconds: 10));
      final ad = json.decode(ar.body);

      setState(() {
        _city = pk2['name'] ?? city;
        _country = pk2['country'] ?? '';
        _temp = (cc['temperature_2m'] as num).toDouble();
        _feels = (cc['apparent_temperature'] as num).toDouble();
        _humidity = (cc['relative_humidity_2m'] as num).toInt();
        _wind = (cc['wind_speed_10m'] as num).toDouble();
        _precip = (cc['precipitation'] as num).toDouble();
        _wcode = (cc['weather_code'] as num).toInt();
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
      setState(() { _city = 'Connection error'; _country = ''; _loading = false; });
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
    // Use translated weather code if available
    final key = 'w$c';
    final translated = TR[_lang]?[key];
    if (translated != null) return translated;
    // Fallback to English
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
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(_textScaleValue)),
      child: Scaffold(
      backgroundColor: _bg1(),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_bg1(), _bg2()])),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _fetch(_city),
            color: _txt(),
            backgroundColor: _cardBg(),
            displacement: 100,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: AnimatedOpacity(
                opacity: _mainOpacity,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
        onPressed: _openSettings,
        child: Icon(Icons.settings, color: Colors.white),
      ),
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
    _TapButton(
      onTap: () { final v = _ctrl.text.trim(); if (v.isNotEmpty) _fetch(v); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(T('go'),
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ),
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
    return _card(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(T('daily').toUpperCase(), style: TextStyle(color: _muted(),
          fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...days.asMap().entries.map((e) => GestureDetector(
                  onTap: () => _showDayDetail(e.value, e.key == 0),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: _itemBg(),
                      borderRadius: BorderRadius.circular(16), border: Border.all(color: _cardBorder())),
                    child: Row(children: [
                      SizedBox(width: 60, child: Text(
                        e.key == 0 ? T('today') : _day(e.value['date']),
                        style: TextStyle(color: _txt(), fontSize: 14, fontWeight: FontWeight.w500))),
                      Text(_icon(e.value['code']), style: const TextStyle(fontSize: 20)),
                      const Spacer(),
                      Text('${_fmtT((e.value['max'] as num).toDouble())} / ${_fmtT((e.value['min'] as num).toDouble())}',
                        style: TextStyle(color: _muted(), fontSize: 14)),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, size: 16, color: _faint()),
                    ]),
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: () => setState(() => _allDays = !_allDays),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
              foregroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
              elevation: 0,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(_allDays ? 'Less' : 'More',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          ),
        ),
      ],
    ));
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
      backgroundColor: Colors.transparent,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: isScrollControlled,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
        reverseDuration: const Duration(milliseconds: 500),
      ),
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: _cardBg(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: builder(ctx),
      ),
    );
  }
  String _getDetailContent(String type) {
    String title = '', value = '', label = '', desc = '', ctx = '';
    if (type == 'precip') {
      title = '🌧️ ${T('precip')}'; value = '${_precip.round()} mm';
      label = '$_precipChance% ${T('chance')}';
      desc = T('desc_precip');
      ctx = _precip > 0 ? T('raining') : T('dry');
    } else if (type == 'wind') {
      title = '💨 ${T('wind')}'; value = _fmtW(_wind);
      label = '${T('direction')}: ' + ['N','NE','E','SE','S','SW','W','NW'][((_wind / 45).round()) % 8];
      desc = T('desc_wind');
      ctx = _wind > 20 ? T('strong_winds') : T('light_breeze');
    } else if (type == 'aqi') {
      title = '🌍 ${T('aqi')}'; value = '$_aqi';
      label = '${T('category')}: ${_aqiCategory()}';
      desc = T('desc_aqi'); ctx = '${T('context')}: ${_aqiCategory()}';
    } else if (type == 'uv') {
      title = '☀️ ${T('uv')}'; value = '${_uv.round()}';
      label = '${T('category')}: ${_uvCategory()}';
      desc = T('desc_uv'); ctx = '${T('uv')}: ${_uvCategory()}';
    } else if (type == 'humidity') {
      title = '💧 ${T('humidity')}'; value = '$_humidity%';
      label = _humidity > 60 ? T('muggy') : T('comfortable');
      desc = T('desc_humidity'); ctx = '$_humidity%';
    } else if (type == 'sun') {
      title = '🌅 ${T('sun')}'; value = '${_fmtTime(_sunrise)} / ${_fmtTime(_sunset)}';
      label = '${T('sunrise')} / ${T('sunset')}';
      desc = T('desc_sun');
      ctx = '${T('sunrise')}: ${_fmtTime(_sunrise)} · ${T('sunset')}: ${_fmtTime(_sunset)}';
    } else if (type == 'outdoor') {
      final isBad = _wcode >= 51 || _temp > 38 || _temp < 5;
      title = '🏃 ${T('outdoor')}';
      value = isBad ? T('bad_out').split('.').first : T('great_out').split('.').first;
      label = T('about'); desc = T('desc_outdoor');
      ctx = isBad ? T('bad_out') : T('great_out');
    } else if (type == 'clothing') {
      title = '👕 ${T('clothing')}';
      value = _temp > 30 ? 'Light' : _temp > 20 ? 'Comfortable' : 'Warm';
      label = T('about'); desc = T('desc_clothing');
      ctx = _temp > 30 ? T('light_cloth') : _temp > 20 ? T('ok_cloth') : T('warm_cloth');
    } else if (type == 'cold') {
      final isHigh = _feels < 15 || _humidity > 80;
      title = '💊 ${T('cold')}';
      value = isHigh ? 'Higher Risk' : 'Low Risk';
      label = T('about'); desc = T('desc_cold');
      ctx = isHigh ? T('high_cold') : T('low_cold');
    } else if (type == 'drive') {
      final isBad = (_wcode >= 45 && _wcode <= 48) || _wcode >= 61;
      title = '🚗 ${T('drive')}';
      value = isBad ? 'Caution' : 'Excellent';
      label = T('about'); desc = T('desc_drive');
      ctx = isBad ? T('bad_drive') : T('ok_drive');
    }
    return '$title|$value|$label|$desc|$ctx';
  }

  void _openDetail(String type) {
    final metrics = [
      {'key': 'precip', 'name': '🌧️ ${T('precip')}', 'val': '${_precip.round()} mm'},
      {'key': 'wind', 'name': '💨 ${T('wind')}', 'val': _fmtW(_wind)},
      {'key': 'aqi', 'name': '🌍 ${T('aqi')}', 'val': '$_aqi'},
      {'key': 'uv', 'name': '☀️ ${T('uv')}', 'val': '${_uv.round()}'},
      {'key': 'humidity', 'name': '💧 ${T('humidity')}', 'val': '$_humidity%'},
      {'key': 'sun', 'name': '🌅 ${T('sun')}', 'val': _fmtTime(_sunrise)},
    ];
    final lifestyle = [
      {'key': 'outdoor', 'name': '🏃 ${T('outdoor')}', 'val': ''},
      {'key': 'clothing', 'name': '👕 ${T('clothing')}', 'val': ''},
      {'key': 'cold', 'name': '💊 ${T('cold')}', 'val': ''},
      {'key': 'drive', 'name': '🚗 ${T('drive')}', 'val': ''},
    ];

    Navigator.push(context, _smoothRoute(builder: (_) => _DetailPage(
      bg1: _bg1(), bg2: _bg2(), txt: _txt(),
      initialType: type,
      getContent: _getDetailContent,
      getIconKey: (k) => k,
      aboutLabel: T('about'),
      contextLabel: T('context'),
      exploreLabel: T('explore'),
      metricsLabel: T('weather_metrics'),
      lifestyleLabel: T('lifestyle'),
      metricsList: metrics,
      lifestyleList: lifestyle,
    )));
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
                (v) { setState(() { _theme = v!; }); setSheet(() {}); _saveSettings(); }),
              _settingDrop(T('temp_unit'), _unit, ['C','F'],
                ['Celsius (°C)','Fahrenheit (°F)'],
                (v) { setState(() { _unit = v!; }); setSheet(() {}); _saveSettings(); }),
              _settingDrop(T('wind_unit'), _windUnit, ['kmh','mph'], ['km/h','mph'],
                (v) { setState(() { _windUnit = v!; }); setSheet(() {}); _saveSettings(); }),
              _settingDrop(T('time_format'), _timeFmt, ['12h','24h'], ['12-hour','24-hour'],
                (v) { setState(() { _timeFmt = v!; }); setSheet(() {}); _saveSettings(); }),
              _settingDrop(T('language'), _lang, ['en','ur','sd','es'],
                ['English','اردو','سنڌي','Español'],
                (v) async {
              if (v == _lang) return;
              setState(() => _mainOpacity = 0.0);
              await Future.delayed(const Duration(milliseconds: 350));
              setState(() { _lang = v!; _mainOpacity = 1.0; });
              setSheet(() {});
              _saveSettings();
            }),
              _settingDrop(T('text_size'), _textSize, ['small','medium','large','xlarge'],
                [T('text_small'), T('text_medium'), T('text_large'), T('text_xlarge')],
                (v) async {
              if (v == _textSize) return;
              setState(() => _mainOpacity = 0.0);
              await Future.delayed(const Duration(milliseconds: 250));
              setState(() { _textSize = v!; _mainOpacity = 1.0; });
              setSheet(() {});
              _saveSettings();
            }),
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
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(label,
          style: TextStyle(
            color: _isLight ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          )),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: _isLight ? const Color(0xFFF8F8F8) : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isLight ? const Color(0xFFBBBBBB) : const Color(0xFF444444),
            width: 1.5,
          ),
          boxShadow: _isLight
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
            : null,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: val,
            dropdownColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: _isLight ? const Color(0xFF333333) : const Color(0xFFFFFFFF),
              size: 22),
            style: TextStyle(
              color: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            items: vals.asMap().entries.map((e) => DropdownMenuItem(
              value: e.value,
              child: Text(disp[e.key],
                style: TextStyle(
                  color: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                )),
            )).toList(),
            onChanged: onChange,
          ),
        ),
      ),
    ]),
  );
}


// ============ FULL-SCREEN DETAIL PAGE WIDGET ============
class _DetailPage extends StatefulWidget {
  final Color bg1, bg2, txt;
  final Function(String) getContent;  // returns content for a type
  final Function(String) getIconKey;
  final String initialType;
  final String aboutLabel, contextLabel, exploreLabel, metricsLabel, lifestyleLabel;
  final List<Map<String, String>> metricsList, lifestyleList;

  const _DetailPage({
    required this.bg1, required this.bg2, required this.txt,
    required this.getContent,
    required this.getIconKey,
    required this.initialType,
    required this.aboutLabel, required this.contextLabel, required this.exploreLabel,
    required this.metricsLabel, required this.lifestyleLabel,
    required this.metricsList, required this.lifestyleList,
  });

  @override
  State<_DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage> {
  late String _currentType;
  late Map<String, String> _content;
  final ScrollController _scrollCtrl = ScrollController();
  double _contentOpacity = 1.0;
  bool _isTransitioning = false;

  bool get _isLight => widget.bg1 == const Color(0xFFFFFFFF);
  Color _cardBorder() => _isLight ? const Color(0xFFDDDDDD) : const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _content = _parseContent(widget.getContent(_currentType));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Map<String, String> _parseContent(String raw) {
    // The content is a concatenated string like:
    // "title|value|label|desc|ctx"
    final parts = raw.split('|');
    return {
      'title': parts.isNotEmpty ? parts[0] : '',
      'value': parts.length > 1 ? parts[1] : '',
      'label': parts.length > 2 ? parts[2] : '',
      'desc': parts.length > 3 ? parts[3] : '',
      'ctx': parts.length > 4 ? parts[4] : '',
    };
  }

  void _onExploreTap(String key) async {
    if (key == _currentType) return;
    if (_isTransitioning) return;  // Prevent fast taps
    
    _isTransitioning = true;

    // Step 1: Scroll to top first (if scrolled down)
    if (_scrollCtrl.hasClients && _scrollCtrl.offset > 0) {
      await _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }

    // Step 2: Fade out old content
    if (mounted) setState(() => _contentOpacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 3: Swap content
    if (mounted) {
      setState(() {
        _currentType = key;
        _content = _parseContent(widget.getContent(key));
      });
    }
    
    // Step 4: Fade in new content
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) setState(() => _contentOpacity = 1.0);
    
    // Step 5: Release lock after full animation
    await Future.delayed(const Duration(milliseconds: 400));
    _isTransitioning = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.bg1, widget.bg2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: widget.txt,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back,
                          color: widget.bg1, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(
                      _content['title'] ?? '',
                      style: TextStyle(color: widget.txt, fontSize: 21, fontWeight: FontWeight.w600),
                    )),
                  ],
                ),
                const SizedBox(height: 28),

                AnimatedOpacity(
                  opacity: _contentOpacity,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Main value
                Text(_content['value'] ?? '',
                  style: TextStyle(color: widget.txt, fontSize: 60,
                    fontWeight: FontWeight.w200, height: 1)),
                const SizedBox(height: 6),
                Text(_content['label'] ?? '',
                  style: TextStyle(color: widget.txt.withOpacity(0.7), fontSize: 14)),
                const SizedBox(height: 32),

                // About
                Text(widget.aboutLabel, style: TextStyle(color: widget.txt.withOpacity(0.9),
                  fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(_content['desc'] ?? '', style: TextStyle(color: widget.txt.withOpacity(0.8),
                  fontSize: 14, height: 1.6)),
                const SizedBox(height: 28),

                // Context
                Text(widget.contextLabel, style: TextStyle(color: widget.txt.withOpacity(0.9),
                  fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(_content['ctx'] ?? '', style: TextStyle(color: widget.txt.withOpacity(0.8),
                  fontSize: 14, height: 1.6)),
                const SizedBox(height: 32),
                    ],
                  ),
                ),

                Divider(color: widget.txt.withOpacity(0.15)),
                const SizedBox(height: 20),

                Text(widget.exploreLabel, style: TextStyle(color: widget.txt.withOpacity(0.9),
                  fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                if (widget.metricsList.any((m) => m['key'] != _currentType)) ...[
                  Text(widget.metricsLabel.toUpperCase(), style: TextStyle(
                    color: widget.txt.withOpacity(0.6), fontSize: 13,
                    fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...widget.metricsList
                    .where((m) => m['key'] != _currentType)
                    .map((m) => _listItem(m['name']!, m['val'] ?? '', () => _onExploreTap(m['key']!))),
                  const SizedBox(height: 20),
                ],
                if (widget.lifestyleList.any((m) => m['key'] != _currentType)) ...[
                  Text(widget.lifestyleLabel.toUpperCase(), style: TextStyle(
                    color: widget.txt.withOpacity(0.6), fontSize: 13,
                    fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...widget.lifestyleList
                    .where((m) => m['key'] != _currentType)
                    .map((m) => _listItem(m['name']!, '', () => _onExploreTap(m['key']!))),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listItem(String name, String val, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder()),
        ),
        child: Row(
          children: [
            Expanded(child: Text(name, style: TextStyle(color: widget.txt,
              fontSize: 14, fontWeight: FontWeight.w500))),
            if (val.isNotEmpty) ...[
              Text(val, style: TextStyle(color: widget.txt.withOpacity(0.7), fontSize: 14)),
              const SizedBox(width: 8),
            ],
            Text('\u203A', style: TextStyle(color: widget.txt.withOpacity(0.5), fontSize: 22)),
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
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _TapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TapButton({required this.child, required this.onTap});
  @override
  State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton> {
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
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}


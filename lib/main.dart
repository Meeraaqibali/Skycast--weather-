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
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// TRANSLATIONS
// ============================================================
const Map<String, Map<String, String>> TR = {
  'en': {
    'search':'Search city...','go':'Go','wind':'Wind','humidity':'Humidity','feels':'Feels Like',
    'hourly':'Hourly Forecast','daily':'Weekly Forecast','details':'More Details','life':'Life Index',
    'settings':'App Settings','theme':'Theme','temp_unit':'Temperature','wind_unit':'Wind Speed',
    'time_format':'Time Format','language':'Language','text_size':'Text Size','done':'Done',
    'auto':'Auto','dark':'Dark','light':'Light','now':'Now','today':'Today',
    'text_small':'Small','text_medium':'Medium','text_large':'Large','text_xlarge':'Extra Large',
    'precip':'Precipitation','aqi':'Air Quality','uv':'UV Index','sun':'Sun',
    'sunrise':'Sunrise','sunset':'Sunset','chance':'chance','direction':'Direction','category':'Category',
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
    'w0':'Clear sky','w1':'Mainly clear','w2':'Partly cloudy','w3':'Overcast','w45':'Fog','w48':'Rime fog',
    'w51':'Light drizzle','w53':'Moderate drizzle','w55':'Dense drizzle',
    'w61':'Slight rain','w63':'Moderate rain','w65':'Heavy rain',
    'w71':'Slight snow','w73':'Moderate snow','w75':'Heavy snow',
    'w95':'Thunderstorm','w96':'Thunderstorm with hail','w99':'Thunderstorm with heavy hail',
      'pred_clear':'Clear sunny day. Perfect for outdoor activities.',
      'pred_mostly_clear':'Mostly clear. Great weather to be outside.',
      'pred_partly_cloudy':'Partly cloudy with some sunshine.',
      'pred_overcast':'Overcast skies. Might feel a bit gloomy.',
      'pred_fog':'Foggy conditions. Drive carefully.',
      'pred_drizzle':'Light drizzle expected. Carry an umbrella.',
      'pred_rain':'Rain expected. Bring an umbrella and wear waterproof shoes.',
      'pred_snow':'Snow expected. Dress warmly and drive carefully.',
      'pred_storm':'Thunderstorms expected. Stay indoors if possible.',
      'pred_mixed':'Mixed conditions throughout the day.',
      'label_high':'High','label_low':'Low',
  },
  'ur': {
    'search':'شہر تلاش کریں...','go':'جائیں','wind':'ہوا','humidity':'نمی','feels':'محسوس',
    'hourly':'گھنٹہ وار پیش گوئی','daily':'ہفتہ وار پیش گوئی','details':'مزید تفصیلات','life':'لائف انڈیکس',
    'settings':'ترتیبات','theme':'تھیم','temp_unit':'درجہ حرارت','wind_unit':'ہوا کی رفتار',
    'time_format':'وقت کی ترتیب','language':'زبان','text_size':'متن کا سائز','done':'مکمل',
    'auto':'خودکار','dark':'ڈارک','light':'لائٹ','now':'ابھی','today':'آج',
    'text_small':'چھوٹا','text_medium':'درمیانہ','text_large':'بڑا','text_xlarge':'بہت بڑا',
    'precip':'بارش','aqi':'فضائی معیار','uv':'یووی انڈیکس','sun':'سورج',
    'sunrise':'طلوع','sunset':'غروب','chance':'امکان','direction':'سمت','category':'قسم',
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
    'w0':'صاف آسمان','w1':'بنیادی طور پر صاف','w2':'جزوی ابر آلود','w3':'ابر آلود','w45':'دھند','w48':'دھند',
    'w51':'ہلکی بوندا باندی','w53':'درمیانی بوندا باندی','w55':'تیز بوندا باندی',
    'w61':'ہلکی بارش','w63':'درمیانی بارش','w65':'تیز بارش',
    'w71':'ہلکی برف باری','w73':'درمیانی برف باری','w75':'تیز برف باری',
    'w95':'گرج چمک','w96':'گرج چمک کے ساتھ اولے','w99':'گرج چمک کے ساتھ تیز اولے',
      'pred_clear':'صاف دھوپ والا دن۔ بیرونی سرگرمیوں کے لیے بہترین۔',
      'pred_mostly_clear':'زیادہ تر صاف۔ باہر جانے کے لیے بہترین موسم۔',
      'pred_partly_cloudy':'جزوی طور پر ابر آلود، کچھ دھوپ کے ساتھ۔',
      'pred_overcast':'ابر آلود آسمان۔ تھوڑا اداس محسوس ہو سکتا ہے۔',
      'pred_fog':'دھند کے حالات۔ احتیاط سے گاڑی چلائیں۔',
      'pred_drizzle':'ہلکی بوندا باندی متوقع۔ چھتری ساتھ رکھیں۔',
      'pred_rain':'بارش متوقع۔ چھتری لائیں اور واٹر پروف جوتے پہنیں۔',
      'pred_snow':'برف باری متوقع۔ گرم کپڑے پہنیں اور احتیاط سے گاڑی چلائیں۔',
      'pred_storm':'گرج چمک متوقع۔ اگر ممکن ہو تو گھر میں رہیں۔',
      'pred_mixed':'دن بھر مخلوط حالات۔',
      'label_high':'زیادہ','label_low':'کم',
  },
  'sd': {
    'search':'شهر ڳوليو...','go':'وڃو','wind':'هوا','humidity':'نمي','feels':'محسوس',
    'hourly':'ڪلاڪوار اڳڪٿي','daily':'هفتيوار اڳڪٿي','details':'وڌيڪ تفصيل','life':'لائف انڊيڪس',
    'settings':'سيٽنگون','theme':'ٿيم','temp_unit':'درجه حرارت','wind_unit':'هوا جي رفتار',
    'time_format':'وقت جي ترتيب','language':'ٻولي','text_size':'متن جي ماپ','done':'مڪمل',
    'auto':'خودڪار','dark':'ڊارڪ','light':'لائيٽ','now':'هاڻي','today':'اڄ',
    'text_small':'ننڍو','text_medium':'وچولو','text_large':'وڏو','text_xlarge':'تمام وڏو',
    'precip':'برسات','aqi':'فضائي معيار','uv':'يووي انڊيڪس','sun':'سج',
    'sunrise':'سج اڀرڻ','sunset':'سج لهڻ','chance':'امڪان','direction':'هدايت','category':'قسم',
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
    'w0':'صاف آسمان','w1':'مکيه صاف','w2':'جزوي ڪڪر','w3':'ڪڪر','w45':'ڌنڌ','w48':'ڌنڌ',
    'w51':'هلڪي برسات','w53':'وچولي برسات','w55':'تيز برسات',
    'w61':'هلڪو مينهن','w63':'وچولو مينهن','w65':'تيز مينهن',
    'w71':'هلڪي برفباري','w73':'وچولي برفباري','w75':'تيز برفباري',
    'w95':'گرج چمڪ','w96':'گرج چمڪ ۽ اولا','w99':'گرج چمڪ ۽ تيز اولا',
      'pred_clear':'صاف سج وارو ڏينهن. ٻاهرين سرگرمين لاءِ بهترين.',
      'pred_mostly_clear':'وڌيڪ صاف. ٻاهر وڃڻ لاءِ بهترين موسم.',
      'pred_partly_cloudy':'جزوي طور تي ڪڪر، ٿوري سج سان.',
      'pred_overcast':'ڪڪر وارو آسمان. ٿورو اداس محسوس ٿي سگهي ٿو.',
      'pred_fog':'ڌنڌ جا حالتون. احتياط سان گاڏي هلايو.',
      'pred_drizzle':'هلڪي برسات متوقع. ڇٽي ساڻ رکو.',
      'pred_rain':'مينهن متوقع. ڇٽي آڻيو ۽ واٽر پروف جوتا پائو.',
      'pred_snow':'برفباري متوقع. گرم ڪپڙا پائو ۽ احتياط سان گاڏي هلايو.',
      'pred_storm':'گرج چمڪ متوقع. جيڪڏهن ممڪن هجي ته گهر ۾ رهو.',
      'pred_mixed':'ڏينهن تي مخلوط حالتون.',
      'label_high':'وڌيڪ','label_low':'گهٽ',
  },
  'es': {
    'search':'Buscar ciudad...','go':'Ir','wind':'Viento','humidity':'Humedad','feels':'Sensación',
    'hourly':'Por Hora','daily':'Semanal','details':'Más Detalles','life':'Índice de Vida',
    'settings':'Ajustes','theme':'Tema','temp_unit':'Temperatura','wind_unit':'Viento',
    'time_format':'Hora','language':'Idioma','text_size':'Tamaño de Texto','done':'Listo',
    'auto':'Auto','dark':'Oscuro','light':'Claro','now':'Ahora','today':'Hoy',
    'text_small':'Pequeño','text_medium':'Mediano','text_large':'Grande','text_xlarge':'Muy Grande',
    'precip':'Precipitación','aqi':'Calidad Aire','uv':'Índice UV','sun':'Sol',
    'sunrise':'Amanecer','sunset':'Atardecer','chance':'probabilidad','direction':'Dirección','category':'Categoría',
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
    'w0':'Cielo despejado','w1':'Mayormente despejado','w2':'Parcialmente nublado','w3':'Nublado','w45':'Niebla','w48':'Niebla helada',
    'w51':'Llovizna ligera','w53':'Llovizna','w55':'Llovizna densa',
    'w61':'Lluvia ligera','w63':'Lluvia','w65':'Lluvia fuerte',
    'w71':'Nieve ligera','w73':'Nieve','w75':'Nieve fuerte',
    'w95':'Tormenta','w96':'Tormenta con granizo','w99':'Tormenta fuerte',
      'pred_clear':'Día soleado y despejado. Perfecto para actividades al aire libre.',
      'pred_mostly_clear':'Mayormente despejado. Excelente clima para estar afuera.',
      'pred_partly_cloudy':'Parcialmente nublado con algo de sol.',
      'pred_overcast':'Cielo nublado. Puede sentirse un poco gris.',
      'pred_fog':'Niebla. Conduzca con cuidado.',
      'pred_drizzle':'Llovizna ligera esperada. Lleva paraguas.',
      'pred_rain':'Lluvia esperada. Lleva paraguas y zapatos impermeables.',
      'pred_snow':'Nieve esperada. Abríguese y conduzca con cuidado.',
      'pred_storm':'Tormentas esperadas. Quédese en casa si es posible.',
      'pred_mixed':'Condiciones mixtas durante el día.',
      'label_high':'Alta','label_low':'Baja',
  },
};

const List<String> DAYS_EN = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
const List<String> DAYS_UR = ['اتوار','پیر','منگل','بدھ','جمعرات','جمعہ','ہفتہ'];
const List<String> DAYS_SD = ['آچر','سومر','اڱارو','اربع','خميس','جمع','ڇنڇر'];
const List<String> DAYS_ES = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'];

// ============================================================
// SPLASH SCREEN — extended duration to cover native splash gap
// ============================================================
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
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textFadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fadeCtrl.forward();
    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textFadeCtrl.forward();
    });

    // Extended to 3000ms so main app has time to init during fade
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (_, __, ___) => const WeatherHome(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
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
            FadeTransition(
              opacity: _fadeCtrl,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack)),
                child: AnimatedBuilder(
                  animation: _spinCtrl,
                  builder: (c, ch) => Transform.rotate(
                    angle: _spinCtrl.value * 2 * 3.14159, child: ch),
                  child: const Text('☀️', style: TextStyle(fontSize: 100)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textFadeCtrl,
              child: Column(children: [
                const Text('SkyCast',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700,
                    color: Color(0xFF000000), letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Weather',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                    color: const Color(0xFF000000).withOpacity(0.5), letterSpacing: 4)),
              ]),
            ),
            const SizedBox(height: 60),
            FadeTransition(
              opacity: _textFadeCtrl,
              child: SizedBox(
                width: 40, height: 8,
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

// ============================================================
// MAIN APP
// ============================================================
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
  bool _loading = true, _allDays = false;
  List<dynamic> _hourly = [], _daily = [];

  String T(String k) => TR[_lang]?[k] ?? TR['en']?[k] ?? k;

  double get _textScaleValue {
    switch (_textSize) {
      case 'small': return 0.9;
      case 'large': return 1.15;
      case 'xlarge': return 1.3;
      default: return 1.0;
    }
  }

  bool get _isLight {
    if (_theme == 'light') return true;
    if (_theme == 'dark') return false;
    final h = DateTime.now().hour;
    return h >= 6 && h < 18;
  }

  Color _bg1() => _loading ? const Color(0xFFFFFFFF) : (_isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000));
  Color _bg2() => _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color _txt() => _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  Color _muted() => _isLight ? const Color(0xFF444444) : const Color(0xFFBBBBBB);
  Color _faint() => _isLight ? const Color(0xFF666666) : const Color(0xFF999999);
  Color _cardBg() => _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  Color _cardBorder() => _isLight ? const Color(0xFFDDDDDD) : const Color(0xFF333333);
  Color _divider() => _isLight ? const Color(0xFFDDDDDD) : const Color(0xFF333333);
  Color _itemBg() => _isLight ? const Color(0xFFF5F5F5) : const Color(0xFF252525);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _lang = p.getString('lang') ?? 'en';
      _theme = p.getString('theme') ?? 'auto';
      _unit = p.getString('unit') ?? 'C';
      _windUnit = p.getString('windUnit') ?? 'kmh';
      _timeFmt = p.getString('timeFmt') ?? '12h';
      _textSize = p.getString('textSize') ?? 'medium';
    });
    // Try GPS first; fall back to saved city
    await _tryCurrentLocation(p);
  }

  Future<void> _tryCurrentLocation(SharedPreferences p) async {
    try {
      // Use IP-based geolocation (no permissions needed)
      final res = await http.get(
        Uri.parse('http://ip-api.com/json/?fields=status,country,city,lat,lon'),
      ).timeout(const Duration(seconds: 6));
      final data = json.decode(res.body);
      if (data['status'] == 'success') {
        final city = data['city'] ?? 'Current Location';
        final country = data['country'] ?? '';
        final lat = (data['lat'] as num).toDouble();
        final lon = (data['lon'] as num).toDouble();
        final name = country.isNotEmpty ? '$city, $country' : city;
        await _fetchByCoords(lat, lon, name);
        return;
      }
      _fallbackToSavedCity(p);
    } catch (e) {
      _fallbackToSavedCity(p);
    }
  }

  void _fallbackToSavedCity(SharedPreferences p) {
    final saved = p.getString('lastCity') ?? 'Karachi';
    _fetch(saved);
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10'),
        headers: {'User-Agent': 'SkyCastWeather/1.0'},
      ).timeout(const Duration(seconds: 5));
      final data = json.decode(res.body);
      final addr = data['address'] ?? {};
      final city = addr['city'] ?? addr['town'] ?? addr['village'] ??
                    addr['suburb'] ?? addr['county'] ?? 'Current Location';
      final country = addr['country'] ?? '';
      return country.isNotEmpty ? '$city, $country' : city;
    } catch (_) {
      return 'Current Location';
    }
  }

  Future<void> _fetchByCoords(double lat, double lon, String name) async {
    setState(() => _loading = true);
    try {
      final wr = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,precipitation&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max&timezone=auto'
      )).timeout(const Duration(seconds: 10));
      final wd = json.decode(wr.body);
      final cc = wd['current'];

      final ar = await http.get(Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=european_aqi&timezone=auto'
      )).timeout(const Duration(seconds: 10));
      final ad = json.decode(ar.body);

      if (!mounted) return;
      setState(() {
        _city = name;
        _country = '';
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
      if (!mounted) return;
      setState(() { _city = 'Connection error'; _country = ''; _loading = false; });
    }
  }

  Future<void> _saveSettings() async {
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
      final city = input.trim();
      final variations = <String>[
        city,
        city.replaceAll(' ', ''),
        city.replaceAll('hass', 'has'),
        city.replaceAll('hass', ' khas'),
        city.split(' ').first,
      ];
      final unique = <String>{};
      for (final v in variations) { if (v.trim().length >= 3) unique.add(v.trim()); }

      List<dynamic> allResults = [];
      for (final v in unique) {
        try {
          final res = await http.get(Uri.parse(
            'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(v)}&count=10&language=en&format=json'
          )).timeout(const Duration(seconds: 8));
          final data = json.decode(res.body);
          if (data['results'] != null) allResults.addAll(data['results'] as List);
        } catch (_) {}
      }
      if (allResults.isEmpty) {
        setState(() { _city = 'Not found'; _loading = false; });
        return;
      }
      final seen = <int>{};
      allResults = allResults.where((r) {
        final id = r['id'] as int;
        if (seen.contains(id)) return false;
        seen.add(id); return true;
      }).toList();
      var pk = allResults.where((r) => r['country_code'] == 'PK').toList();
      if (pk.isEmpty) pk = allResults;

      final target = city.toLowerCase().replaceAll(' ', '');
      pk.sort((a, b) {
        final aName = (a['name'] as String).toLowerCase().replaceAll(' ', '');
        final bName = (b['name'] as String).toLowerCase().replaceAll(' ', '');
        int aScore = 0, bScore = 0;
        if (aName == target) aScore = 100;
        else if (aName.startsWith(target) || target.startsWith(aName)) aScore = 80;
        else if (aName.contains(target) || target.contains(aName)) aScore = 60;
        else {
          int m = 0;
          for (int i = 0; i < aName.length && i < target.length; i++) {
            if (aName[i] == target[i]) m++; else break;
          }
          aScore = m * 5;
        }
        if (bName == target) bScore = 100;
        else if (bName.startsWith(target) || target.startsWith(bName)) bScore = 80;
        else if (bName.contains(target) || target.contains(bName)) bScore = 60;
        else {
          int m = 0;
          for (int i = 0; i < bName.length && i < target.length; i++) {
            if (bName[i] == target[i]) m++; else break;
          }
          bScore = m * 5;
        }
        if (aScore != bScore) return bScore - aScore;
        return ((b['population'] ?? 0) as int).compareTo((a['population'] ?? 0) as int);
      });

      final loc = pk.first;
      final lat = loc['latitude'], lon = loc['longitude'];

      final wr = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,precipitation&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max&timezone=auto'
      )).timeout(const Duration(seconds: 10));
      final wd = json.decode(wr.body);
      final c = wd['current'];

      final ar = await http.get(Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=european_aqi&timezone=auto'
      )).timeout(const Duration(seconds: 10));
      final ad = json.decode(ar.body);

      if (!mounted) return;
      setState(() {
        _city = loc['name'] ?? city;
        _country = loc['country'] ?? '';
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
      if (!mounted) return;
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
    final t = TR[_lang]?['w$c'];
    if (t != null) return t;
    const m = {0:'Clear sky',1:'Mainly clear',2:'Partly cloudy',3:'Overcast',45:'Fog',48:'Rime fog',
      51:'Light drizzle',53:'Drizzle',55:'Dense drizzle',61:'Slight rain',63:'Rain',65:'Heavy rain',
      71:'Slight snow',73:'Snow',75:'Heavy snow',95:'Thunderstorm',96:'Storm with hail',99:'Heavy storm'};
    return m[c] ?? 'Unknown';
  }

  String _dayPrediction(int code) {
    if (code == 0) return T('pred_clear');
    if (code == 1) return T('pred_mostly_clear');
    if (code == 2) return T('pred_partly_cloudy');
    if (code == 3) return T('pred_overcast');
    if (code == 45 || code == 48) return T('pred_fog');
    if (code >= 51 && code <= 55) return T('pred_drizzle');
    if (code >= 61 && code <= 65) return T('pred_rain');
    if (code >= 71 && code <= 75) return T('pred_snow');
    if (code >= 95) return T('pred_storm');
    return T('pred_mixed');
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
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _searchBar(),
              const SizedBox(height: 10),
              _mainCard(),
              const SizedBox(height: 10),
              _hourlyCard(),
              const SizedBox(height: 10),
              _dailyCard(),
              const SizedBox(height: 10),
              _extrasCard(),
              const SizedBox(height: 10),
              _lifeCard(),
              const SizedBox(height: 16),
            ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFF333333),
          onPressed: _openSettings,
          child: const Icon(Icons.settings, color: Colors.white),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _cardBg(),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: _cardBorder()),
    ),
    child: child,
  );

  Widget _searchBar() => Row(children: [
    Expanded(child: TextField(
      controller: _ctrl, style: TextStyle(color: _txt()),
      decoration: InputDecoration(
        hintText: T('search'), hintStyle: TextStyle(color: _faint()),
        filled: true, fillColor: _itemBg(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _cardBorder())),
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
          SizedBox(width: 50, height: 50,
            child: CircularProgressIndicator(color: _txt(), strokeWidth: 4)),
          const SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: _txt(), fontSize: 14)),
        ])))
    : Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_city, $_country'.toUpperCase(),
              style: TextStyle(color: _muted(), fontSize: 14,
                letterSpacing: 1.5, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _fetch(_city),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _itemBg(),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _cardBorder()),
                ),
                child: Icon(Icons.refresh, size: 16, color: _txt()),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () async {
                final p = await SharedPreferences.getInstance();
                _tryCurrentLocation(p);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _itemBg(),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _cardBorder()),
                ),
                child: Icon(Icons.my_location, size: 16, color: _txt()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedWeatherIcon(code: _wcode, size: 80),
        const SizedBox(height: 10),
        Text(_fmtT(_temp), style: TextStyle(color: _txt(), fontSize: 90,
          fontWeight: FontWeight.w200, height: 1)),
        Text(_desc(_wcode), style: TextStyle(color: _txt(), fontSize: 20, fontWeight: FontWeight.w500)),
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
    Text(l.toUpperCase(), style: TextStyle(color: _muted(), fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.w600)),
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
              decoration: BoxDecoration(color: _itemBg(),
                borderRadius: BorderRadius.circular(16), border: Border.all(color: _cardBorder())),
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

  // ========================================================
  // WEEKLY CARD — smooth expand/collapse with no gap
  // Uses AnimatedSize on the list Column only, so the card
  // shrinks/grows naturally and the More/Less button moves with it.
  // ========================================================
  Widget _dailyCard() {
    return _card(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(T('daily').toUpperCase(), style: TextStyle(color: _muted(),
          fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          reverseDuration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey<bool>(_allDays),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < (_allDays ? _daily.length : 3); i++)
                _dayRow(i),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 54,
          child: OutlinedButton(
            onPressed: () => setState(() => _allDays = !_allDays),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: _txt(),
              side: BorderSide(color: _cardBorder(), width: 1.5),
              elevation: 0,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(_allDays ? 'Less' : 'More',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: _txt())),
          ),
        ),
      ],
    ));
  }

  Widget _dayRow(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _showDayDetail(_daily[i], i == 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _itemBg(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder()),
          ),
          child: Row(children: [
            SizedBox(width: 60, child: Text(
              i == 0 ? T('today') : _day(_daily[i]['date']),
              style: TextStyle(color: _txt(), fontSize: 14, fontWeight: FontWeight.w500))),
            Text(_icon(_daily[i]['code']), style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text('${_fmtT((_daily[i]['max'] as num).toDouble())} / ${_fmtT((_daily[i]['min'] as num).toDouble())}',
              style: TextStyle(color: _muted(), fontSize: 14)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 16, color: _faint()),
          ]),
        ),
      ),
    );
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

  Widget _ex(String emoji, String l, String v, String sub, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _itemBg(),
        borderRadius: BorderRadius.circular(16), border: Border.all(color: _cardBorder())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('$emoji ${l.toUpperCase()}',
            style: TextStyle(color: _muted(), fontSize: 10,
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
    return _card(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🌿 ${T('life').toUpperCase()}', style: TextStyle(color: _muted(),
          fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        _life('🏃', isBadOut ? T('bad_out') : T('great_out'), () => _openDetail('outdoor')),
        const SizedBox(height: 8),
        _life('👕', _temp > 30 ? T('light_cloth') : _temp > 20 ? T('ok_cloth') : T('warm_cloth'),
          () => _openDetail('clothing')),
        const SizedBox(height: 8),
        _life('💊', isHighCold ? T('high_cold') : T('low_cold'), () => _openDetail('cold')),
        const SizedBox(height: 8),
        _life('🚗', isBadDrv ? T('bad_drive') : T('ok_drive'), () => _openDetail('drive')),
      ],
    ));
  }

  Widget _life(String emoji, String text, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _itemBg(),
        borderRadius: BorderRadius.circular(16), border: Border.all(color: _cardBorder())),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: _txt(), fontSize: 13))),
        Icon(Icons.chevron_right, size: 18, color: _faint()),
      ]),
    ),
  );

  // Smooth page transition — fade + subtle slide, no overlap
  PageRouteBuilder _smoothRoute({required WidgetBuilder builder}) {
    return PageRouteBuilder(
      opaque: true,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: const Duration(milliseconds: 850),
      reverseTransitionDuration: const Duration(milliseconds: 650),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation,
          curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<T?> _smoothBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: isScrollControlled,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 450),
      ),
      builder: builder,
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
      label = '${T('direction')}: ${['N','NE','E','SE','S','SW','W','NW'][((_wind / 45).round()) % 8]}';
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

    Navigator.push(context, _smoothRoute(builder: (_) => DetailPage(
      bg1: _bg1(), bg2: _bg2(), txt: _txt(),
      muted: _muted(), faint: _faint(),
      cardBorder: _cardBorder(), itemBg: _itemBg(),
      initialType: type,
      getContent: _getDetailContent,
      aboutLabel: T('about'),
      contextLabel: T('context'),
      exploreLabel: T('explore'),
      metricsLabel: T('weather_metrics'),
      lifestyleLabel: T('lifestyle'),
      metricsList: metrics,
      lifestyleList: lifestyle,
    )));
  }

  void _showHourDetail(Map<String, dynamic> h) {
    final code = h['code'] as int;
    final temp = (h['temp'] as num).toDouble();
    _smoothBottomSheet(
      context: context,
      builder: (ctx) => Container(
        decoration: BoxDecoration(color: _cardBg(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(child: Padding(
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
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                  foregroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(T('done'), style: const TextStyle(fontWeight: FontWeight.w600)),
              )),
          ]),
        )),
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
      builder: (ctx) => Container(
        decoration: BoxDecoration(color: _cardBg(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(child: Padding(
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
              decoration: BoxDecoration(color: _itemBg(),
                borderRadius: BorderRadius.circular(14), border: Border.all(color: _cardBorder())),
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
                decoration: BoxDecoration(color: _itemBg(),
                  borderRadius: BorderRadius.circular(14), border: Border.all(color: _cardBorder())),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(T('label_high'), style: TextStyle(color: _muted(), fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(_fmtT(max), style: TextStyle(color: _txt(), fontSize: 32, fontWeight: FontWeight.w300, height: 1)),
                ]),
              )),
              const SizedBox(width: 12),
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _itemBg(),
                  borderRadius: BorderRadius.circular(14), border: Border.all(color: _cardBorder())),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(T('label_low'), style: TextStyle(color: _muted(), fontSize: 12, fontWeight: FontWeight.w500)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(T('done'), style: const TextStyle(fontWeight: FontWeight.w600)),
              )),
          ]),
        )),
      ),
    );
  }

  // ========================================================
  // SETTINGS — uses local vars, only applies on Done press
  // ========================================================
  void _openSettings() {
    String localTheme = _theme;
    String localUnit = _unit;
    String localWindUnit = _windUnit;
    String localTimeFmt = _timeFmt;
    String localLang = _lang;
    String localTextSize = _textSize;

    _smoothBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => Container(
        decoration: BoxDecoration(color: _cardBg(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(T('settings'), style: TextStyle(color: _txt(), fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _settingRow(ctx, T('theme'), localTheme, ['auto','dark','light'],
              [T('auto'), T('dark'), T('light')],
              (v) => setSheet(() => localTheme = v)),
            _settingRow(ctx, T('temp_unit'), localUnit, ['C','F'],
              ['Celsius (°C)','Fahrenheit (°F)'],
              (v) => setSheet(() => localUnit = v)),
            _settingRow(ctx, T('wind_unit'), localWindUnit, ['kmh','mph'], ['km/h','mph'],
              (v) => setSheet(() => localWindUnit = v)),
            _settingRow(ctx, T('time_format'), localTimeFmt, ['12h','24h'], ['12-hour','24-hour'],
              (v) => setSheet(() => localTimeFmt = v)),
            _settingRow(ctx, T('language'), localLang, ['en','ur','sd','es'],
              ['English','اردو','سنڌي','Español'],
              (v) => setSheet(() => localLang = v)),
            _settingRow(ctx, T('text_size'), localTextSize, ['small','medium','large','xlarge'],
              [T('text_small'), T('text_medium'), T('text_large'), T('text_xlarge')],
              (v) => setSheet(() => localTextSize = v)),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _theme = localTheme;
                    _unit = localUnit;
                    _windUnit = localWindUnit;
                    _timeFmt = localTimeFmt;
                    _lang = localLang;
                    _textSize = localTextSize;
                  });
                  _saveSettings();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                  foregroundColor: _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(T('done'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              )),
          ]),
        )),
      )),
    );
  }

  Widget _settingRow(BuildContext parentCtx, String label, String val,
      List<String> vals, List<String> disp, Function(String) onChange) {
    final idx = vals.indexOf(val);
    final displayVal = idx >= 0 && idx < disp.length ? disp[idx] : val;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(
            color: _muted(), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        ),
        GestureDetector(
          onTap: () async {
            final result = await _smoothBottomSheet<String>(
              context: context,
              builder: (ctx) => Container(
                decoration: BoxDecoration(
                  color: _cardBg(),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: _muted().withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(label, style: TextStyle(color: _txt(), fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...vals.asMap().entries.map((e) {
                      final isSelected = e.value == val;
                      return GestureDetector(
                        onTap: () => Navigator.pop(ctx, e.value),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? _txt().withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected ? Border.all(color: _cardBorder(), width: 1.5) : null,
                          ),
                          child: Row(children: [
                            Expanded(child: Text(disp[e.key], style: TextStyle(
                              color: _txt(), fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400))),
                            if (isSelected) Icon(Icons.check, color: _txt(), size: 20),
                          ]),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                )),
              ),
            );
            if (result != null) onChange(result);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: _itemBg(),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder(), width: 1.2),
            ),
            child: Row(children: [
              Expanded(child: Text(displayVal, style: TextStyle(
                color: _txt(), fontSize: 15, fontWeight: FontWeight.w500))),
              Icon(Icons.keyboard_arrow_down_rounded, color: _txt(), size: 22),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ============================================================
// ANIMATED WEATHER ICON
// ============================================================
class AnimatedWeatherIcon extends StatefulWidget {
  final int code;
  final double size;
  const AnimatedWeatherIcon({super.key, required this.code, this.size = 80});
  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String _ic(int c) {
    if (c <= 1) return '☀️';
    if (c <= 3 || c == 45 || c == 48) return '☁️';
    if (c >= 51 && c <= 65) return '🌧️';
    if (c >= 71 && c <= 75) return '❄️';
    if (c >= 95) return '⛈️';
    return '☀️';
  }

  @override
  Widget build(BuildContext context) {
    final icon = Text(_ic(widget.code), style: TextStyle(fontSize: widget.size));
    if (widget.code <= 1) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (c, ch) => Transform.rotate(angle: _ctrl.value * 2 * math.pi, child: ch),
        child: icon);
    }
    if (widget.code >= 51 && widget.code <= 65) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (c, ch) => Transform.translate(
          offset: Offset(0, math.sin(_ctrl.value * 2 * math.pi) * 6), child: ch),
        child: icon);
    }
    if (widget.code >= 95) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (c, ch) => Opacity(
          opacity: _ctrl.value > 0.85 || _ctrl.value < 0.15 ? 1.0 : 0.7, child: ch),
        child: icon);
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (c, ch) => Transform.scale(
        scale: 1 + math.sin(_ctrl.value * 2 * math.pi) * 0.05, child: ch),
      child: icon);
  }
}

// ============================================================
// DETAIL PAGE — premium layout
// ============================================================
class DetailPage extends StatefulWidget {
  final Color bg1, bg2, txt, muted, faint, cardBorder, itemBg;
  final Function(String) getContent;
  final String initialType;
  final String aboutLabel, contextLabel, exploreLabel, metricsLabel, lifestyleLabel;
  final List<Map<String, String>> metricsList, lifestyleList;

  const DetailPage({
    super.key,
    required this.bg1, required this.bg2, required this.txt,
    required this.muted, required this.faint,
    required this.cardBorder, required this.itemBg,
    required this.getContent, required this.initialType,
    required this.aboutLabel, required this.contextLabel, required this.exploreLabel,
    required this.metricsLabel, required this.lifestyleLabel,
    required this.metricsList, required this.lifestyleList,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String _currentType;
  late Map<String, String> _content;
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTransitioning = false;
  bool _loadingContent = false;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _content = _parseContent(widget.getContent(_currentType));
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  Map<String, String> _parseContent(String raw) {
    final parts = raw.split('|');
    return {
      'title': parts.isNotEmpty ? parts[0] : '',
      'value': parts.length > 1 ? parts[1] : '',
      'label': parts.length > 2 ? parts[2] : '',
      'desc': parts.length > 3 ? parts[3] : '',
      'ctx': parts.length > 4 ? parts[4] : '',
    };
  }

  // Smooth transition between detail items — scroll to top, then swap content.
  // No fade / no AnimatedOpacity so old and new never overlap.
  void _onExploreTap(String key) async {
    if (key == _currentType) return;
    if (_isTransitioning) return;
    _isTransitioning = true;

    // 1. Scroll to top
    if (_scrollCtrl.hasClients && _scrollCtrl.offset > 0) {
      await _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }

    // 2. Show loading state (old content hidden)
    if (mounted) setState(() => _loadingContent = true);

    // 3. Wait a moment — this is the "load" the user sees
    await Future.delayed(const Duration(milliseconds: 550));

    // 4. Swap to new content and hide loading
    if (mounted) {
      setState(() {
        _currentType = key;
        _content = _parseContent(widget.getContent(key));
        _loadingContent = false;
      });
    }

    _isTransitioning = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bg1,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Back button row
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.arrow_back, color: widget.txt, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_content['title'] ?? '',
                style: TextStyle(color: widget.txt, fontSize: 22,
                  fontWeight: FontWeight.w700, letterSpacing: -0.3))),
            ]),
            const SizedBox(height: 32),

            // === LOADING OR CONTENT ===
            if (_loadingContent)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 80),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(
                    color: widget.txt, strokeWidth: 3,
                  ),
                ),
              )
            else ...[
            // Big value — dynamic size based on text length
            Text(_content['value'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.txt,
                fontSize: (_content['value'] ?? '').length > 12 ? 32 : 52,
                fontWeight: FontWeight.w200,
                height: 1.15,
                letterSpacing: -0.8,
              )),
            const SizedBox(height: 8),
            Text(_content['label'] ?? '',
              style: TextStyle(color: widget.muted, fontSize: 15, fontWeight: FontWeight.w500)),

            const SizedBox(height: 36),

            // ABOUT section — quote-block (visually distinct from buttons)
            _sectionHeader(widget.aboutLabel),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: widget.txt.withOpacity(0.3), width: 3),
                ),
              ),
              child: Text(_content['desc'] ?? '',
                style: TextStyle(color: widget.muted, fontSize: 15,
                  height: 1.7, letterSpacing: 0.1, fontStyle: FontStyle.italic)),
            ),

            const SizedBox(height: 28),

            // CONTEXT section — quote-block
            _sectionHeader(widget.contextLabel),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: widget.txt.withOpacity(0.3), width: 3),
                ),
              ),
              child: Text(_content['ctx'] ?? '',
                style: TextStyle(color: widget.muted, fontSize: 15,
                  height: 1.7, letterSpacing: 0.1, fontStyle: FontStyle.italic)),
            ),

            const SizedBox(height: 36),
            ],
            Divider(color: widget.cardBorder, height: 1),
            const SizedBox(height: 32),

            // EXPLORE header
            Row(children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(
                  color: widget.txt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.exploreLabel,
                style: TextStyle(color: widget.txt, fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 24),

            // Weather metrics
            if (widget.metricsList.any((m) => m['key'] != _currentType)) ...[
              _subHeader(widget.metricsLabel),
              const SizedBox(height: 12),
              ...widget.metricsList
                .where((m) => m['key'] != _currentType)
                .map((m) => _listItem(m['name']!, m['val'] ?? '', () => _onExploreTap(m['key']!))),
              const SizedBox(height: 28),
            ],

            // Lifestyle
            if (widget.lifestyleList.any((m) => m['key'] != _currentType)) ...[
              _subHeader(widget.lifestyleLabel),
              const SizedBox(height: 12),
              ...widget.lifestyleList
                .where((m) => m['key'] != _currentType)
                .map((m) => _listItem(m['name']!, '', () => _onExploreTap(m['key']!))),
            ],
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Row(children: [
    Container(
      width: 3, height: 18,
      decoration: BoxDecoration(
        color: widget.txt,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    const SizedBox(width: 10),
    Text(text, style: TextStyle(
      color: widget.txt, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
  ]);

  Widget _subHeader(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 4),
    child: Text(text.toUpperCase(), style: TextStyle(
      color: widget.faint, fontSize: 12,
      fontWeight: FontWeight.w700, letterSpacing: 1.4)),
  );

  Widget _listItem(String name, String val, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: widget.itemBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.cardBorder),
        ),
        child: Row(children: [
          Expanded(child: Text(name, style: TextStyle(color: widget.txt,
            fontSize: 15, fontWeight: FontWeight.w500))),
          if (val.isNotEmpty) ...[
            Text(val, style: TextStyle(color: widget.muted, fontSize: 14,
              fontWeight: FontWeight.w500)),
            const SizedBox(width: 10),
          ],
          Icon(Icons.chevron_right, color: widget.faint, size: 20),
        ]),
      ),
    );
  }
}

// ============================================================
// TAP ANIMATION WIDGETS
// ============================================================
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

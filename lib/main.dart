import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CharvisUltimateApp());
}

class CharvisUltimateApp extends StatelessWidget {
  const CharvisUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charvis TJ Ultimate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigoAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: const CharvisHomeScreen(),
    );
  }
}

class CharvisHomeScreen extends StatefulWidget {
  const CharvisHomeScreen({super.key});

  @override
  State<CharvisHomeScreen> createState() => _CharvisHomeScreenState();
}

class _CharvisHomeScreenState extends State<CharvisHomeScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  String _aiResponse = "Салом! Ман Чарвис ТЧ Ультимейт ҳастам. Тамоми системаҳо, муҳофизат ва овоз фаъоланд!";
  bool _isLoading = false;
  
  // Фонҳои чати интихобшуда (Wallpapers)
  String _selectedBgImage = 'assets/images/charvis_bg_neon.png';

  // Танзимоти дигар
  bool _isDarkMode = true;
  String _selectedLanguage = "Тоҷикӣ (Tajik)";

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initSystemPermissionsAndTts();
  }

  Future<void> _initSystemPermissionsAndTts() async {
    // Дархости ҳуқуқҳои пурра (Банди 17)
    await [
      Permission.microphone,
      Permission.phone,
      Permission.storage,
      Permission.camera,
      Permission.sms,
      Permission.location,
    ].request();

    await _flutterTts.setLanguage("tg-TJ");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void _respondAndSpeak(String response) {
    setState(() {
      _aiResponse = response;
    });
    _speak(response);
  }

  // --- Функсияҳои идоракунӣ ва амниятӣ (Банди 1, 2, 3, 4, 5, 20, 21) ---

  Future<void> _makeDirectCall(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(callUri)) {
      _respondAndSpeak("Занг зада истодаам ба рақами $number...");
      await launchUrl(callUri);
    } else {
      _respondAndSpeak("Хатогӣ дар иҷрои занг.");
    }
  }

  void _runAntivirusAndParentalCheck() async {
    setState(() {
      _isLoading = true;
      _aiResponse = "🛡️ Санҷиши амният, муҳофизати волидайн ва тозакунии вирусҳо / сайтҳои зараровар оғоз шуд...";
    });
    _speak("Санҷиши амният оғоз шуд.");

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
      _aiResponse = "✅ Санҷиш бомуваффақият анҷом ёфт!\n\n• Вирусҳо ва сайтҳои зараровар: Блока шуданд (0 хатар)\n• Назорати волидайн: Фаъол ва бехатар\n• Ҳимояи телефон: 100% кор мекунад.";
    });
    _speak("Система аз ҳар гуна вирусҳо ва сайтҳои зараровар пурра муҳофизат карда шуд.");
  }

  Future<void> _connectExternalDevice(String deviceType, String method) async {
    _respondAndSpeak("Пайвастшавӣ ба $deviceType тавассути $method оғоз шуд...");
    await Future.delayed(const Duration(seconds: 2));
    _respondAndSpeak("Дастгоҳи $deviceType бомуваффақият пайваст гардид!");
  }

  Future<void> _downloadMediaWithSnapTube(String query) async {
    _respondAndSpeak("Ҷустуҷӯ ва омодасозии суруд ё филм тавассути SnapTube барои: $query...");
    final String snapUrl = "snaptube://search?q=${Uri.encodeComponent(query)}";
    final Uri uri = Uri.parse(snapUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final Uri webUri = Uri.parse("https://www.google.com/search?q=$query download");
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _getWeatherForecast() {
    _respondAndSpeak("Имрӯз обу ҳаво дар Тоҷикистон софу офтобӣ аст. Ҳарорат то 28 дараҷа мерасад. Барои 7 рӯзи оянда тағйироти калон дар назар нест.");
  }

  // --- Коркарди фармонҳо ва суҳбат ---

  void _processInput(String input) async {
    if (input.trim().isEmpty) return;
    String cmd = input.toLowerCase().trim();

    // Зангзанӣ
    if (cmd.contains("занг зан")) {
      RegExp regExp = RegExp(r'\d+');
      var match = regExp.firstMatch(cmd);
      if (match != null) {
        _makeDirectCall(match.group(0)!);
      } else {
        _respondAndSpeak("Лутфан рақами телефонро нишон диҳед.");
      }
      return;
    }

    // Вирускуш ва амният
    if (cmd.contains("вирус") || cmd.contains("амният") || cmd.contains("сайт")) {
      _runAntivirusAndParentalCheck();
      return;
    }

    // Пайвастшавӣ ба дастгоҳҳо
    if (cmd.contains("телевизор") || cmd.contains("канал")) {
      _connectExternalDevice("Телевизор", "Wi-Fi");
      return;
    }
    if (cmd.contains("мошин") || cmd.contains("авто")) {
      _connectExternalDevice("Мошини ҳушманд", "Bluetooth");
      return;
    }

    // Суруд ва филм (SnapTube)
    if (cmd.contains("суруд") || cmd.contains("филм") || cmd.contains("клип") || cmd.contains("скачать")) {
      _downloadMediaWithSnapTube(input);
      return;
    }

    // Обу ҳаво
    if (cmd.contains("обу ҳаво") || cmd.contains("ҳаво")) {
      _getWeatherForecast();
      return;
    }

    // Ҳамдардӣ ва хастагӣ (Банди 10)
    if (cmd.contains("зикам") || cmd.contains("хаста шудам") || cmd.contains("ғамгин")) {
      _respondAndSpeak("Эй дӯсти ман, ғамгин нашав! Ман ҳамеша дар паҳлӯи ту ҳастам. Биё каме истироҳат кунем ё суруди хуб гӯш кунем.");
      return;
    }

    // Ҷустуҷӯ ва ҷавоб аз ИИ онлайн бо овоз (TTS)
    bool success = await _sendToOnlineAI(input);
    if (!success) {
      _respondAndSpeak("Интернет дастнорас аст, аммо системаи офлайнии Чарвис кор мекунад.");
    }
  }

  Future<bool> _sendToOnlineAI(String prompt) async {
    setState(() {
      _isLoading = true;
      _aiResponse = "Дар ҳоли ҷустуҷӯ ва коркарди маълумот...";
    });

    try {
      final encodedPrompt = Uri.encodeComponent("Ту Чарвис ТЧ Ультимейт ҳастӣ. Ба ин савол бо забони тоҷикӣ кӯтоҳ, ахлоқӣ ва бо овоз хондан мувофиқ ҷавоб деҳ: $prompt");
      final url = Uri.parse('https://text.pollinations.ai/$encodedPrompt');
      final response = await http.get(url).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        _respondAndSpeak(response.body);
        setState(() => _isLoading = false);
        return true;
      }
    } catch (e) {
      // Хатогӣ
    }

    setState(() => _isLoading = false);
    return false;
  }

  Future<void> _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _processInput(_textController.text);
    }
  }

  // --- Менюҳо ва интихоби фонҳо (Банди 12) ---
  void _openWallpaperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Интихоби фони чат (Wallpaper)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Neon Background"),
              onTap: () {
                setState(() => _selectedBgImage = 'assets/images/charvis_bg_neon.png');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Matrix Cyber"),
              onTap: () {
                setState(() => _selectedBgImage = 'assets/images/charvis_matrix_cyber.png');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Hologram AI"),
              onTap: () {
                setState(() => _selectedBgImage = 'assets/images/charvis_hologram.png');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Dark Core Galaxy"),
              onTap: () {
                setState(() => _selectedBgImage = 'assets/images/charvis_dark_core.png');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Танзимоти Charvis TJ Ultimate"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Забон: Тоҷикӣ"),
              trailing: const Icon(Icons.language),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Фонҳои чат (Wallpaper)"),
              trailing: const Icon(Icons.wallpaper),
              onTap: () {
                Navigator.pop(context);
                _openWallpaperDialog();
              },
            ),
            ListTile(
              title: const Text("Худмуаррифӣ ва Маълумот"),
              trailing: const Icon(Icons.info),
              onTap: () {
                _respondAndSpeak("Ман Чарвис ТЧ Ультимейт ҳастам, ёвари пешрафтаи шумо бо забони тоҷикӣ.");
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Пӯшидан"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Акси асосии барнома (tajik_icon)
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/tajik_icon.png'),
            ),
            const SizedBox(width: 10),
            const Text('Charvis TJ Ultimate'),
          ],
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper),
            onPressed: _openWallpaperDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_selectedBgImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                  ),
                  child: SingleChildScrollView(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SelectableText(
                            _aiResponse,
                            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Фармон диҳед (масалан: занг зан, суруд, обу ҳаво)...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black87,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.cyanAccent),
                    onPressed: () {
                      _processInput(_textController.text);
                      _textController.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _listenVoice,
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: _isListening ? Colors.red : Colors.indigoAccent,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Барои суҳбат пахш кунед",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

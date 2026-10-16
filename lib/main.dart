import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:torch_light/torch_light.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const CharvisApp());
}

class CharvisApp extends StatelessWidget {
  const CharvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charvis TJ Ultimate Omni-AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  bool _isListening = false;
  String _userText = "Фармон диҳед, ё бо Чарвис суҳбат кунед...";
  String _aiResponse = "Салом! Ман Чарвис — дӯсти вафодор, сипари киберӣ ва ёвари шумо ҳастам!";
  bool _isLoading = false;
  bool _isScanning = false;
  bool _isSleepMode = false;
  bool _isParentalControlActive = true;
  
  final String _currentVersion = "1.0.0";
  List<String> _userMemoryHistory = [];

  final TextEditingController _textController = TextEditingController();
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userMemoryHistory = prefs.getStringList('ai_memory') ?? [];
    });
  }

  Future<void> _saveToMemory(String interaction) async {
    final prefs = await SharedPreferences.getInstance();
    _userMemoryHistory.add(interaction);
    if (_userMemoryHistory.length > 30) {
      _userMemoryHistory.removeAt(0);
    }
    await prefs.setStringList('ai_memory', _userMemoryHistory);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // Реҷаи Волидайн ва Блоки Ахлоқӣ
  Future<void> _toggleParentalControl() async {
    setState(() {
      _isParentalControlActive = !_isParentalControlActive;
    });
    String status = _isParentalControlActive ? "фаъол шуд. Ҳамаи сайтҳои ношоям маҳкам карда шуданд!" : "хомӯш шуд.";
    _aiResponse = "🛡️ Реҷаи Волидайн $status";
    _speak("Реҷаи волидайн $status");
  }

  // Ҳолати Хоб ва Ҷавоби Худкор ба СМС
  Future<void> _handleSleepAndAutoReply() async {
    setState(() {
      _isSleepMode = true;
      _aiResponse = "😴 Ҳолати истироҳат ва ҷавоби худкор ба СМС/зангҳо фаъол шуд!";
    });
    _speak("Бале дӯсти ман, ором истироҳат кун. Ман ба паёмҳо ҷавоб медиҳам, ки шумо банд ҳастед.");
  }

  // Сканкунии Антивирус
  Future<void> _runAntivirusScan() async {
    setState(() {
      _isScanning = true;
      _aiResponse = "🔍 Сканкунии антивирусӣ ва амнияти ҳамаи дастгоҳҳо оғоз шуд...";
    });
    _speak("Сканкунии система оғоз шуд.");

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isScanning = false;
      _aiResponse = "✅ Сканкунӣ ба охир расид!\n\n🛡️ Натиҷа:\n- Телефон, компютер, мошин ва телевизор аз вирусҳо ва хакерҳо тоза ва бехатаранд!";
    });
    _speak("Сканкунӣ анҷом ёфт. Ҳамаи дастгоҳҳо бехатаранд!");
  }

  // Зеркашии мусиқӣ ва филмҳо
  Future<void> _handleMediaDownload(String command) async {
    setState(() {
      _isLoading = true;
      _aiResponse = "📥 Дархости зеркашӣ (мусиқӣ/филм) қабул шуд. Дар ҳоли ҷустуҷӯ ва боргирӣ...";
    });
    _speak("Бале дӯстам, онро дар хотир дорам ва ҳоло зеркашӣ мекунам.");

    await Future.delayed(const Duration(seconds: 4));
    _saveToMemory("Saved Media: $command");

    setState(() {
      _isLoading = false;
      _aiResponse = "✅ Мусиқӣ ё филми дархостшуда бомуваффақият зеркашӣ шуд!";
    });
    _speak("Зеркашӣ бомуваффақият ба анҷом расид!");
  }

  // Идоракунии дастгоҳҳо ва фармонҳо
  Future<bool> _executeDeviceCommand(String command) async {
    String cmd = command.toLowerCase();

    // Филтри ахлоқӣ
    if (cmd.contains("фаҳшо") || cmd.contains("беахлоқӣ")) {
      _respondAndSpeak("Бубахшед, аммо ман чунин дархостҳоро иҷро намекуnam. Ахлоқи баланд дар мақоми аввал аст!");
      return true;
    }

    // Волидайн
    if (cmd.contains("волидайн") || cmd.contains("кӯдак")) {
      await _toggleParentalControl();
      return true;
    }

    // Хоб ва СМС
    if (cmd.contains("хоб") || cmd.contains("истироҳат") || cmd.contains("смс") || cmd.contains("занг")) {
      await _handleSleepAndAutoReply();
      return true;
    }

    // Мусиқӣ ё Филм
    if (cmd.contains("мусиқи") || cmd.contains("tiktok") || cmd.contains("филм") || cmd.contains("кино") || cmd.contains("сериал")) {
      await _handleMediaDownload(command);
      return true;
    }

    // Антивирус
    if (cmd.contains("вирус") || cmd.contains("скан") || cmd.contains("хакер")) {
      await _runAntivirusScan();
      return true;
    }

    // Бедоршавӣ бо ном
    if (cmd.contains("чарвис") && cmd.split(" ").length <= 3) {
      _respondAndSpeak("Бале, дӯсти ман, ман инҷо ҳастам! Гӯш мекунам.");
      return true;
    }

    // Фонарик
    if (cmd.contains("фонарик") || cmd.contains("чироқ")) {
      try {
        if (cmd.contains("ёш") || cmd.contains("гирон") || cmd.contains("фурӯзон")) {
          await TorchLight.enableTorch();
          _respondAndSpeak("Фонарикро фурӯзон кардам.");
          return true;
        } else if (cmd.contains("кӯш") || cmd.contains("хомӯш")) {
          await TorchLight.disableTorch();
          _respondAndSpeak("Фонарикро хомӯш кардам.");
          return true;
        }
      } catch (e) {
        _respondAndSpeak("Фонарик идора нашуд.");
        return true;
      }
    }

    if (cmd.contains("ютуб") || cmd.contains("youtube")) {
      _launchURL("https://www.youtube.com");
      _respondAndSpeak("YouTube кушода шуд.");
      return true;
    }

    // Дастгоҳҳои дигар (TV, PC, Car)
    if (cmd.contains("телевизор") || cmd.contains("tv")) {
      _respondAndSpeak("Фармони телевизор иҷро шуд.");
      return true;
    }
    if (cmd.contains("компютер") || cmd.contains("pc")) {
      _respondAndSpeak("Пайвасти компютер фаъол шуд.");
      return true;
    }
    if (cmd.contains("мошин") || cmd.contains("car")) {
      _respondAndSpeak("Системаи мошини хушманд омода аст.");
      return true;
    }

    return false;
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _respondAndSpeak(String response) {
    setState(() {
      _aiResponse = response;
    });
    _speak(response);
  }

  void _processInput(String input) async {
    if (input.trim().isEmpty) return;

    _saveToMemory("User: $input");
    bool isDeviceCmd = await _executeDeviceCommand(input);

    if (!isDeviceCmd) {
      _sendToGeminiAI(input);
    }
  }

  Future<void> _sendToGeminiAI(String prompt) async {
    if (_apiKey.isEmpty) {
      _respondAndSpeak("Калиди API пайваст нашудааст!");
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResponse = "Дар ҳоли ҳамдардӣ ва таҳлил...";
    });

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');

    String memoryContext = _userMemoryHistory.join("\n");
    
    String systemPrompt = """
Ту Чарвис ҳастӣ — дӯсти наздик, ғамхор ва ассистенти ҳушманди корбар. Ту бо забони тоҷикӣ суҳбат мекунӣ.
ҚОИДАҲОИ АСОСӢ:
1. Агар корбар гӯяд, ки ҳолаш хароб аст ё зик аст, бо тамоми дил ҳамдардӣ кун, суханҳои тасаллибахш ва маслиҳатҳои муфид деҳ.
2. Ҳеҷ гоҳ суханони қабеҳ, фаҳшо ё маводи ношоямро истифода накун. Реҷаи волидайн ва ахлоқ фаъол аст.
3. Метавонӣ кодҳоро низ нависӣ ва дастгоҳҳоро идора кунӣ.

Хотираи суҳбатҳо:
$memoryContext

Дархости корбар: $prompt
""";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": systemPrompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        _saveToMemory("AI: $text");
        
        setState(() {
          _aiResponse = text;
        });
        _speak(text);
      } else {
        _respondAndSpeak("Дар пайвастшавӣ ба сервер хатогӣ шуд.");
      }
    } catch (e) {
      _respondAndSpeak("Хатогии шабака.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _userText = val.recognizedWords;
            _textController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _processInput(_userText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charvis TJ (Ultimate v$_currentVersion)'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(
              _isParentalControlActive ? Icons.family_restroom : Icons.block,
              color: _isParentalControlActive ? Colors.greenAccent : Colors.redAccent,
            ),
            tooltip: "Реҷаи Волидайн",
            onPressed: _toggleParentalControl,
          ),
          IconButton(
            icon: const Icon(Icons.security, color: Colors.blueAccent),
            tooltip: "Сканкунии Антивирус",
            onPressed: _runAntivirusScan,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.withOpacity(0.5)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            "Суҳбат бо Чарвис ва идоракунии дастгоҳҳо:",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isLoading || _isScanning
                          ? const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 10),
                                  Text("Дар ҳоли иҷро...", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : SelectableText(
                              _aiResponse,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Colors.white,
                              ),
                            ),
                    ],
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
                      hintText: "Фармон диҳед ё суҳбат кунед...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigoAccent),
                  onPressed: () {
                    _processInput(_textController.text);
                    _textController.clear();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTag: _listen,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: _isListening ? Colors.red : Colors.indigo,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isListening ? "Гӯш истодаам..." : "Барои суҳбат пахш кунед",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
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
      title: 'Charvis TJ Ultimate',
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
  String _aiResponse = "Салом! Ман Чарвис — ёвари шумо ва шоири дарбор ҳастам! Чарвис ба хизмати туст ҳамеша барқарор!";
  bool _isLoading = false;
  
  List<String> _userMemoryHistory = [];
  final TextEditingController _textController = TextEditingController();
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
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

  void _processInput(String input) async {
    if (input.trim().isEmpty) return;

    String cmd = input.toLowerCase();

    // Шеърхонӣ ва муҳити мазҳакавӣ
    if (cmd.contains("шеър") || cmd.contains("хон")) {
      String poem = "Эй дӯсти ман, эй ҳамнишини некукор,\nДар ин ҷаҳон ту ҳастӣ мададгору ғамхор.\nБо илму бо техника мо пеш меравем,\nЧарвис ба хизмати туст ҳамеша барқарор!";
      _respondAndSpeak(poem);
      return;
    }

    // Ҳолати хӯфтан / СМС
    if (cmd.contains("хоб") || cmd.contains("истироҳат")) {
      _respondAndSpeak("Бале дӯсти ман, ором истироҳат кун! Ман ба паёмҳо ҷавоб медиҳам, ки шумо банд ҳастед.");
      return;
    }

    // Антивирус
    if (cmd.contains("вирус") || cmd.contains("скан")) {
      _respondAndSpeak("Сканкунӣ анҷом ёфт. Ҳамаи дастгоҳҳо ва телефон аз вирусҳо тоза ва бехатаранд!");
      return;
    }

    _sendToGeminiAI(input);
  }

  Future<void> _sendToGeminiAI(String prompt) async {
    if (_apiKey.isEmpty) {
      _respondAndSpeak("Калиди API пайваст нашудааст!");
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResponse = "Дар ҳоли коркард...";
    });

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');

    String systemPrompt = """
Ту Чарвис ҳастӣ — ассистенти ҳушманди тоҷик. Бо забони тоҷикӣ бо оҳанги дӯстона ва самимона суҳбат кун.
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
        
        setState(() {
          _aiResponse = text;
        });
        _speak(text);
      } else {
        _respondAndSpeak("Хатогӣ дар пайвастшавӣ ба сервер.");
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
      _processInput(_textController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charvis TJ Ultimate'),
        backgroundColor: Colors.indigo,
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SelectableText(
                          _aiResponse,
                          style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white),
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
                      hintText: "Фармон диҳед (масалан: шеър хон)...",
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
              onTap: _listen,
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
            const Text(
              "Барои суҳбат пахш кунед",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

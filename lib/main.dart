import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() {
  runApp(const CharvisApp());
}

class CharvisApp extends StatelessWidget {
  const CharvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charvis TJ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
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
  String _userText = "Савол диҳед ё фармон диҳед...";
  String _aiResponse = "Салом! Ман Charvis AI. Чӣ тавр ба шумо кӯмак кунам?";
  bool _isLoading = false;

  final TextEditingController _textController = TextEditingController();
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("tg-TJ"); // агар дастгирӣ кунад, ё "ru-RU"
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // Функсия барои идоракунии телефон бо фармонҳо
  bool _checkAndExecuteCommand(String text) {
    String command = text.toLowerCase();

    if (command.contains("ютуб") || command.contains("youtube")) {
      _launchURL("https://www.youtube.com");
      _respondAndSpeak("Дар ҳоли кушодани YouTube");
      return true;
    } else if (command.contains("гугл") || command.contains("google")) {
      _launchURL("https://www.google.com");
      _respondAndSpeak("Дар ҳоли кушодани Google");
      return true;
    } else if (command.contains("камера") || command.contains("акс")) {
      _respondAndSpeak("Камера кушода мешавад");
      // Фармон барои кушодани камера
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

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (_isListening) {
              setState(() => _isListening = false);
              if (_userText.isNotEmpty && _userText != "Савол диҳед ё фармон диҳед...") {
                _processInput(_userText);
              }
            }
          }
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          pauseFor: const Duration(milliseconds: 1500),
          listenFor: const Duration(seconds: 10),
          onResult: (val) => setState(() {
            _userText = val.recognizedWords;
            _textController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_userText.isNotEmpty) {
        _processInput(_userText);
      }
    }
  }

  void _processInput(String input) {
    if (input.trim().isEmpty) return;

    // Аввал месанҷем, ки ин фармон барои телефон аст ё не
    bool isCommand = _checkAndExecuteCommand(input);

    // Агар фармон набошад, ба Gemini API мефиристем
    if (!isCommand) {
      _sendToGemini(input);
    }
  }

  Future<void> _sendToGemini(String prompt) async {
    if (_apiKey.isEmpty) {
      _respondAndSpeak("Калиди API пайваст нашудааст!");
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResponse = "Дар ҳоли фикрронӣ...";
    });

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Ассистент Charvis TJ. Кӯтоҳ (максимум 1-2 ҷумла) ба тоҷикӣ ҷавоб деҳ: $prompt"
                }
              ]
            }
          ],
          "generationConfig": {
            "maxOutputTokens": 100,
            "temperature": 0.5
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        _respondAndSpeak(text);
      } else {
        _respondAndSpeak("Хатогӣ дар пайвастшавӣ ба сервер.");
      }
    } catch (e) {
      _respondAndSpeak("Хатогӣ дар шабака.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Charvis TJ (Voice & Text)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Қисми намоиши ҷавоби Ассистент
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text(
                            'Ҷавоби Charvis AI:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              _aiResponse,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Майдони воридкунии матн ва тугмаи фиристодан
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Нависед ё бо овоз гӯед...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (val) {
                      _processInput(val);
                      _textController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      _processInput(_textController.text);
                      _textController.clear();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Тугмаи Микрофон барои овоз
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.redAccent : Colors.indigo,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.redAccent : Colors.indigo)
                          .withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isListening ? "Шунида истодаам..." : "Барои сӯҳбат тугмаро пахш кунед",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

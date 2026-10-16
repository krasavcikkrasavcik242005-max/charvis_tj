import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

void main() {
  runApp(const CharvisApp());
}

class CharvisApp extends StatelessWidget {
  const CharvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Charvis TJ AI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const VoiceAssistantScreen(),
    );
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;
  String _textSpoken = "Барои оғоз тугмаи микрофонро пахш кунед...";
  String _aiResponse = "Charvis AI омода аст... Саволатонро диҳед!";

  final String apiKey = "YOUR_GEMINI_API_KEY";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _askGeminiAI(String prompt) async {
    setState(() {
      _isLoading = true;
      _aiResponse = "Charvis фикр карда истодааст...";
    });

    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Шумо ассистенти овозии ҳушманди тоҷикӣ бо номи 'Charvis TJ' ҳастед. Ба саволи зерин ба забони тоҷикӣ кӯтоҳ, ширин ва бо зеҳни баланд ҷавоб диҳед: $prompt"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiText = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _aiResponse = aiText.trim();
          _isLoading = false;
        });
      } else {
        setState(() {
          _aiResponse = "Хатогӣ дар пайвастшавӣ ба сервер.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Хатогии интернет: $e";
        _isLoading = false;
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) => setState(() => _isListening = false),
      );

      if (available) {
        setState(() {
          _isListening = true; // Исправлено
          _textSpoken = "Гӯш истодаам...";
        });

        _speech.listen(
          onResult: (val) {
            setState(() {
              _textSpoken = val.recognizedWords;
            });
            if (val.recognizedWords.isNotEmpty && val.finalResult) {
              _speech.stop();
              setState(() => _isListening = false);
              _askGeminiAI(_textSpoken);
            }
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charvis TJ (AI Powered)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 6,
              shadowColor: Colors.indigo.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          "Ҷавоби Charvis AI:",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            _aiResponse,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                height: 1.4),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _textSpoken,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _isListening ? Colors.redAccent : Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 95,
                width: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.indigo,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.indigo)
                          .withOpacity(0.5),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              _isListening ? "Сабт шуда истодааст..." : "Барои сӯҳбат тугмаро пахш кунед",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

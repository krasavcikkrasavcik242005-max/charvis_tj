import 'package0package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
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
  bool _isListening = false;
  String _userText = "Барои сӯҳбат тугмаро пахш кунед";
  String _aiResponse = "Салом! Ман Charvis AI. Чӣ тавр ба шумо кӯмак кунам?";
  bool _isLoading = false;

  // Калид мустақиман аз GitHub Secrets сохта мешавад
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (_isListening) {
              setState(() => _isListening = false);
              if (_userText.isNotEmpty && _userText != "Барои сӯҳбат тугмаро пахш кунед") {
                _sendToGemini(_userText);
              }
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          pauseFor: const Duration(milliseconds: 1500),
          listenFor: const Duration(seconds: 10),
          onResult: (val) => setState(() {
            _userText = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_userText.isNotEmpty && _userText != "Барои сӯҳбат тугмаро пахш кунед") {
        _sendToGemini(_userText);
      }
    }
  }

  Future<void> _sendToGemini(String prompt) async {
    if (_apiKey.isEmpty) {
      setState(() {
        _aiResponse = "Калиди API пайваст нашудааст!";
      });
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
                  "text": "Ассистент Charvis TJ. Кӯтоҳ (максимум 1-2 ҷумла) ва фаврӣ ба тоҷикӣ ҷавоб деҳ: $prompt"
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
        setState(() {
          _aiResponse = text;
        });
      } else {
        setState(() {
          _aiResponse = "Хатогӣ дар пайвастшавӣ ба сервер: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Хатогӣ дар шабака ё интернет.";
      });
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
          'Charvis TJ (AI Powered)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
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
                          fontSize: 1

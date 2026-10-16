import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const CharvisApp());
}

class CharvisApp extends StatelessWidget {
  const CharvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Charvis TJ',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
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
  String _textSpoken = "Тугмаро пахш кунед ва гап занед...";
  String _aiResponse = "Ассистент омода аст...";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _processCommand(String command) {
    String lowerCmd = command.toLowerCase();
    String response = "";

    if (lowerCmd.contains("салом") || lowerCmd.contains("привет")) {
      response = "Салом! Шуморо диданам хурсандам. Чӣ хизмат кунам?";
    } else if (lowerCmd.contains("аҳвол") || lowerCmd.contains("как дела")) {
      response = "Шукр, ҳамааш хуб аст. Шумо чӣ хел истодаед?";
    } else if (lowerCmd.contains("соат") || lowerCmd.contains("время")) {
      String timeNow = TimeOfDay.fromDateTime(DateTime.now()).format(context);
      response = "Ҳоло соат $timeNow аст.";
    } else if (lowerCmd.contains("ном") || lowerCmd.contains("кто ты")) {
      response = "Ман Charvis TJ ҳастам, ассистенти овозии шумо.";
    } else {
      response = "Ман инро шунидам: '$command'.";
    }

    setState(() {
      _aiResponse = response;
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textSpoken = val.recognizedWords;
            if (val.recognizedWords.isNotEmpty) {
              _processCommand(_textSpoken);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charvis TJ - Ассистенти Овозӣ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "Ҷавоби Charvis:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _aiResponse,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _textSpoken,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: _isListening ? Colors.redAccent : Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.indigo,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.indigo).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
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
            const SizedBox(height: 30),
            Text(
              _isListening ? "Гӯш истодаам..." : "Барои гап задан пахш кунед",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

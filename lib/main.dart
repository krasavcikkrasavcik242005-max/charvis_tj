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
  String _textSpoken = "Барои оғоз тугмаи микрофонро пахш кунед...";
  String _aiResponse = "Charvis омода аст... Рафиқи шумо онлайн аст!";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Обработка голосовых команд
  void _processCommand(String command) {
    String lowerCmd = command.toLowerCase();
    String response = "";

    if (lowerCmd.contains("салом") || lowerCmd.contains("сал") || lowerCmd.contains("привет")) {
      response = "Салом! Шуморо диданам хеле хурсандам. Имрӯз ба шумо чӣ гуна кӯмак расонам?";
    } else if (lowerCmd.contains("аҳвол") || lowerCmd.contains("хол") || lowerCmd.contains("как дела")) {
      response = "Шукр, ҳамааш хуб аст! Барномаи шумо дар ҳолати корӣ ва онлайн қарор дорад.";
    } else if (lowerCmd.contains("соат") || lowerCmd.contains("вақт") || lowerCmd.contains("время")) {
      String timeNow = TimeOfDay.fromDateTime(DateTime.now()).format(context);
      response = "Ҳоло вақти маҳаллӣ соат $timeNow аст.";
    } else if (lowerCmd.contains("ном") || lowerCmd.contains("кистӣ") || lowerCmd.contains("кто ты")) {
      response = "Ман Charvis TJ ҳастам, ассистенти овозии рақамии шумо.";
    } else {
      response = "Ман ин суханро шунидам: '$command'.";
    }

    setState(() {
      _aiResponse = response;
    });
  }

  // Включение и сброс состояния микрофона
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
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _textSpoken = val.recognizedWords;
              if (val.recognizedWords.isNotEmpty) {
                _processCommand(_textSpoken);
              }
            });
            if (val.finalResult) {
              _speech.stop();
              setState(() => _isListening = false);
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
        title: const Text('Charvis TJ (Online Assistant)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_toy, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          "Ҷавоби Charvis:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _aiResponse,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, color: Colors.black87, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                duration: const Duration(milliseconds: 300),
                height: 95,
                width: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.indigo,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.indigo).withOpacity(0.5),
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
              _isListening ? "Лутфан гап занед, гӯш истодаам..." : "Барои сӯҳбат тугмаро пахш кунед",
              style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

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

  // Коркарди чандири фармонҳо
  void _processCommand(String command) {
    String lowerCmd = command.toLowerCase();
    String response = "";

    if (lowerCmd.contains("салом") || lowerCmd.contains("сал") || lowerCmd.contains("привет")) {
      response = "Салом! Шуморо диданам хеле хурсандам. Имрӯз ба шумо чӣ гуна кӯмак расонам?";
    } else if (lowerCmd.contains("аҳвол") || lowerCmd.contains("хол") || lowerCmd.contains("как дела")) {

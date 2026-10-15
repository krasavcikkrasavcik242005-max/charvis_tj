import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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
  String _text = 'Тугмаро пахш кунед ва гап занед...';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Функсия барои дархости иҷозат ва оғози гӯшкунӣ
  Future<void> _listen() async {
    if (!_isListening) {
      // Иҷозати микрофонро аз система мепурсад
      var status = await Permission.microphone.request();
      
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) => print('Status: $val'),
          onError: (val) => print('Error: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            localeId: 'tg_TJ', // Танзими забони тоҷикӣ
            onResult: (val) => setState(() {
              _text = val.recognizedWords;
            }),
          );
        }
      } else {
        setState(() {
          _text = 'Иҷозати истифодаи микрофон дода нашуд!';
        });
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
        title: const Text('Charvis TJ - Ассистенти Овозӣ'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.redAccent : Colors.indigo,
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const CharvisApp());
}

class CharvisApp extends StatelessWidget {
  const CharvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Charvis TJ Ultimate',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "bot",
      "text": "Салом! Ман Чарвир ТҶ Ултимейт ҳастам. Ёвари шахсии шумо бо забони тоҷикӣ омодаи иҷрои фармонҳост!"
    }
  ];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
    });

    _controller.clear();

    // Ҷавоб ва иҷрои фармонҳои пешрафтаи овозӣ ва матнӣ
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        String response = "Фармони '$text' қабул шуд. Дар ҳоли иҷро ҳастам.";
        
        String lowerText = text.toLowerCase();
        if (lowerText.contains("чароғ") || lowerText.contains("фонарик")) {
          response = "Чароғаки телефон бо фармони шумо идора карда шуд.";
        } else if (lowerText.contains("вайфай") || lowerText.contains("wifi")) {
          response = "Шабакаи Wi-Fi бо фармони шумо санҷида шуд.";
        } else if (lowerText.contains("хомӯш") || lowerText.contains("перезагрузка")) {
          response = "Барои амнияти система идоракунии мустақими хомӯшсозӣ дархост гардид.";
        } else if (lowerText.contains("обу ҳаво")) {
          response = "Имрӯз ҳаво дар Тоҷикистон соф ва муътадил аст.";
        }

        _messages.add({"sender": "bot", "text": response});
      });
    });
  }

  void _showSettingsMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Танзимоти Charvis TJ Ultimate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• Забони барнома: Тоҷикӣ'),
            Text('• Ҳуқуқҳои идоракунии телефон: Фаъол'),
            Text('• Пайвастшавӣ (USB / Bluetooth): Омода'),
            Text('• Амният ва муҳофизат: Фаъол'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Пӯшидан'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charvis TJ Ultimate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message["text"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black54,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Фармон диҳед (масалан: чароғро хомӯш кун...)',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _handleSubmitted(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    {"sender": "bot", "text": "Ман Чарвир ТҶ Ултимейт ҳастам. Омодаам ба идоракунӣ ва фармонҳои шумо бо забони тоҷикӣ!"}
  ];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({"sender": "user", "text": text});
    });
    
    _controller.clear();

    // Ҷавоб ва иҷрои фармонҳои супоридашуда
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        String response = "Фармони шумо қабул шуд: '$text'. Система дар ҳоли иҷро аст.";
        if (text.toLowerCase().contains("хомӯш") || text.toLowerCase().contains("перезагрузка")) {
          response = "Барои амният идоракунии мустақими хомӯшкунӣ аз тарафи система маҳдуд аст, аммо дархост иҷро шуд.";
        } else if (text.toLowerCase().contains("телефон")) {
          response = "Идоракунии мустақили телефон фаъол аст. Марҳамат фармон диҳед.";
        }
        _messages.add({"sender": "bot", "text": response});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charvis TJ Ultimate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Меню ва танзимот
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Танзимоти Чарвис'),
                  content: const Text('Қисми идоракунӣ ва ҳуқуқҳои телефон фаъол аст.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Пушидан'),
                    ),
                  ],
                ),
              );
            },
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
                      hintText: 'Фармон диҳед (масалан: идоракунии телефон...)',
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

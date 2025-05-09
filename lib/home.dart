import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:worklyn_test/provider.dart'; // Replace with actual path

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(ChatProvider provider) {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    _controller.clear();
    provider.sendMessage(message);
  }

  void _showTaskModal(BuildContext context, String html) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: 300,
        child: SingleChildScrollView(
          child: Text(html, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<ChatProvider>(
          builder: (context, provider, _) {
            return SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.messages.length +
                          (provider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= provider.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: LoadingDots(),
                            ),
                          );
                        }

                        final message = provider.messages[index];
                        final isUser = message['sender'] == 'user';
                        final isHtml = message['type'] == 'html';

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              if (isHtml) {
                                _showTaskModal(context, message['content']);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser
                                      ? const Radius.circular(16)
                                      : const Radius.circular(0),
                                  bottomRight: isUser
                                      ? const Radius.circular(0)
                                      : const Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                message['content'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "What can I do for you?",
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _sendMessage(provider),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.lightBlueAccent,
                            child: const Icon(Icons.arrow_upward,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black87,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.checklist), label: 'Tasks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
          currentIndex: 0,
          onTap: (_) {},
        ),
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        if (_controller.status == AnimationStatus.completed) {
          setState(() => dotCount = (dotCount + 1) % 4);
          _controller.forward(from: 0);
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("." * dotCount, style: const TextStyle(fontSize: 24));
  }
}

Widget _buildTaskCard(Map<String, dynamic> task, BuildContext context) {
  return GestureDetector(
    onTap: () => _showTaskBottomSheet(task, context),
    child: Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Task created", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.circle_outlined),
              SizedBox(width: 8),
              Expanded(child: Text(task['message'] ?? 'No message')),
            ],
          ),
          if (task['html'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text("Today", style: TextStyle(color: Colors.green))
                ],
              ),
            )
        ],
      ),
    ),
  );
}

void _showTaskBottomSheet(Map<String, dynamic> task, BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Task Detail",
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("Message: ${task['message'] ?? ''}"),
            SizedBox(height: 8),
            if (task['html'] != null)
              Text("HTML: ${task['html']}",
                  style: TextStyle(color: Colors.grey)),
            if (task['interactiveId'] != null)
              Text("Interactive ID: ${task['interactiveId']}",
                  style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    },
  );
}

class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 6),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 6,
            height: 6,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: 6,
            height: 6,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 700),
            width: 6,
            height: 6,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text("Assistant is typing...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

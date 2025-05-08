import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider.dart';

class MainScreen extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();

  MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final taskNotifier = ref.read(taskListProvider.notifier);
    final isTapped = ref.watch(isTappedProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: false,
            title: Text(
              'Chat',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.white),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[100],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: tasks.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle:
                        Text('Due: ${DateFormat.yMMMd().format(task.date)}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: task.date,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        taskNotifier.updateTaskDate(index, picked);
                      }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  ref.read(isTappedProvider.notifier).state = !isTapped;
                },
                child: Row(
                  children: [
                    Container(
                      width: 230,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(234, 237, 237, 1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'What can I do for you?',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(162, 162, 166, 1)),
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isTapped
                            ? Color.fromRGBO(170, 218, 233, 1)
                            : Color.fromRGBO(0, 0, 0, 1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          taskNotifier.fetchTasks(_controller.text);
                          _controller.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

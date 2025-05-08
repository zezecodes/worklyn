import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worklyn_test/task.dart';
import 'dart:convert';

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

final isTappedProvider = StateProvider<bool>((ref) => false);

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);
  // Add this to your existing providers

  Future<void> fetchTasks(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.worklyn.com/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tasks =
          (data['tasks'] as List).map((e) => Task.fromJson(e)).toList();
      state = tasks;
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  void updateTaskDate(int index, DateTime newDate) {
    final updated = [...state];
    updated[index].date = newDate;
    state = updated;
  }
}

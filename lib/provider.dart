// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ChatProvider with ChangeNotifier {
//   List<String> _messages = []; 
//   bool _isLoading = false;

//   List<String> get messages => _messages;
//   bool get isLoading => _isLoading;

//   final String baseUrl = "https://api.worklyn.com";

//   Future<void> sendMessage(String message) async {
//     if (message.trim().isEmpty) return;

//     _messages.add(message);
//     notifyListeners();

//     try {
//       _isLoading = true;
//       notifyListeners();

//       final url =
//           Uri.parse('$baseUrl/konsul/assistant.chat');
//       final response = await http.put(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'X-Environment': 'development'
//         },
//         body: jsonEncode({
//           "message": message,
//           "source": {
//             "id": 1,
//             "name": 1
//           }
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['reply'] != null) {
//           _messages.add(data['reply']);
//         } else {
//           _messages.add("No reply from server.");
//         }
//       } else {
//         _messages.add("Failed to send message. (${response.statusCode})");
//       }
//     } catch (e) {
//       _messages.add("Error: ${e.toString()}");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ChatProvider extends ChangeNotifier {
//   List<String> _messages = [];
//   bool _isTyping = false;
//   Map<String, dynamic>? _latestTask;

//   final String baseUrl = "https://api.worklyn.com";

//   List<String> get messages => _messages;
//   bool get isTyping => _isTyping;
//   Map<String, dynamic>? get latestTask => _latestTask;

//   Future<void> sendMessage(String message) async {
//     if (message.trim().isEmpty) return;

//     _messages.add(message);
//     _isTyping = true;
//     _latestTask = null;
//     notifyListeners();

//     try {
//       final url = Uri.parse('$baseUrl/konsul/assistant.chat');
//       final response = await http.put(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'X-Environment': 'development'
//         },
//         body: jsonEncode({
//           "message": message,
//           "source": {
//             "id": "1",
//             "deviceId": 1
//           }
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _latestTask = data;
//       } else {
//         _latestTask = {"message": "Failed with status ${response.statusCode}"};
//       }
//     } catch (e) {
//       _latestTask = {"message": "Error: ${e.toString()}"};
//     } finally {
//       _isTyping = false;
//       notifyListeners();
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  final String baseUrl = "https://api.worklyn.com";

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add({
      'sender': 'user',
      'type': 'text',
      'content': message,
    });
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/konsul/assistant.chat');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Environment': 'development',
        },
        body: jsonEncode({
          "message": message,
          "source": {
            "id": 1,
            "deviceId": 1,
          }
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Add bot reply (HTML or text)
        _messages.add({
          'sender': 'bot',
          'type': data['html'] != null ? 'html' : 'text',
          'content': data['html'] ?? data['message'] ?? 'No response',
          'interactiveId': data['interactiveId'],
        });
      } else {
        _messages.add({
          'sender': 'bot',
          'type': 'text',
          'content': 'Failed to get response. (${response.statusCode})',
        });
      }
    } catch (e) {
      _messages.add({
        'sender': 'bot',
        'type': 'text',
        'content': 'Error: ${e.toString()}',
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

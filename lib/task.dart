class Task {
  final String title;
  DateTime date;

  Task({required this.title, required this.date});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      date: DateTime.parse(json['date']),
    );
  }
}

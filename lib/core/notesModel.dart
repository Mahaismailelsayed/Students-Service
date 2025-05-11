class Note {
  DateTime? reminderTime;
  final String title;
  final String content;

  Note({required this.title, required this.content, this.reminderTime});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'])
          : null,
    );
  }
}
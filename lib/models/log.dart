class Log {
  final String id;
  final String title;
  final String date;

  Log({required this.id, required this.title, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
    };
  }

  factory Log.fromMap(Map<String, dynamic> json) => Log(
        id: json['id'],
        title: json['title'],
        date: json['date'],
      );

  @override
  String toString() {
    return 'Log{id: $id, title: $title, date: $date}';
  }
}

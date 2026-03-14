class Task {
  final int id;
  final String description;

  Task({required this.id, required this.description});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(id: json["id"], description: json["description"]);
  }
}

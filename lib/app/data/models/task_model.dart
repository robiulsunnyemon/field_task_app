
class TaskModel {
  final String id;
  final String title;

  TaskModel({required this.id, required this.title});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['tittle'] ?? 'No Title',
    );
  }
}
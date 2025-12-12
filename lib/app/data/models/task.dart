
import 'dart:convert';

List<Task> taskListFromJson(String str) => List<Task>.from(json.decode(str).map((x) => Task.fromJson(x)));

String taskListToJson(List<Task> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Task {
  final String id;
  final String title;
  final String longi;
  final String lati;
  final String agentId;
  final String taskStatus;
  final String parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.longi,
    required this.lati,
    required this.agentId,
    required this.taskStatus,
    required this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json["id"],
    title: json["tittle"],
    longi: json["longi"],
    lati: json["lati"],
    agentId: json["agent_id"],
    taskStatus: json["task_status"],
    parentId: json["parent_id"] ?? "N/A",
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tittle": title,
    "longi": longi,
    "lati": lati,
    "agent_id": agentId,
    "task_status": taskStatus,
    "parent_id": parentId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };


  Task copyWith({
    String? id,
    String? title,
    String? longi,
    String? lati,
    String? agentId,
    String? taskStatus,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      longi: longi ?? this.longi,
      lati: lati ?? this.lati,
      agentId: agentId ?? this.agentId,
      taskStatus: taskStatus ?? this.taskStatus,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
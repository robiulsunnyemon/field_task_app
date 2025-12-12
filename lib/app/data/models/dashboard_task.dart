import 'dart:convert';
import 'package:get/get.dart';


List<TaskModel> taskListFromJson(String str) =>
    List<TaskModel>.from(json.decode(str).map((x) => TaskModel.fromJson(x)));

class TaskModel {
  final String id;
  final String title;
  final String longi;
  final String lati;
  final String agentId;
  final String taskStatus;
  final String parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String agentName;

  TaskModel({
    required this.id,
    required this.title,
    required this.longi,
    required this.lati,
    required this.agentId,
    required this.taskStatus,
    required this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.agentName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json["id"] ?? 'N/A',
      title: json["tittle"] ?? 'No Title',
      longi: json["longi"] ?? '0.0',
      lati: json["lati"] ?? '0.0',
      agentId: json["agent_id"] ?? 'N/A',
      taskStatus: json["task_status"] ?? 'pending',
      parentId: json["parent_id"] ?? 'N/A',
      createdAt: DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? '') ?? DateTime.now(),
      agentName: json["agent_name"] ?? 'Unknown Agent',
    );
  }

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
    "agent_name": agentName,
  };


  TaskModel copyWith({String? taskStatus}) {
    return TaskModel(
      id: id,
      title: title,
      longi: longi,
      lati: lati,
      agentId: agentId,
      taskStatus: taskStatus ?? this.taskStatus,
      parentId: parentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      agentName: agentName,
    );
  }
}
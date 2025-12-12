import 'package:get/get.dart';
import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';

class CreateTaskController extends GetxController {
  static const String _tasksUrl = "${AppConstants.baseUrl}/api/v1/tasks/";
  static const String _usersUrl = "${AppConstants.baseUrl}/api/v1/users";

  final titleController = TextEditingController();
  final RxString longi = ''.obs;
  final RxString lati = ''.obs;

  final RxString selectedAgentId = ''.obs;
  final RxString selectedParentTaskId = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isAgentsLoading = true.obs;
  final RxBool isParentTasksLoading = false.obs;

  final RxList<User> agentsList = <User>[].obs;
  final RxList<TaskModel> parentTasksList = <TaskModel>[].obs;
  final GetStorage _box = GetStorage();



  @override
  void onInit() {
    fetchAgents();
    super.onInit();
  }

  void onAgentIdChanged(String? newAgentId) {
    if (newAgentId != null && newAgentId.isNotEmpty) {
      selectedAgentId.value = newAgentId;
      fetchParentTasks(newAgentId);
    } else {
      selectedAgentId.value = '';
      selectedParentTaskId.value = '';
      parentTasksList.clear();
    }
  }

  void onParentTaskIdChanged(String? newParentTaskId) {
    selectedParentTaskId.value = newParentTaskId ?? '';
  }

  Future<void> fetchAgents() async {
    isAgentsLoading.value = true;
    final token = _box.read('authToken');
    final url = Uri.parse(_usersUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        agentsList.value = data.map((json) => User.fromJson(json)).toList();
      } else {
        Get.snackbar(
          "Agent Load Error",
          "Failed to load agents: ${response.statusCode}",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Network Error",
        "Could not connect to fetch agents: $e",
        backgroundColor: Colors.red,
      );

    } finally {
      isAgentsLoading.value = false;
    }
  }

  Future<void> fetchParentTasks(String agentId) async {
    isParentTasksLoading.value = true;
    selectedParentTaskId.value = '';
    parentTasksList.clear();

    final token = _box.read('authToken');
    final url = Uri.parse("${_tasksUrl}user/$agentId");


    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );



      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        parentTasksList.value = data
            .map((json) => TaskModel.fromJson(json))
            .toList();
      } else {
        Get.snackbar(
          "Task Load Error",
          "Failed to load parent tasks: ${response.statusCode}",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Network Error",
        "Could not connect to fetch parent tasks: $e",
        backgroundColor: Colors.red,
      );

    } finally {
      isParentTasksLoading.value = false;
    }
  }

  void setLocation(double lat, double lon) {
    lati.value = lat.toString();
    longi.value = lon.toString();
    Get.back();
  }

  Future<void> createTask() async {
    if (isLoading.value) return;

    if (titleController.text.isEmpty ||
        longi.value.isEmpty ||
        lati.value.isEmpty ||
        selectedAgentId.value.isEmpty) {
      Get.snackbar(
        "Missing Fields",
        "Please fill in the Title, pick a Location, and select an Agent.",
        backgroundColor: Colors.orange,
      );
      return;
    }

    isLoading.value = true;

    final Map<String, dynamic> body = {
      "tittle": titleController.text,
      "longi": longi.value.toString(),
      "lati": lati.value.toString(),
      "agent_id": selectedAgentId.value,
      "parent_id": selectedParentTaskId.value.isNotEmpty
          ? selectedParentTaskId.value
          : "null",
    };

    final url = Uri.parse(_tasksUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );



      if (response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Task created successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white
        );



        titleController.clear();
        selectedAgentId.value = '';
        selectedParentTaskId.value = '';
        lati.value = '';
        longi.value = '';
        parentTasksList.clear();

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchMyTasks();
        }
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchAllTasks();
        }
      } else {
        final data = jsonDecode(response.body);
        String errorMessage = data["message"] ?? "Task creation failed.";
        Get.snackbar("API Error", errorMessage, backgroundColor: Colors.red);

      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: Colors.red,
      );

    } finally {
      isLoading.value = false;
    }
  }
}

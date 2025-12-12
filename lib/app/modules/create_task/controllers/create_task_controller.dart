import 'package:get/get.dart';
import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../home/controllers/home_controller.dart';

class CreateTaskController extends GetxController {


  final titleController = TextEditingController();
  final parentIdController = TextEditingController();
  final RxString agentId = ''.obs;


  final RxString longi = ''.obs;
  final RxString lati = ''.obs;

  final RxBool isLoading = false.obs;
  final GetStorage _box = GetStorage();

  static const String _tasksUrl = "${AppConstants.baseUrl}/api/v1/tasks/";

  @override
  void onInit() {

    _loadAgentId();
    super.onInit();
  }


  @override
  void onReady() {
    if (agentId.value.isEmpty) {
      Get.snackbar("Error", "User data or Agent ID not found. Please log in again.", backgroundColor: Colors.red);
    }
    super.onReady();
  }

  void _loadAgentId() {
    final userDataJson = _box.read('currentUserData');
    if (userDataJson != null && userDataJson['id'] != null) {
      agentId.value = userDataJson['id'];
      print('DEBUG: Agent ID loaded: ${agentId.value}');
    } else {
      agentId.value = '';
    }
  }


  void setLocation(double lat, double lon) {
    lati.value = lat.toString();
    longi.value = lon.toString();
    Get.back();
  }


  Future<void> createTask() async {
    if (isLoading.value) return;

    if (titleController.text.isEmpty || longi.value.isEmpty || lati.value.isEmpty || agentId.value.isEmpty) {
      Get.snackbar("Missing Fields", "Please fill in the Title and pick a Location.", backgroundColor: Colors.orange);
      return;
    }



    isLoading.value = true;
    final token = _box.read('authToken');

    final Map<String, dynamic> body = {
      "tittle": titleController.text,
      "longi": longi.value,
      "lati": lati.value,
      "agent_id": agentId.value,
      "parent_id": parentIdController.text.isNotEmpty ? parentIdController.text : null, // যদি খালি হয় তবে null পাঠানো হলো
    };

    final url = Uri.parse(_tasksUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        Get.snackbar("Success", "Task created successfully!", backgroundColor: Colors.green);

        titleController.clear();
        parentIdController.clear();
        lati.value = '';
        longi.value = '';


        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchMyTasks();
        }

      } else {
        final data = jsonDecode(response.body);
        String errorMessage = data["message"] ?? "Task creation failed.";
        Get.snackbar("API Error", errorMessage, backgroundColor: Colors.red);
        print('API Error: ${response.statusCode} - ${response.body}');
      }

    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e", backgroundColor: Colors.red);
      print('Exception during task creation: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
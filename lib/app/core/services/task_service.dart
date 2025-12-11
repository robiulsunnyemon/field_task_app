
import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../exception/api_exception.dart';
import 'location_service.dart';

class TaskService extends GetxService {

  final LocationService _locationService = Get.find<LocationService>();
  final GetStorage _storage = GetStorage();


  static const String _offlineTasksKey = 'offlineCompletedTasks';
  static const String _authTokenKey = 'authToken';


  static const String _checkInUrl = "${AppConstants.baseUrl}/api/v1/complete_tasks/check-in";
  static const String _completeUrl = "${AppConstants.baseUrl}/api/v1/complete_tasks/";

  @override
  void onInit() {
    super.onInit();


    ever(_locationService.connectivityResultStream, (ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _syncOfflineTasks();
      }
    });
  }


  Future<void> checkInTask(String taskId, String agentId) async {
    final token = _storage.read(_authTokenKey);
    if (token == null) {
      // টোকেন না পেলে লগইন এ পাঠানো উচিত
      Get.snackbar("Auth Error", "Session expired. Please log in.", backgroundColor: Colors.red);
      throw Exception("Authentication token missing.");
    }

    final url = Uri.parse(_checkInUrl);
    final body = jsonEncode({"task_id": taskId, "agent_id": agentId});

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      Get.snackbar("Check-In", "Task $taskId checked in successfully!", backgroundColor: Colors.green);
    } else {
      final data = jsonDecode(response.body);
      throw ApiException(data["message"] ?? "Check-In failed", statusCode: response.statusCode);
    }
  }


  Future<void> completeTaskOnline(String taskId, String agentId) async {
    final token = _storage.read(_authTokenKey);
    print("called complete tsk online");
    if (token == null) {
      Get.snackbar("Auth Error", "Session expired. Please log in.", backgroundColor: Colors.red);
      throw Exception("Authentication token missing.");
    }

    final url = Uri.parse(_completeUrl);
    final body = jsonEncode({"task_id": taskId, "agent_id": agentId});

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );
    print("complete task response stacode ${response.statusCode} and ${response.body}");

    if (response.statusCode == 200) {
      Get.snackbar("Success", "Task $taskId completed and synced!", backgroundColor: Colors.green);
    } else {
      final data = jsonDecode(response.body);
      throw ApiException(data["message"] ?? "Task completion failed", statusCode: response.statusCode);
    }
  }


  Future<void> saveTaskOffline(String taskId, String agentId) async {
    final List<dynamic> offlineTasks = _storage.read(_offlineTasksKey) ?? [];

    final newTask = {
      "task_id": taskId,
      "agent_id": agentId,
      "timestamp": DateTime.now().toIso8601String(),
    };

    offlineTasks.add(newTask);
    await _storage.write(_offlineTasksKey, offlineTasks);

    Get.snackbar("Offline Saved", "Task saved locally. Will sync when connected.", backgroundColor: Colors.orange);
  }


  Future<void> _syncOfflineTasks() async {
    //

    if (!_locationService.hasInternet) return;

    final List<dynamic> offlineTasks = _storage.read(_offlineTasksKey) ?? [];
    if (offlineTasks.isEmpty) return;

    Get.snackbar("Syncing", "${offlineTasks.length} tasks pending sync...", backgroundColor: Colors.blue);

    List<dynamic> successfullySynced = [];

    for (var task in offlineTasks) {
      try {
        // প্রতিটি টাস্ক অনলাইনে কমপ্লিট করার চেষ্টা
        await completeTaskOnline(task["task_id"], task["agent_id"]);
        successfullySynced.add(task);
      } catch (e) {
        // সিঙ্ক ব্যর্থ হলে (যেমন 400 বা 500 এরর), এই টাস্কটি লোকালি রেখে দেওয়া হবে
        print("Failed to sync task ${task["task_id"]}: $e");

        // টাস্ক সিঙ্ক না হওয়ার কারণে যদি কোনো গুরুত্বপূর্ণ স্ট্যাটাস কোড আসে (যেমন 401 Auth error),
        // তবে পুরো সিঙ্ক প্রক্রিয়া বন্ধ করে লগইন এ যাওয়া উচিত।
        // বর্তমানে, এটি প্রথম ব্যর্থতার পরে সিঙ্ক বন্ধ করছে, যা ঠিক আছে।
        break;
      }
    }

    // সফলভাবে সিঙ্ক হওয়া টাস্কগুলো লোকাল স্টোরেজ থেকে মুছে দেওয়া
    final updatedList = offlineTasks.where((task) => !successfullySynced.contains(task)).toList();
    await _storage.write(_offlineTasksKey, updatedList);

    if (successfullySynced.isNotEmpty) {
      Get.snackbar("Sync Complete", "${successfullySynced.length} tasks synced successfully!", backgroundColor: Colors.green);
    }
    if (updatedList.isNotEmpty) {
      Get.snackbar("Pending", "${updatedList.length} tasks still pending sync.", backgroundColor: Colors.orange);
    }
  }


  Future<void> processTaskCompletion(String taskId, String agentId) async {
    if (_locationService.hasInternet) {
      try {
        await completeTaskOnline(taskId, agentId);
      } catch (e) {

        await saveTaskOffline(taskId, agentId);
      }
    } else {

      await saveTaskOffline(taskId, agentId);
    }
  }
}
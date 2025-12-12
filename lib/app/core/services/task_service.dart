import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../modules/home/controllers/home_controller.dart';
import '../exception/api_exception.dart';
import 'location_service.dart';

class TaskService extends GetxService {

  final LocationService _locationService = Get.find<LocationService>();
  final GetStorage _storage = GetStorage();


  static const String _syncQueueKey = 'syncQueue';
  static const String _authTokenKey = 'authToken';

  static const String _checkInUrl = "${AppConstants.baseUrl}/api/v1/complete_tasks/check-in";
  static const String _completeUrl = "${AppConstants.baseUrl}/api/v1/complete_tasks/";

  final RxBool isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();

    ever(_locationService.connectivityResultStream, (ConnectivityResult result) {
      if (result != ConnectivityResult.none && !isSyncing.value) {
        print('DEBUG: Internet detected. Initiating sync from TaskService.');
        _syncOfflineTasks();
      }
    });
  }

  Future<void> _apiCall(String url, String taskId, String agentId) async {
    final token = _storage.read(_authTokenKey);
    if (token == null) {
      Get.snackbar("Auth Error", "Session expired. Please log in.", backgroundColor: Colors.red);
      throw Exception("Authentication token missing.");
    }

    final body = jsonEncode({"task_id": taskId, "agent_id": agentId});

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {

    } else {
      final data = jsonDecode(response.body);
      throw ApiException(data["message"] ?? "API call failed", statusCode: response.statusCode);
    }
  }


  void _addToSyncQueue(String taskId, String agentId, String action) {
    final List<dynamic> queue = _storage.read(_syncQueueKey) ?? [];

    queue.add({
      "task_id": taskId,
      "agent_id": agentId,
      "action": action,
      "timestamp": DateTime.now().toIso8601String(),
    });

    _storage.write(_syncQueueKey, queue);
    print('DEBUG: Added $action for $taskId to sync queue. Queue size: ${queue.length}');
  }


  Future<void> _syncOfflineTasks() async {
    if (isSyncing.value || !_locationService.hasInternet) return;

    final List<dynamic> offlineTasks = _storage.read(_syncQueueKey) ?? [];
    if (offlineTasks.isEmpty) return;

    isSyncing.value = true;
    Get.snackbar("Syncing", "${offlineTasks.length} pending actions...", duration: const Duration(seconds: 5), backgroundColor: Colors.blue);

    List<dynamic> failedQueue = [];

    for (var task in offlineTasks) {
      final taskId = task["task_id"];
      final agentId = task["agent_id"];
      final action = task["action"];
      final url = action == 'check_in' ? _checkInUrl : _completeUrl;

      try {
        await _apiCall(url, taskId, agentId);
        print("DEBUG: Successfully synced $action for $taskId.");

      } catch (e) {

        print("DEBUG: Sync failed for $action on $taskId: $e");
        failedQueue.add(task);
      }
    }


    await _storage.write(_syncQueueKey, failedQueue);

    isSyncing.value = false;

    if (failedQueue.isEmpty && offlineTasks.isNotEmpty) {
      Get.snackbar("Sync Complete", "All actions synced successfully!", backgroundColor: Colors.green);

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchMyTasks();
      }
    } else if (failedQueue.isNotEmpty) {
      Get.snackbar("Partial Sync", "${failedQueue.length} actions failed to sync. Trying again later.", backgroundColor: Colors.red);
    }
  }


  Future<void> processCheckIn(String taskId, String agentId) async {
    if (_locationService.hasInternet) {
      try {
        await _apiCall(_checkInUrl, taskId, agentId);
      } catch (e) {
        _addToSyncQueue(taskId, agentId, 'check_in');
        Get.snackbar("Sync Pending", "Check-in successful locally, but API failed. Sync pending.", backgroundColor: Colors.orange);
      }
    } else {
      _addToSyncQueue(taskId, agentId, 'check_in');
    }
  }


  Future<void> processCompletion(String taskId, String agentId) async {
    if (_locationService.hasInternet) {
      try {
        await _apiCall(_completeUrl, taskId, agentId);
      } catch (e) {
        _addToSyncQueue(taskId, agentId, 'complete');
        Get.snackbar("Sync Pending", "Completion successful locally, but API failed. Sync pending.", backgroundColor: Colors.orange);
      }
    } else {
      _addToSyncQueue(taskId, agentId, 'complete');
    }
  }
}

import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../core/exception/api_exception.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/task_service.dart';
import '../../../data/models/task_model.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {

  final LocationService _locationService = Get.find<LocationService>();
  final TaskService _taskService = Get.find<TaskService>();

  final GetStorage _box = GetStorage();

  static const String _tasksUrl = "${AppConstants.baseUrl}/api/v1/tasks/users/my-task";
  static const String _tasksStorageKey = 'myTasks';

  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final RxString userName = 'Field Agent'.obs;
  final RxString userToken = ''.obs;

  static const double _rangeLimit = 100.0;

  final RxMap<String, bool> checkInStatus = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchMyTasks();

    everAll(
        [
          _locationService.currentPositionStream,
          tasks
        ],
            (_) => _checkTaskRanges()
    );
  }


  void _loadUserData() {
    final box = GetStorage();
    final token = box.read('authToken');
    final userDataJson = box.read('currentUserData');

    if (token != null) {
      userToken.value = token;
    }

    if (userToken.isEmpty) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    if (userDataJson != null && userDataJson['name'] != null) {
      userName.value = userDataJson['name'];
    } else {
      userName.value = 'Agent: ${userToken.value.substring(0, 8)}...';
    }
  }



  Future<void> fetchMyTasks() async {
    print('DEBUG: Starting fetchMyTasks with Offline Support.');
    error.value = '';


    final localTasksJson = _box.read(_tasksStorageKey);
    if (localTasksJson != null) {
      try {
        final List<Task> localTasks = taskListFromJson(localTasksJson);
        tasks.assignAll(localTasks);
        isLoading.value = false;
        print('DEBUG: Successfully loaded ${tasks.length} tasks from local storage.');
      } catch (e) {
        print('DEBUG: Error parsing local data: $e');
        _box.remove(_tasksStorageKey);
      }
    }

    if (tasks.isEmpty) {
      isLoading.value = true;
    }


    final connectivityResult = await (Connectivity().checkConnectivity());
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (!isOnline) {
      if (tasks.isEmpty) {
        error.value = 'Offline: No tasks found locally.';
        Get.snackbar("Offline Mode", "You are currently offline and no previous tasks were saved. Please connect to the internet.", backgroundColor: Colors.yellow.shade800, colorText: Colors.black);
      } else {
        error.value = 'Offline: Showing cached data.';
        Get.snackbar("Offline Mode", "Showing cached data. Connect to the internet to refresh.", backgroundColor: Colors.yellow.shade800, colorText: Colors.black);
      }
      isLoading.value = false;
      return;
    }


    print('DEBUG: Device is Online. Fetching from API...');
    final url = Uri.parse(_tasksUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer ${userToken.value}",
        },
      );

      if (response.statusCode == 200) {
        final List<Task> fetchedTasks = taskListFromJson(response.body);
        tasks.assignAll(fetchedTasks);
        error.value = '';
        _box.write(_tasksStorageKey, response.body);
        print('DEBUG: Tasks fetched and saved locally. Total tasks: ${tasks.length}');
      } else if (response.statusCode == 401) {
        Get.snackbar("Auth Error", "Session expired. Please log in again.", backgroundColor: Colors.red);
        Get.offAllNamed(Routes.LOGIN);
      } else {
        final data = jsonDecode(response.body);
        throw ApiException(data["message"] ?? "Failed to fetch tasks.", statusCode: response.statusCode);
      }

    } on ApiException catch (e) {
      if (tasks.isEmpty) {
        error.value = e.message;
        Get.snackbar("API Error", e.message, backgroundColor: Colors.red);
      }
    } catch (e) {
      if (tasks.isEmpty) {
        error.value = 'An unexpected error occurred: $e';
        Get.snackbar("Error", "Could not fetch tasks.", backgroundColor: Colors.red);
      }
    } finally {
      isLoading.value = false;
      print('DEBUG: fetchMyTasks finished. isLoading=${isLoading.value}');
    }
  }



  RxBool isWithinRange(String taskId) {
    final task = tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null || _locationService.currentPosition == null) {
      return false.obs;
    }
    final distance = _locationService.getDistanceInMeters(
      double.parse(task.lati),
      double.parse(task.longi),
    );
    return (distance <= _rangeLimit).obs;
  }
  void _checkTaskRanges() {}




  Future<void> handleCheckIn(Task task) async {
    print('DEBUG: Starting Check-In for Task: ${task.id}');


    checkInStatus[task.id] = true;
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task.copyWith(taskStatus: 'in_progress');
      tasks.refresh();
      _box.write(_tasksStorageKey, jsonEncode(tasks.map((e) => e.toJson()).toList()));
    }


    await _taskService.processCheckIn(task.id, task.agentId);
  }

  Future<void> handleCompletion(Task task) async {
    print('DEBUG: Starting Completion for Task: ${task.id}');


    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task.copyWith(taskStatus: 'complete');
      tasks.refresh();
      checkInStatus.remove(task.id);

      _box.write(_tasksStorageKey, jsonEncode(tasks.map((e) => e.toJson()).toList()));
    }


    await _taskService.processCompletion(task.id, task.agentId);
  }
}
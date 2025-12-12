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
import '../../../core/widget/map_vew.dart';
import '../../../data/models/task.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  final TaskService _taskService = Get.find<TaskService>();

  final GetStorage _box = GetStorage();

  static const String _tasksUrl =
      "${AppConstants.baseUrl}/api/v1/tasks/users/my-task";
  static const String _userInfoUrl =
      "https://www.fieldtask.mtscorporate.com/api/v1/users/info/me";
  static const String _tasksStorageKey = 'myTasks';
  static const String _userDataStorageKey = 'currentUserData';

  final Rx<User?> currentUser = Rx<User?>(null);

  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final RxString userToken = ''.obs;

  static const double _rangeLimit = 100.0;

  final RxMap<String, bool> checkInStatus = <String, bool>{}.obs;
  final RxMap<String, bool> taskRangeStatus = <String, bool>{}.obs;

  int get pendingTasksCount =>
      tasks.where((task) => task.taskStatus.toLowerCase() == 'pending').length;
  int get inProgressTasksCount => tasks
      .where((task) => task.taskStatus.toLowerCase() == 'inprogress')
      .length;

  int get completedTasksCount => tasks
      .where(
        (task) =>
            task.taskStatus.toLowerCase() == 'complete' ||
            task.taskStatus.toLowerCase() == 'completed',
      )
      .length;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchUserInfoAndTasks();

    everAll([
      _locationService.currentPositionStream,
      tasks,
    ], (_) => _checkTaskRanges());
  }

  Future<void> fetchUserInfo() async {
    print('DEBUG: Starting fetchUserInfo...');
    if (userToken.isEmpty) return;

    final url = Uri.parse(_userInfoUrl);
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
        final data = jsonDecode(response.body);
        currentUser.value = User.fromJson(data);
        _box.write(_userDataStorageKey, data);
        print('DEBUG: User Info fetched: ${currentUser.value!.fullName}');
      } else if (response.statusCode == 401) {
        Get.snackbar(
          "Auth Error",
          "Session expired. Please log in again.",
          backgroundColor: Colors.red,
        );
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print('DEBUG: Error fetching user info: $e');
    }
  }

  void _loadUserData() {
    final box = GetStorage();
    final token = box.read('authToken');
    final userDataJson = box.read(_userDataStorageKey);

    if (token != null) {
      userToken.value = token;
    }

    if (userToken.isEmpty) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    if (userDataJson != null) {
      try {
        currentUser.value = User.fromJson(userDataJson);
      } catch (e) {
        print('DEBUG: Error loading user data from local storage: $e');
        _box.remove(_userDataStorageKey);
      }
    }
  }

  Future<void> fetchUserInfoAndTasks() async {
    if (userToken.isNotEmpty) {
      await fetchUserInfo();
    }
    await fetchMyTasks();
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
        print(
          'DEBUG: Successfully loaded ${tasks.length} tasks from local storage.',
        );
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
        Get.snackbar(
          "Offline Mode",
          "You are currently offline and no previous tasks were saved. Please connect to the internet.",
          backgroundColor: Colors.yellow.shade800,
          colorText: Colors.black,
        );
      } else {
        error.value = 'Offline: Showing cached data.';
        Get.snackbar(
          "Offline Mode",
          "Showing cached data. Connect to the internet to refresh.",
          backgroundColor: Colors.yellow.shade800,
          colorText: Colors.black,
        );
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
        print(
          'DEBUG: Tasks fetched and saved locally. Total tasks: ${tasks.length}',
        );
      } else if (response.statusCode == 401) {
        Get.snackbar(
          "Auth Error",
          "Session expired. Please log in again.",
          backgroundColor: Colors.red,
        );
        Get.offAllNamed(Routes.LOGIN);
      } else {
        final data = jsonDecode(response.body);
        throw ApiException(
          data["message"] ?? "Failed to fetch tasks.",
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (e) {
      if (tasks.isEmpty) {
        error.value = e.message;
        Get.snackbar("API Error", e.message, backgroundColor: Colors.red);
      }
    } catch (e) {
      if (tasks.isEmpty) {
        error.value = 'An unexpected error occurred: $e';
        Get.snackbar(
          "Error",
          "Could not fetch tasks.",
          backgroundColor: Colors.red,
        );
      }
    } finally {
      isLoading.value = false;
      print('DEBUG: fetchMyTasks finished. isLoading=${isLoading.value}');
    }
  }


  void _checkTaskRanges() {
    print('DEBUG: Checking task ranges...');
    final currentPosition = _locationService.currentPosition;
    if (currentPosition == null) {
      taskRangeStatus.clear();
      return;
    }

    final Map<String, bool> newStatus = {};
    for (var task in tasks) {
      try {
        final distance = _locationService.getDistanceInMeters(
          double.parse(task.lati),
          double.parse(task.longi),
        );
        newStatus[task.id] = (distance <= _rangeLimit);
      } catch (e) {
        newStatus[task.id] = false;
      }
    }
    taskRangeStatus.assignAll(newStatus);
  }

  bool isWithinRange(String taskId) {
    return taskRangeStatus[taskId] ?? false;
  }

  Future<bool> _canCheckIn(Task currentTask) async {
    final parentId = currentTask.parentId;

    if (parentId == "N/A" || parentId.isEmpty) {
      print(
        'DEBUG: Task ${currentTask.id} has no Parent ID or ID is invalid default. Check-in allowed.',
      );
      return true;
    }

    final parentTask = tasks.firstWhereOrNull((t) => t.id == parentId);

    if (parentTask == null) {
      print(
        'DEBUG: Parent Task ID $parentId not found in list. Check-in allowed.',
      );

      return true;
    }

    final status = parentTask.taskStatus.toLowerCase();
    final isParentCompleted = status == 'complete' || status == 'completed';

    if (isParentCompleted) {
      print('DEBUG: Parent Task $parentId is COMPLETED. Check-in allowed.');
      return true;
    } else {
      print(
        'DEBUG: Parent Task $parentId is NOT COMPLETED (Status: ${parentTask.taskStatus}). Check-in BLOCKED.',
      );
      Get.snackbar(
        "Action Blocked",
        "Please complete the prerequisite task: ${parentTask.title} (Status: ${parentTask.taskStatus.toUpperCase()}) first.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
  }

  Future<void> handleCheckIn(Task task) async {
    print('DEBUG: Starting Check-In for Task: ${task.id}');

    final isAllowed = await _canCheckIn(task);
    if (!isAllowed) {
      return;
    }

    checkInStatus[task.id] = true;
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task.copyWith(taskStatus: 'inprogress');
      tasks.refresh();

      _box.write(
        _tasksStorageKey,
        jsonEncode(tasks.map((e) => e.toJson()).toList()),
      );
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

      _box.write(
        _tasksStorageKey,
        jsonEncode(tasks.map((e) => e.toJson()).toList()),
      );
    }

    await _taskService.processCompletion(task.id, task.agentId);
  }

  void navigateToTaskLocation(Task task) {
    try {
      final double lat = double.parse(task.lati);
      final double long = double.parse(task.longi);

      Get.to(() => StreetMapView(lat: lat, long: long, title: task.title));
    } catch (e) {
      print('Error parsing location data: $e');
      Get.snackbar(
        "Location Error",
        "Invalid coordinates for this task.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

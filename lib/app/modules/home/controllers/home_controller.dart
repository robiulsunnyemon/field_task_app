import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/exception/api_exception.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/task_service.dart';
import '../../../data/models/task_model.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {

  final LocationService _locationService = Get.find<LocationService>();
  final TaskService _taskService = Get.find<TaskService>();

  static const String _tasksUrl = "${AppConstants.baseUrl}/api/v1/tasks/users/my-task";

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
      print('DEBUG: Auth Token loaded successfully.');
    } else {
      print('DEBUG: No Auth Token found, redirecting to login.');
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
    print('DEBUG: Starting fetchMyTasks.');
    if (tasks.isEmpty) {
      isLoading.value = true;
      error.value = '';
    }

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
        print('DEBUG: Tasks fetched successfully. Total tasks: ${tasks.length}');
      } else if (response.statusCode == 401) {
        print('DEBUG: API Error 401. Redirecting to Login.');
        Get.snackbar("Auth Error", "Session expired. Please log in again.", backgroundColor: Colors.red);
        Get.offAllNamed(Routes.LOGIN);
      } else {
        final data = jsonDecode(response.body);
        throw ApiException(data["message"] ?? "Failed to fetch tasks.", statusCode: response.statusCode);
      }

    } on ApiException catch (e) {
      error.value = e.message;
      print('DEBUG: API Exception: ${e.message}');
      Get.snackbar("Error", e.message, backgroundColor: Colors.red);
    } catch (e) {
      error.value = 'An unexpected error occurred: $e';
      print('DEBUG: General Exception: $e');
      Get.snackbar("Error", "Could not fetch tasks.", backgroundColor: Colors.red);
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

  void _checkTaskRanges() {

  }



  Future<void> handleCheckIn(Task task) async {
    print('DEBUG: Starting Check-In for Task: ${task.id}');
    try {
      // ✅ [গুরুত্বপূর্ণ]: TaskService-এ 201 স্ট্যাটাস কোডটিকে সফল সাড়া হিসেবে বিবেচনা করার জন্য নিশ্চিত করুন।
      await _taskService.checkInTask(task.id, task.agentId);

      // শুধুমাত্র যখন Check-In সফল হবে, তখনই এইগুলো এক্সিকিউট হবে
      checkInStatus[task.id] = true;
      checkInStatus.refresh();
      print('DEBUG: Task ${task.id} locally checked in (checkInStatus: true).');

      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task.copyWith(taskStatus: 'in_progress');
        tasks.refresh();
        print('DEBUG: Task ${task.id} status updated to in_progress locally.');
      }

      // যদি API কল সফলভাবে শেষ হয়, কিন্তু আপনি একটি ত্রুটি বার্তা দেখছেন,
      // তবে সম্ভবত আপনার TaskService এর error handling 201 কোডটিকেও error হিসেবে ধরছে।

    } catch (e) {
      // যদি Check-In failed: (Status: 201) আসে, কিন্তু আপনি চান যে এটি সফল হোক,
      // তাহলে আপনার TaskService.checkInTask মেথড সংশোধন করতে হবে।

      // সাময়িকভাবে শুধুমাত্র 201 কোডকে অগ্রাহ্য করতে চাইলে:
      if (e.toString().contains('Status: 201')) {
        print('DEBUG: Task ${task.id} Check-In successful, despite 201 being caught as an error.');
        checkInStatus[task.id] = true; // লোকালি আপডেট করুন
        checkInStatus.refresh();
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = task.copyWith(taskStatus: 'in_progress');
          tasks.refresh();
        }
      } else {
        print('DEBUG: Check-In failed for Task ${task.id}: $e');
        // আসল এরর হ্যান্ডলিং
      }
    }
  }

  Future<void> handleCompletion(Task task) async {
    print('DEBUG: Starting Completion for Task: ${task.id}');
    try {
      await _taskService.processTaskCompletion(task.id, task.agentId);

      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task.copyWith(taskStatus: 'completed');
        tasks.refresh();
        print('DEBUG: Task ${task.id} status updated to completed locally.');
      }

      checkInStatus.remove(task.id);
      print('DEBUG: Task ${task.id} completion successful.');

    } catch (e) {
      print('DEBUG: Completion failed for Task ${task.id}: $e');
    }
  }
}
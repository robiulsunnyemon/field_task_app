import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/dashboard_task.dart';
import '../../../routes/app_pages.dart';
import '../../../core/exception/api_exception.dart';


class DashboardController extends GetxController with GetSingleTickerProviderStateMixin {


  // Tab Controller
  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;

  static const String _allTasksUrl = "${AppConstants.baseUrl}/api/v1/tasks/";

  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxBool isLoadingTasks = true.obs;
  final RxString taskError = ''.obs;



  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    fetchAllTasks();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchAllTasks() async {

    isLoadingTasks.value = true;
    taskError.value = '';

    final url = Uri.parse(_allTasksUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<TaskModel> fetchedTasks = taskListFromJson(response.body);
        allTasks.assignAll(fetchedTasks);
        taskError.value = '';
        print('DEBUG: Successfully fetched ${allTasks.length} all tasks.');
      } else if (response.statusCode == 401) {
        Get.snackbar("Auth Error", "Session expired. Please log in again.", backgroundColor: Colors.red);
        Get.offAllNamed(Routes.LOGIN);
      } else {
        final data = jsonDecode(response.body);
        throw ApiException(data["message"] ?? "Failed to fetch all tasks.", statusCode: response.statusCode);
      }

    } on ApiException catch (e) {
      taskError.value = e.message;
      Get.snackbar("API Error", e.message, backgroundColor: Colors.red);
    } catch (e) {
      taskError.value = 'An unexpected error occurred: $e';
      Get.snackbar("Error", "Could not fetch tasks: $e", backgroundColor: Colors.red);
    } finally {
      isLoadingTasks.value = false;
    }
  }


  Future<void> createNewTask(Map<String, dynamic> taskData) async {
    Get.snackbar("Task Creation", "Task creation logic not implemented yet.", backgroundColor: Colors.yellow);
    print("Task Data to be sent: $taskData");
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/task_model.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<HomeController>() == false) {
      Get.put(HomeController());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,

        title: Obx(() => Text(
          'Welcome, ${controller.userName.value}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        )),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchMyTasks,
            tooltip: 'Refresh Tasks',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to log out?",
                textConfirm: "Yes",
                textCancel: "No",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  GetStorage().remove('authToken');
                  GetStorage().remove('currentUser');
                  Get.offAllNamed(Routes.LOGIN);
                },
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty && controller.tasks.isEmpty) {
          return Center(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.signal_cellular_off, color: Colors.grey, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      controller.error.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: controller.fetchMyTasks,
                      child: const Text('Try Refresh'),
                    )
                  ],
                )
            ),
          );
        }

        if (controller.tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks assigned to you yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyTasks,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return _buildTaskCard(task);
            },
          ),
        );
      }),
    );
  }


  Widget _buildTaskCard(Task task) {

    Color statusColor;
    final String status = task.taskStatus.toLowerCase();

    String statusText = status.capitalizeFirst ?? 'Unknown';

    final RxBool withinRange = controller.isWithinRange(task.id);


    switch (status) {
      case 'pending':
        statusColor = Colors.orange.shade600;
        break;

      case 'complete':
      case 'completed':
        statusColor = Colors.green.shade600;
        break;
      case 'in_progress':
        statusColor = Colors.blue.shade600;
        break;
      default:
        statusColor = Colors.grey.shade600;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.pin_drop, 'Location:', 'Lat: ${task.lati.substring(0, 8)}... | Long: ${task.longi.substring(0, 8)}...'),
            _buildDetailRow(Icons.calendar_today, 'Created:', '${task.createdAt.day}-${task.createdAt.month}-${task.createdAt.year}'),
            const SizedBox(height: 10),


            Align(
              alignment: Alignment.centerRight,
              child: Obx(() {


                final isTaskCompleted = status == 'completed' || status == 'complete';
                final isTaskInProgress = status == 'inprogress';
                final isTaskPending = status == 'pending';
                final isLocallyCheckedIn = controller.checkInStatus[task.id] ?? false;
                final isWithinRange = withinRange.value;


                print('--- UI DEBUG for Task name:${task.title} id: ${task.id} ---');
                print('Status: ${task.taskStatus}');
                print('isLocallyCheckedIn: $isLocallyCheckedIn');
                print('isWithinRange: $isWithinRange');


                if (isTaskCompleted) {
                  print('UI: Showing COMPLETED Chip (Final State).');
                  return const Chip(
                    label: Text('COMPLETED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.green,
                  );
                }


                if ((isTaskInProgress || isLocallyCheckedIn) && isWithinRange) {
                  print('UI: Showing COMPLETE TASK button.');
                  return ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : () => controller.handleCompletion(task),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('COMPLETE TASK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }


                if (isTaskPending && isWithinRange) {
                  print('UI: Showing CHECK IN button.');
                  return ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : () => controller.handleCheckIn(task),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('CHECK IN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }


                print('UI: Showing VIEW ON MAP button (Outside Range or Other).');
                return ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      "Navigation",
                      "Opening map to task location (${task.lati}, ${task.longi})",
                      backgroundColor: Colors.yellow.shade800,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.location_on, size: 18),
                  label: const Text('VIEW ON MAP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textColor.withValues(alpha: 0.8)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
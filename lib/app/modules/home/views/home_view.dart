import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/task.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<HomeController>() == false) {
      Get.put(HomeController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor:  AppColors.primaryColor,
        backgroundColor:  AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,

        title: Obx(() {
          final firstName = controller.currentUser.value?.firstName ?? 'Agent';
          return Text(
            'Welcome, $firstName',
            style: const TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold),
          );
        }),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchUserInfoAndTasks,
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
                  GetStorage().remove('currentUserData');
                  Get.offAllNamed(Routes.LOGIN);
                },
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [

          _buildTaskSummary(),


          Expanded(
            child: Obx(() {
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.defaultDialog(
            title: "Logout",
            middleText: "Are you sure you want to log out and move Dashboard?",
            textConfirm: "Yes",
            textCancel: "No",
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              GetStorage().remove('authToken');
              GetStorage().remove('currentUserData');
              Get.offAllNamed(Routes.DASHBOARD_LOGIN);
            },
          );
        },
        backgroundColor: AppColors.secondaryColor,
        child: const Icon(Icons.swap_horiz,color: Colors.white,),
      ),
    );
  }


  Widget _buildTaskSummary() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
            colors: [

              AppColors.primaryColor,
              AppColors.secondaryColor,


            ]
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight:Radius.circular(12) ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
              'Pending',
              controller.pendingTasksCount,
              Colors.orange.shade600,
              Icons.access_time_filled
          ),
          _buildSummaryItem(
              'In Progress',
              controller.inProgressTasksCount,
              Colors.blue.shade600,
              Icons.auto_stories
          ),
          _buildSummaryItem(
              'Completed',
              controller.completedTasksCount,
              Colors.green.shade600,
              Icons.check_circle_rounded
          ),
        ],
      ),
    ));
  }


  Widget _buildSummaryItem(String title, int count, Color color, IconData icon) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


  Widget _buildTaskCard(Task task) {

    Color statusColor;
    final String status = task.taskStatus.toLowerCase();

    String statusText = status.capitalizeFirst ?? 'Unknown';

    switch (status) {
      case 'pending':
        statusColor = Colors.orange.shade600;
        break;

      case 'complete':
      case 'completed':
        statusColor = Colors.green.shade600;
        break;
      case 'inprogress':
        statusColor = Colors.blue.shade600;
        break;
      default:
        statusColor = Colors.grey.shade600;
    }

    return Card(
      elevation: 4,
      color: Colors.white,
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
            _buildDetailRow(Icons.pin_drop, 'Location:', 'Lat: ${task.lati.substring(0, 8)}...'),
            _buildDetailRow(Icons.pin_drop, 'Location:', 'Long: ${task.longi.substring(0, 8)}...'),
            _buildDetailRow(Icons.calendar_today, 'Created:', '${task.createdAt.day}-${task.createdAt.month}-${task.createdAt.year}'),
            const SizedBox(height: 10),


            Align(
              alignment: Alignment.centerRight,
              child: Obx(() {

                final bool isWithinRange = controller.isWithinRange(task.id);


                final isTaskCompleted = status == 'completed' || status == 'complete';
                final isTaskInProgress = status == 'inprogress';
                final isTaskPending = status == 'pending';
                final isLocallyCheckedIn = controller.checkInStatus[task.id] ?? false;

                final isCurrentTaskInProgress = isTaskInProgress || isLocallyCheckedIn;


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


                if (isCurrentTaskInProgress && isWithinRange) {
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
                  onPressed: () => controller.navigateToTaskLocation(task),
                  icon: const Icon(Icons.location_on, size: 18),
                  label: const Text('VIEW ON MAP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffB33771),
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
          Icon(icon, size: 16, color: AppColors.textColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textColor.withOpacity(0.8)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
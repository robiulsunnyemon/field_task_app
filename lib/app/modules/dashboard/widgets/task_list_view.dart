import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_colors.dart';
import '../../../data/models/dashboard_task.dart';
import '../controllers/dashboard_controller.dart';

class TaskListView extends StatelessWidget {

   TaskListView({super.key});

  final controller=Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTasks.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.taskError.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${controller.taskError.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: controller.fetchAllTasks,
                child: const Text('Retry Fetch'),
              )
            ],
          ),
        );
      }

      if (controller.allTasks.isEmpty) {
        return const Center(
          child: Text(
            'No tasks found on the server.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchAllTasks,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: controller.allTasks.length,
          itemBuilder: (context, index) {
            final task = controller.allTasks[index];
            return _buildTaskCard(task);
          },
        ),
      );
    });
  }


  Widget _buildTaskCard(TaskModel task) {
    Color statusColor;
    final String status = task.taskStatus.toLowerCase();
    String statusText = status.replaceAll('_', ' ').capitalizeFirst ?? 'Unknown';

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
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      fontSize: 17,
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
            const Divider(height: 15),


            _buildDetailRow(Icons.person, 'Agent:', task.agentName),
            const SizedBox(height: 5),


            _buildDetailRow(
                Icons.location_on,
                'Location:',
                'Lat: ${task.lati.substring(0, 8)}..., Long: ${task.longi.substring(0, 8)}...'
            ),
            const SizedBox(height: 5),


            _buildDetailRow(
                Icons.calendar_today,
                'Created:',
                '${task.createdAt.day}-${task.createdAt.month}-${task.createdAt.year}'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
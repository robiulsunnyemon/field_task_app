import 'package:field_task_app/app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/location_picker.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../controllers/create_task_controller.dart';

class CreateTaskView extends StatelessWidget {
  const CreateTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateTaskController controller = Get.put(CreateTaskController());
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: controller.titleController,
              decoration: _inputDecoration(
                label: 'Task Title',
                icon: Icons.assignment,
              ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              if (controller.isAgentsLoading.value) {
                return const Center(child: LinearProgressIndicator());
              }

              return DropdownButtonFormField<String>(
                decoration: _inputDecoration(
                  label: 'Select Agent',
                  icon: Icons.person_add,
                ),
                initialValue: controller.selectedAgentId.value.isEmpty
                    ? null
                    : controller.selectedAgentId.value,
                hint: const Text('Select Agent'),
                dropdownColor: Colors.white,
                items: controller.agentsList.map<DropdownMenuItem<String>>((
                  User agent,
                ) {
                  return DropdownMenuItem<String>(
                    value: agent.id,
                    child: Text(agent.fullName),
                  );
                }).toList(),
                onChanged: controller.onAgentIdChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an agent';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 24),

            Obx(() {
              if (controller.selectedAgentId.value.isEmpty) {
                return DropdownButtonFormField<String>(
                  decoration: _inputDecoration(
                    label: 'Parent Task (Select Agent First)',
                    icon: Icons.business,
                  ),
                  initialValue: null,
                  hint: const Text('Select Agent first to load tasks'),
                  items: const [],
                  onChanged: null,
                );
              }

              if (controller.isParentTasksLoading.value) {
                return const Center(child: LinearProgressIndicator());
              }

              return DropdownButtonFormField<String>(
                decoration: _inputDecoration(
                  label: 'Parent Task (Optional)',
                  icon: Icons.business,

                ),
                dropdownColor: Colors.white,
                initialValue: controller.selectedParentTaskId.value.isEmpty
                    ? null
                    : controller.selectedParentTaskId.value,
                hint: const Text('Select Parent Task (Optional)'),

                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text(
                      '--- No Parent Task ---',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  ...controller.parentTasksList.map((TaskModel task) {
                    return DropdownMenuItem(
                      value: task.id,
                      child: Text(task.title),
                    );
                  }),
                ],
                onChanged: controller.onParentTaskIdChanged,
              );
            }),
            const SizedBox(height: 24),



            ElevatedButton.icon(
              onPressed: () {

                Get.to(() => LocationPickerScreen());
              },
              icon: const Icon(Icons.map, color: AppColors.primaryColor),
              label: const Text(
                'Pick Location',
                style: TextStyle(color: AppColors.primaryColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.primaryColor)
                ),

              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Location Coordinates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Obx(
                  () => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude: ${controller.lati.value.isEmpty ? 'Not Picked' : controller.lati.value}',
                      style: TextStyle(
                        color: controller.lati.value.isEmpty
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'Longitude: ${controller.longi.value.isEmpty ? 'Not Picked' : controller.longi.value}',
                      style: TextStyle(
                        color: controller.longi.value.isEmpty
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),




            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'CREATE TASK',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      prefixIcon: Icon(icon),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
    );
  }
}

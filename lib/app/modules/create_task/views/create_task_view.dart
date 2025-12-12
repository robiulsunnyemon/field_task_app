import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/location_picker.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../controllers/create_task_controller.dart';

class CreateTaskView extends GetView<CreateTaskController> {
  const CreateTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
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

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {

                Get.to(() => LocationPickerScreen());
              },
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text(
                'Pick Location from Map (OSM)',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 40),


            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
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
    );
  }
}

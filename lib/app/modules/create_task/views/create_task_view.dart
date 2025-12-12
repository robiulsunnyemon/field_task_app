import 'package:field_task_app/app/modules/create_task/controllers/create_task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/location_picker.dart';



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
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task description or name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.assignment),
              ),
            ),
            const SizedBox(height: 16),


            TextFormField(
              controller: controller.parentIdController,
              decoration: InputDecoration(
                labelText: 'Parent Task ID (Optional)',
                hintText: 'Enter ID of the prerequisite task',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),


            const Text(
              'Location Coordinates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Obx(() => Container(
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
                    style: TextStyle(color: controller.lati.value.isEmpty ? Colors.red : Colors.black),
                  ),
                  Text(
                    'Longitude: ${controller.longi.value.isEmpty ? 'Not Picked' : controller.longi.value}',
                    style: TextStyle(color: controller.longi.value.isEmpty ? Colors.red : Colors.black),
                  ),
                ],
              ),
            )),

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 40),


            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.createTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
                  : const Text(
                'CREATE TASK',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )),

            const SizedBox(height: 20),
            Obx(() => controller.agentId.value.isEmpty
                ? const Text("Error: Agent ID not loaded.", style: TextStyle(color: Colors.red))
                : Text("Agent ID: ${controller.agentId.value.substring(0, 8)}...", style: const TextStyle(fontSize: 12, color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
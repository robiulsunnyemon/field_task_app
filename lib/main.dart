import 'package:field_task_app/app/core/field_task/field_task.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'app/core/services/location_service.dart';
import 'app/core/services/task_service.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(LocationService());
  Get.put(TaskService());
  runApp(
   FieldTask()
  );
}

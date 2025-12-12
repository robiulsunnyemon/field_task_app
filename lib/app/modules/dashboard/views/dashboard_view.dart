import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../create_task/views/create_task_view.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../widgets/task_list_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<DashboardController>() == false) {
      Get.put(DashboardController());
    }


    final DashboardController controller = Get.find<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Task Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'All Tasks'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Create Task'),
          ],
        ),
      ),

      body: TabBarView(
        controller: controller.tabController,
        children: [

          TaskListView(),
          const CreateTaskView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.defaultDialog(
            title: "Logout",
            middleText: "Are you sure to log out?",
            textConfirm: "Yes",
            textCancel: "No",
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              final box=GetStorage();
              box.remove("isDashboard");
              Get.offAllNamed(Routes.ONBOARDING);
            },
          );
        },
        backgroundColor: AppColors.secondaryColor,
        child: const Icon(Icons.swap_horiz,color: Colors.white,),
      ),
    );
  }
}
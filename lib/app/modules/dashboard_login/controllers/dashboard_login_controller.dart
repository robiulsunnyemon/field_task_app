import 'package:field_task_app/app/core/utils/app_colors.dart';
import 'package:field_task_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DashboardLoginController extends GetxController {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  final isObscure = true.obs;


  final String correctEmail = "robiulsunyemon@gmail.com";
  final String correctPassword = "123456";

  Future<void> login() async {

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email == correctEmail && password == correctPassword) {

      Get.snackbar(
        "Success",
        "Login Successful! Navigating to Dashboard.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      final box = GetStorage();
      await box.write("isDashboard", "true");


      Get.offAllNamed(Routes.DASHBOARD);

    } else {

      Get.snackbar(
          "Warning",
          "Invalid email or password. Please use the demo credentials.",
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
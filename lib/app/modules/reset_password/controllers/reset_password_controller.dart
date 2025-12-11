import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/exception/api_exception.dart';
import '../../../routes/app_pages.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final isLoading = false.obs;


  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;


  final RxString userEmail = ''.obs;

  static const String _resetPasswordUrl = "${AppConstants.baseUrl}/api/v1/auth/reset_password";

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is String) {
      userEmail.value = Get.arguments as String;
    } else {
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar("Error", "Session expired. Please restart the password recovery process.",
        backgroundColor: Colors.red.shade400, colorText: Colors.white,
      );
    }
  }

  void toggleNewPasswordVisibility() => isNewPasswordHidden.value = !isNewPasswordHidden.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;


  void resetPassword() {
    if (formKey.currentState!.validate()) {
      resetPasswordApiCall(
        userEmail.value,
        newPasswordController.text,
      );
    }
  }

  Future<void> resetPasswordApiCall(String email, String newPassword) async {
    isLoading.value = true;
    Get.defaultDialog(
      title: "Resetting Password...",
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );

    final url = Uri.parse(_resetPasswordUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "new_password": newPassword
        }),
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {

        Get.snackbar("Success", "Password successfully reset! Please log in.",
            backgroundColor: Colors.green, colorText: Colors.white);


        Get.offAllNamed(Routes.LOGIN);

      } else {
        final data = jsonDecode(response.body);
        throw ApiException(data["message"] ?? "Password reset failed.", statusCode: response.statusCode);
      }

    } on ApiException catch (e) {
      Get.snackbar("Error", e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred.", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

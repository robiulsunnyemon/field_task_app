import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/exception/api_exception.dart';
import '../../../routes/app_pages.dart';

class ForgetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final isLoading = false.obs;


  static const String _sendOtpUrl = "${AppConstants.baseUrl}/api/v1/auth/resend_otp";

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void sendOtpRequest() {
    if (formKey.currentState!.validate()) {
      sendOtpApiCall(emailController.text);
    }
  }

  Future<void> sendOtpApiCall(String email) async {
    isLoading.value = true;
    Get.defaultDialog(
      title: "Sending Code...",
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );

    final url = Uri.parse(_sendOtpUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {

        Get.snackbar("Success", "Verification code sent to $email",
            backgroundColor: Colors.green, colorText: Colors.white);

        Get.offAllNamed(Routes.RESET_PASSWORD_VERIFICATION, arguments: email);

      } else {
        final data = jsonDecode(response.body);
        throw ApiException(data["message"] ?? "Failed to send OTP.", statusCode: response.statusCode);
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
}

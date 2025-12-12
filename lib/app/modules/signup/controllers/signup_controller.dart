

import 'dart:convert';
import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:field_task_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/exception/api_exception.dart';

class SignupController extends GetxController {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> signup() async {
    isLoading.value = true;
    final url = Uri.parse("${AppConstants.baseUrl}/api/v1/auth/signup");
    final data={
      "first_name":nameController.text.trim(),
      "last_name": "null",
      "email":emailController.text.trim(),
      "phone_number": "null",
      "password": passwordController.text.trim(),
      "auth_provider": "email"
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      isLoading.value = false;



      // Handle non-200 responses
      if (response.statusCode!= 201) {
        final data = jsonDecode(response.body);

        throw ApiException(
          data["message"] ?? "Signup failed",
          statusCode: response.statusCode,
        );
      }

      // Success Case

      Get.snackbar(
        'Success',
        'Account created successfully for ${nameController.text.trim()}!',
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );

      Get.offAllNamed(Routes.OTP_VERIFY,arguments: emailController.text.trim());


    } on ApiException {
      rethrow;

    } on http.ClientException catch (_) {
      throw ApiException("Network error — Please check your internet connection.");

    } on FormatException catch (_) {
      throw ApiException("Invalid server response format.");

    } catch (e) {
      throw ApiException("Something went wrong. Please try again.\nError: $e");
    }finally{
      isLoading.value = false;
    }
  }
}
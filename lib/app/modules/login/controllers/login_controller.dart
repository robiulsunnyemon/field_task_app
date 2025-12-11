// lib/controllers/login_controller.dart

import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:field_task_app/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/exception/api_exception.dart';


class LoginController extends GetxController {


  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(text: "robiulsunyemon@gmail.com");
  final TextEditingController passwordController = TextEditingController(text: "123456");


  final isLoading = false.obs;


  static const String _loginUrl = "${AppConstants.baseUrl}/api/v1/auth/login";


  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void handleLogin() {
    if (formKey.currentState!.validate()) {
      loginApiCall();
    }
  }


  Future<void> loginApiCall() async {
    final email = emailController.text;
    final password = passwordController.text;

    isLoading.value = true;


    Get.defaultDialog(
      title: "Logging In...",
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );

    final url = Uri.parse(_loginUrl);


    final Map<String, String> body = {
      'username': email,
      'password': password,
    };


    final encodedBody = body.keys.map((key) => '$key=${Uri.encodeQueryComponent(body[key]!)}').join('&');


    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
        body: encodedBody,
      );


      if (Get.isDialogOpen ?? false) {
        Get.back();
      }


      // Response Handle
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data["access_token"]);

        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );


        Get.offAllNamed(Routes.HOME);

      } else {

        final data = jsonDecode(response.body);
        throw ApiException(
          data["message"] ?? "Login failed. Please check your credentials.",
          statusCode: response.statusCode,
        );
      }

    } on ApiException catch (e) {
      Get.snackbar("Login Failed", e.message,
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      rethrow;

    } on http.ClientException catch (_) {
      Get.snackbar("Network Error", "Please check your internet connection.",
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      throw ApiException("Network error – Please check your internet connection.");

    } catch (e) {
      Get.snackbar("Error", "Something went wrong. Please try again.",
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      throw ApiException("Something went wrong. Please try again.\nError: $e");
    } finally {
      isLoading.value = false;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }
}
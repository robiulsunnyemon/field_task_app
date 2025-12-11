// lib/controllers/login_controller.dart

import 'package:field_task_app/app/core/constants/app_constants.dart';
import 'package:field_task_app/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/exception/api_exception.dart';


// class LoginController extends GetxController {
//
//
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController(text: "robiulsunyemon@gmail.com");
//   final TextEditingController passwordController = TextEditingController(text: "123456");
//
//
//   final isLoading = false.obs;
//
//
//   static const String _loginUrl = "${AppConstants.baseUrl}/api/v1/auth/login";
//
//
//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
//
//   void handleLogin() {
//     if (formKey.currentState!.validate()) {
//       loginApiCall();
//     }
//   }
//
//
//   Future<void> loginApiCall() async {
//     final email = emailController.text;
//     final password = passwordController.text;
//
//     isLoading.value = true;
//
//
//     Get.defaultDialog(
//       title: "Logging In...",
//       content: const CircularProgressIndicator(),
//       barrierDismissible: false,
//     );
//
//     final url = Uri.parse(_loginUrl);
//
//
//     final Map<String, String> body = {
//       'username': email,
//       'password': password,
//     };
//
//
//     final encodedBody = body.keys.map((key) => '$key=${Uri.encodeQueryComponent(body[key]!)}').join('&');
//
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/x-www-form-urlencoded",
//           "Accept": "application/json",
//         },
//         body: encodedBody,
//       );
//
//
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//
//
//       // Response Handle
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print(data["access_token"]);
//
//         Get.snackbar(
//           'Success',
//           'Login successful!',
//           backgroundColor: Colors.green.shade400,
//           colorText: Colors.white,
//         );
//
//
//         Get.offAllNamed(Routes.HOME);
//
//       } else {
//
//         final data = jsonDecode(response.body);
//         throw ApiException(
//           data["message"] ?? "Login failed. Please check your credentials.",
//           statusCode: response.statusCode,
//         );
//       }
//
//     } on ApiException catch (e) {
//       Get.snackbar("Login Failed", e.message,
//           backgroundColor: Colors.red.shade400, colorText: Colors.white);
//       rethrow;
//
//     } on http.ClientException catch (_) {
//       Get.snackbar("Network Error", "Please check your internet connection.",
//           backgroundColor: Colors.red.shade400, colorText: Colors.white);
//       throw ApiException("Network error – Please check your internet connection.");
//
//     } catch (e) {
//       Get.snackbar("Error", "Something went wrong. Please try again.",
//           backgroundColor: Colors.red.shade400, colorText: Colors.white);
//       throw ApiException("Something went wrong. Please try again.\nError: $e");
//     } finally {
//       isLoading.value = false;
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       }
//     }
//   }
// }



// lib/controllers/login_controller.dart

import 'package:get_storage/get_storage.dart'; // <--- নতুন ইম্পোর্ট



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
      // আপনার API এ যদি 'email' এর পরিবর্তে 'username' লাগে, তবে এটি ঠিক আছে।
      // যদি শুধু 'email' লাগে তবে 'username' কে 'email' করুন।
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

        // 💾 GetStorage এ ডেটা সেভ করার লজিক
        final box = GetStorage();

        // 1. Access Token সেভ করা
        final token = data["access_token"];
        await box.write('authToken', token);

        // 2. সম্পূর্ণ ইউজার ডেটা সেভ করা (API response এ থাকা অন্যান্য ডেটা সহ)
        // এটি ম্যাপ আকারে সেভ হবে, যা আপনি পরে অন্য কন্ট্রোলারে ব্যবহার করতে পারবেন
        await box.write('currentUserData', data);

        print("Access Token Saved: $token"); // টোকেন সেভ হয়েছে কিনা দেখা

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
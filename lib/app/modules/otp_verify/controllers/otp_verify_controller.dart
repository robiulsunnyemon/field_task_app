
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../../core/constants/app_constants.dart';
import '../../../core/exception/api_exception.dart';
import 'package:field_task_app/app/routes/app_pages.dart';

class OtpVerifyController extends GetxController {

  late List<TextEditingController> otpControllers;
  final isLoading = false.obs;

  RxInt timerSeconds = 20.obs;
  RxBool canResend = false.obs;
  late Timer _timer;

  final RxString userEmail = ''.obs;


  static const String _resendOtpUrl = "${AppConstants.baseUrl}/api/v1/auth/resend_otp";

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is String) {
      userEmail.value = Get.arguments as String;
    } else {
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar("Error", "Missing required email data for OTP verification.",
        backgroundColor: Colors.red.shade400, colorText: Colors.white,
      );
      return;
    }

    otpControllers = List.generate(6, (index) => TextEditingController());
    startTimer();
  }


  void startTimer() {
    canResend.value = false;
    timerSeconds.value = 20;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        timer.cancel();
        canResend.value = true;
      }
    });
  }


  void resendOtp() {
    if (canResend.value) {
      resendOtpFunc(userEmail.value);
    }
  }


  Future<void> resendOtpFunc(String email) async {
    Get.snackbar(
      'Sending OTP',
      'Requesting new OTP for $email...',
      backgroundColor: Colors.blueGrey,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    final url = Uri.parse(_resendOtpUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        startTimer();
        Get.snackbar(
          'OTP Sent',
          'New OTP has been successfully sent to $email.',
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
      } else {
        final data = jsonDecode(response.body);
        throw ApiException(
          data["message"] ?? "Failed to resend OTP",
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar("Resend Failed", e.message,
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Could not resend OTP. Check connection.",
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
    }
  }


  void verifyOtp() {
    String otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter the complete 6-digit OTP.',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    otpVerificationFunc(userEmail.value, otp);
  }


  Future<void> otpVerificationFunc(String email,String otp) async {
    isLoading.value = true;
    Get.defaultDialog(
      title: "Verifying...",
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );

    final url = Uri.parse("${AppConstants.baseUrl}/api/v1/auth/otp_verify");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );


      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Handle non-200 responses
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw ApiException(
          data["message"] ?? "OTP verification failed",
          statusCode: response.statusCode,
        );
      }

      // Success Case (Status Code 200)
      Get.snackbar(
        'Success',
        'OTP successfully verified!',
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );

      Get.offAllNamed(Routes.LOGIN);

    } on ApiException catch (e) {
      Get.snackbar("Verification Failed", e.message,
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      rethrow;

    } on http.ClientException catch (_) {
      Get.snackbar("Network Error", "Please check your internet connection.",
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      throw ApiException("Network error – Please check your internet connection.");

    } on FormatException catch (_) {
      Get.snackbar("Error", "Invalid server response format.",
          backgroundColor: Colors.red.shade400, colorText: Colors.white);
      throw ApiException("Invalid server response format.");

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


  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    _timer.cancel();
    super.onClose();
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/exception/api_exception.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';



class AuthRepository {
  final String baseUrl = "https://example.com/api";

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/auth");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": name,
          "last_name": "null",
          "email":email,
          "phone_number": "null",
          "password": password,
          "auth_provider": "email"
        }),
      );

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
        'Account created successfully for $name!',
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );

      Get.toNamed(Routes.OTP_VERIFY);


    } on ApiException {

      rethrow;

    } on http.ClientException catch (_) {
      throw ApiException("Network error — Please check your internet connection.");

    } on FormatException catch (_) {
      throw ApiException("Invalid server response format.");

    } catch (e) {
      throw ApiException("Something went wrong. Please try again.\nError: $e");
    }
  }
}

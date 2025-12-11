import 'package:get/get.dart';
import 'package:flutter/material.dart';
class LoginController extends GetxController {


  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _handleLogin() {
    if (formKey.currentState!.validate()) {
      String email = emailController.text;
      String password = passwordController.text;

    }
  }
}

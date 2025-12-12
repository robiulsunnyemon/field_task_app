
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../controllers/signup_controller.dart';


class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your account to unlock all features.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textColor.withValues(alpha:0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),


              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[

                      _buildInputField(
                        controller: controller.nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 20),


                      _buildInputField(
                        controller: controller.emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 20),


                      _buildInputField(
                        controller: controller.passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: controller.confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_open,
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),

                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : () => _validateAndSignup(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: AppColors.textColor)),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _validateAndSignup() {
    if (controller.nameController.text.isEmpty ||
        controller.emailController.text.isEmpty ||
        controller.passwordController.text.isEmpty ||
        controller.confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required.',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (controller.passwordController.text != controller.confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match.',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    controller.signup();
  }



  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.textColor),
      cursorColor: AppColors.primaryColor,


      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
    );
  }
}
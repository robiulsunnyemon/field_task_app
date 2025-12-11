import 'package:field_task_app/app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              SizedBox(
                height: size.height * 0.4,
                child: Image.asset(
                  'assets/imgs/task.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),


              Text(
                'Welcome!',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),


              Text(
                'Please select your role to continue to the login.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              _buildLoginButton(
                context,
                text: 'Login as Field Agent',
                icon: Icons.person_pin_circle,
                color: AppColors.primaryColor,
                onPressed:(){}
              ),

              const SizedBox(height: 20),

              _buildLoginButton(
                context,
                text: 'Login as Admin',
                icon: Icons.security,
                  color: AppColors.primaryColor,
                onPressed: (){}
              ),

            ],
          ),
        ),
      ),
    );
  }
}


Widget _buildLoginButton(
    BuildContext context, {
      required String text,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed,
    }) {
  return ElevatedButton.icon(
    icon: Icon(icon, color: Colors.white, size: 24),
    label: Text(
      text,style: TextStyle(
      color: Colors.white
    ),
    ),
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      minimumSize: const Size(double.infinity, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 5,
    ),
  );
}


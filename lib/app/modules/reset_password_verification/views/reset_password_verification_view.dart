
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../controllers/reset_password_verification_controller.dart';

class ResetPasswordVerificationView
    extends GetView<ResetPasswordVerificationController> {
  const ResetPasswordVerificationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('OTP Verification', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please enter the 6-digit code sent to your email/phone.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textColor.withValues(alpha:0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _otpTextField(context, index)),
              ),
              const SizedBox(height: 40),


              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),


              Obx(() => Column(
                children: [
                  Text(
                    controller.canResend.value
                        ? "Didn't receive code?"
                        : "Resend code in ${controller.timerSeconds.value}s",
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.canResend.value ? AppColors.textColor : AppColors.textColor.withValues(alpha:0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: controller.canResend.value ? controller.resendOtp : null,
                    child: Text(
                      'RESEND OTP',
                      style: TextStyle(
                        color: controller.canResend.value ? AppColors.primaryColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }


  Widget _otpTextField(BuildContext context, int index) {
    return SizedBox(
      width: 45,
      child: TextFormField(
        controller: controller.otpControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha:0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          counterText: "",
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {

            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {

            FocusScope.of(context).previousFocus();
          }
          if (index == 5 && value.isNotEmpty) {

            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }
}

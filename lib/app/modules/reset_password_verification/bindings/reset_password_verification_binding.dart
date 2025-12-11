import 'package:get/get.dart';

import '../controllers/reset_password_verification_controller.dart';

class ResetPasswordVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordVerificationController>(
      () => ResetPasswordVerificationController(),
    );
  }
}

import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  @override
  void onInit() {

    Timer(const Duration(seconds: 3), () {
      Get.offNamed(Routes.ONBOARDING);
    });
    super.onInit();
  }


}

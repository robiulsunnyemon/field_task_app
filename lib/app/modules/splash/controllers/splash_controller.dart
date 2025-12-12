import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final GetStorage _box = GetStorage();
  @override
  void onInit() {

    Timer(const Duration(seconds: 3), () {
      final token = _box.read('authToken');
      if(token!=null){
        Get.offNamed(Routes.HOME);
      }else{
        Get.offNamed(Routes.ONBOARDING);
      }
    });
    super.onInit();
  }


}

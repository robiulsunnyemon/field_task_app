import 'package:get/get.dart';

import '../controllers/dashboard_login_controller.dart';

class DashboardLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardLoginController>(
      () => DashboardLoginController(),
    );
  }
}

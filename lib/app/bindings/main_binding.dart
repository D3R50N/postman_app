import 'package:get/get.dart';
import 'package:postman_app/app/bindings/home_binding.dart';
import '../controllers/main_controller.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
  }
}

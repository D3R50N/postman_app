import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postman_app/app/routes/route.dart';

class WelcomeController extends GetxController {
  RxString loadingText = "Chargement...".obs;
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(Routes.home);
    });
  }
}

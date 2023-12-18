import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postman_app/app/controllers/home_controller.dart';
import 'package:postman_app/app/routes/route.dart';

class MainController extends GetxController with GetTickerProviderStateMixin {
  RxList<Onglet> onglets = <Onglet>[].obs;
  RxInt currentOnglet = 0.obs;
  late Rx<TabController> tabController =
      Rx<TabController>(TabController(length: onglets.length, vsync: this));

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    tabController.value.addListener(listener);
    newOnglet();
  }

  void newOnglet() {
    int id = onglets.length;
    if (onglets.where((p0) => p0.id == id).isNotEmpty) {
      id = onglets.length + 1;
    }
    onglets.add(
        Onglet(id, controller: HomeController())..name = "Onglet ${id + 1}");
    tabController.value = TabController(length: onglets.length, vsync: this);
    tabController.value.addListener(listener);
    tabController.value.animateTo(onglets.length - 1);
  }

  void goto(int index) {
    tabController.value.animateTo(index);
  }

  void listener() {
    currentOnglet.value = tabController.value.index;
  }

  void history() {
    Get.toNamed(Routes.history);
  }
}

class Onglet {
  String name;
  int id;

  HomeController controller;

  Onglet(
    this.id, {
    this.name = 'Onglet',
    required this.controller,
  });
}

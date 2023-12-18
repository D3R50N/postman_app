import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:postman_app/app/ui/pages/home_page/home_page.dart';
import '../../../controllers/main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LePosteur'),
        actions: [
          IconButton(
            onPressed: () => controller.newOnglet(),
            icon: const Icon(Icons.add),
          ),
          const Gap(10),
          // history
          IconButton(
            onPressed: () => controller.history(),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Obx(
        () => SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: controller.onglets
                        .map(
                          (element) => GestureDetector(
                            onTap: () {
                              controller
                                  .goto(controller.onglets.indexOf(element));
                            },
                            child: Obx(
                              () => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                constraints:
                                    const BoxConstraints(minHeight: 40),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: controller.currentOnglet.value ==
                                          controller.onglets.indexOf(element)
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    const Gap(5),
                                    Text(
                                      element.name,
                                      style: TextStyle(
                                        color: controller.currentOnglet.value ==
                                                controller.onglets
                                                    .indexOf(element)
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    AnimatedContainer(
                                      margin: const EdgeInsets.only(left: 10),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(),
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: controller.currentOnglet.value ==
                                                  controller.onglets
                                                      .indexOf(element) &&
                                              controller.onglets.length > 1
                                          ? 25
                                          : 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.onglets.remove(element);
                                          if (controller.onglets.length == 1) {
                                            controller.onglets.first.name =
                                                "Onglet 1";
                                            controller.currentOnglet.value = 0;
                                          }
                                          controller.tabController.value =
                                              TabController(
                                                  length:
                                                      controller.onglets.length,
                                                  vsync: controller);
                                          controller.tabController.value
                                              .addListener(controller.listener);
                                          controller.tabController.value
                                              .animateTo(
                                                  controller.onglets.length -
                                                      1);
                                        },
                                        child: const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ).animate().scaleXY(duration: 100.ms),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(
                    color: Colors.black,
                    height: 0,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController.value,
                    physics: const BouncingScrollPhysics(),
                    children: controller.onglets
                        .map(
                          (element) => HomePage(element.controller),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../controllers/welcome_controller.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                "assets/images/logo.png",
                width: Get.width * .3,
                height: Get.width * .3,
              )
                  .animate(onComplete: (c) {
                    c.loop(reverse: true);
                  })
                  .scaleXY(begin: .9, end: 1)
                  .shimmer(
                    duration: 1500.ms,
                  ),
            ),
          )
              .animate(onComplete: (c) {
                c.loop();
              })
              .rotate(delay: 100.ms, duration: 400.ms, begin: 0, end: .2)
              .then(delay: 100.ms)
              .rotate(delay: 100.ms, duration: 400.ms, begin: 0, end: .2)
              .then(delay: 100.ms)
              .rotate(delay: 100.ms, duration: 400.ms, begin: 0, end: .2)
              .then(delay: 100.ms)
              .rotate(delay: 100.ms, duration: 400.ms, begin: 0, end: .2)
              .then(delay: 100.ms)
              .rotate(delay: 100.ms, duration: 400.ms, begin: 0, end: .2),
          const Gap(20),
          Obx(() => Text(controller.loadingText.string)),
        ],
      ),
    );
  }
}

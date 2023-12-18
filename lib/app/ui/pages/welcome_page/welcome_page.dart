import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/welcome_controller.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.onInit();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/images/logo.png",
                width: Get.width * .3,
                height: Get.width * .3,
              ),
            )
                .animate(onComplete: (c) {
                  c.loop();
                })
                .rotate(delay: 100.ms, duration: 400.ms, begin: 0, end: .5)
                .then(delay: 100.ms)
                .rotate(delay: 100.ms, duration: 400.ms, begin: 0, end: .5)
                .then(delay: 100.ms),
          )
              .animate(onComplete: (c) {
                c.loop(reverse: true);
              })
              .scaleXY(begin: .9, end: 1)
              .shimmer(
                duration: 1500.ms,
              ),
        ],
      ),
    );
  }
}

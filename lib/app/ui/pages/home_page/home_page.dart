import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:postman_app/app/ui/theme/colors.dart';
import 'package:postman_app/app/ui/utils/functions.dart';
import 'package:postman_app/extensions/color_extension.dart';
import '../../../controllers/home_controller.dart';

class HomePage extends GetView {
  @override
  HomeController controller;
  HomePage(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.urlController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Entrer l\'url de la requête',
                          ),
                        ),
                      ),
                      const Gap(10),
                      DropdownMenu<String>(
                        dropdownMenuEntries: ReqType.all
                            .map(
                              (e) => DropdownMenuEntry(
                                value: e,
                                label: e,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            )
                            .toList(),
                        controller: controller.reqTypeController,
                        width: 120,
                        menuStyle: MenuStyle(
                          backgroundColor: MaterialStateProperty.all(
                            primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Obx(
                    () => MaterialButton(
                      color: controller.fetching.isTrue
                          ? Colors.grey
                          : primaryColor,
                      onPressed: () {
                        if (controller.fetching.isTrue) {
                          message("Une requête est déjà en cour..");
                          return;
                        }

                        controller.fetchUrl();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      splashColor: Colors.blueGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          controller.fetching.isTrue ? "..." : 'Envoyer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                        .animate(onComplete: (c) {
                          c.loop();
                        })
                        .shake(hz: 5, rotation: .02)
                        .then(duration: 5000.ms),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(30),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (controller
                                .paramsAnimationController.isCompleted) {
                              controller.paramsAnimationController.reverse();
                            } else {
                              controller.paramsAnimationController.forward();
                            }
                            controller.paramsOpen.toggle();
                          },
                          child: Row(
                            children: [
                              Obx(
                                () => Text(
                                  "Paramètres (${controller.params.length})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Obx(
                                () => Icon(
                                  controller.paramsOpen.isFalse
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: controller.addParams,
                          child: Text(
                            "Ajouter",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Obx(
                        () => ListView(
                          shrinkWrap: true,
                          children: controller.params
                              .map(
                                (element) => paramsWidget(element),
                              )
                              .toList(),
                        ),
                      ),
                    )
                        .animate(
                            autoPlay: false,
                            onInit: (c) {
                              controller.paramsAnimationController = c;
                            })
                        .custom(
                          builder: (context, value, child) {
                            if (controller.params.isEmpty) {
                              return const SizedBox();
                            }
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: double.maxFinite * value,
                              ),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          begin: 1,
                          end: 0,
                          duration: 100.ms,
                        ),
                    if (controller.paramsOpen.isTrue &&
                        controller.params.isNotEmpty)
                      const Gap(20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (controller
                                .headersAnimationController.isCompleted) {
                              controller.headersAnimationController.reverse();
                            } else {
                              controller.headersAnimationController.forward();
                            }
                            controller.headersOpen.toggle();
                          },
                          child: Row(
                            children: [
                              Obx(
                                () => Text(
                                  "Headers (${controller.headers.length})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Obx(
                                () => Icon(
                                  controller.headersOpen.isFalse
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: controller.addHeaders,
                          child: Text(
                            "Ajouter",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Obx(
                        () => ListView(
                          shrinkWrap: true,
                          children: controller.headers
                              .map(
                                (element) => headersWidget(element),
                              )
                              .toList(),
                        ),
                      ),
                    )
                        .animate(
                            autoPlay: false,
                            onInit: (c) {
                              controller.headersAnimationController = c;
                            })
                        .custom(
                          builder: (context, value, child) {
                            if (controller.headers.isEmpty) {
                              return const SizedBox();
                            }
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: double.maxFinite * value,
                              ),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          begin: 1,
                          end: 0,
                          duration: 100.ms,
                        ),
                    const Gap(20),
                    Obx(
                      () => Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(.1),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(.0),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: SelectableText(
                              (controller.result.value.startsWith('[') ||
                                      controller.result.value.startsWith('{'))
                                  ? const JsonEncoder.withIndent("    ")
                                      .convert(
                                      json.decode(utf8.decode(
                                          controller.result.value.codeUnits)),
                                    )
                                  : controller.result.value,
                              style: const TextStyle(),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                copyToClipboard(controller.result.value);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.copy, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(50),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget headersWidget(ReqHeaders element) {
    return Row(
      children: [
        if (!element.isAuth)
          Expanded(
            child: TextField(
              controller: element.keyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Clé',
              ),
            ),
          ),
        if (!element.isAuth) const Gap(10),
        Expanded(
          flex: 2,
          child: TextField(
            controller: element.valueController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: element.isAuth
                  ? "Authorization${element.isBearer ? " - Bearer" : ''}"
                  : 'Valeur',
            ),
          ),
        ),
        const Gap(10),
        TextButton(
          onPressed: () {
            controller.headers.remove(element);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size.square(50),
          ),
          child: const Icon(
            Icons.delete_forever_outlined,
            color: Colors.white,
          ),
        ),
      ],
    ).paddingSymmetric(vertical: 2).animate().slideX(begin: 1, end: 0);
  }

  Widget paramsWidget(ReqParams element) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: element.keyController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Clé',
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          flex: 2,
          child: TextField(
            controller: element.valueController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Valeur',
            ),
          ),
        ),
        const Gap(10),
        TextButton(
          onPressed: () {
            controller.params.remove(element);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size.square(50),
          ),
          child: const Icon(
            Icons.delete_forever_outlined,
            color: Colors.white,
          ),
        ),
      ],
    ).paddingSymmetric(vertical: 2).animate().slideX(begin: 1, end: 0);
  }
}

Future<void> copyToClipboard(String value) async {
  try {
    await Clipboard.setData(ClipboardData(text: value));
    message("Copié dans le presse-papier");
  } on Exception catch (e) {
    message("Erreur lors de la copie dans le presse-papier");
    print(e);
  }
}

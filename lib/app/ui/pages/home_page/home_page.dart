import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:postman_app/app/ui/theme/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../controllers/home_controller.dart';

class HomePage extends GetView {
  @override
  final HomeController controller;
  const HomePage(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
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
                  TextField(
                    controller: controller.urlController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Entrer l\'url de la requête',
                    ),
                  ),
                  const Gap(10),
                  Obx(
                    () => Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: controller.fetching.isTrue
                            ? const Color.fromARGB(255, 78, 78, 78)
                            : secondaryColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Obx(
                              () => MaterialButton(
                                onPressed: () {
                                  if (controller.fetching.isTrue) {
                                    message("Une requête est déjà en cours..");
                                    return;
                                  }

                                  controller.fetchUrl();
                                },
                                splashColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    controller.fetching.isTrue
                                        ? "..."
                                        : 'Envoyer',
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
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                              ),
                              child: DropdownMenu<String>(
                                onSelected: (s) {
                                  // controller.isUorD.value =
                                  //     controller.reqTypeController.text ==
                                  //             ReqType.update ||
                                  //         controller.reqTypeController.text ==
                                  //             ReqType.delete;
                                },
                                dropdownMenuEntries: ReqType.all
                                    .map(
                                      (e) => DropdownMenuEntry(
                                        value: e,
                                        label: e,
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                        ),
                                        leadingIcon: const SizedBox.shrink(),
                                      ),
                                    )
                                    .toList(),
                                controller: controller.reqTypeController,
                                menuStyle: MenuStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    primaryColor,
                                  ),
                                  elevation: const MaterialStatePropertyAll(0),
                                  alignment: Alignment.bottomLeft,
                                ),
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                width: 200,
                                trailingIcon: const Icon(
                                    Icons.keyboard_double_arrow_right_sharp),
                                leadingIcon: const Icon(
                                    Icons.keyboard_double_arrow_left_sharp),
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  border: InputBorder.none,
                                  suffixIconColor: Colors.white,
                                  prefixIconColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shimmer(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: controller.lockWebView.isFalse
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(30),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
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
                              color: secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    if (controller.paramsOpen.isTrue &&
                        controller.params.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
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
                      ),
                    if (controller.paramsOpen.isTrue &&
                        controller.params.isNotEmpty)
                      const Gap(10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
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
                              color: secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    if (controller.headersOpen.isTrue &&
                        controller.headers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
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
                      ),
                    const Gap(20),
                    Obx(
                      () => Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                                controller.showWebView.isFalse ? 10 : 5),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(.1),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(.0),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: controller.showWebView.isFalse
                                ? SelectableText(
                                    (controller.result.value.startsWith('[') ||
                                            controller.result.value
                                                .startsWith('{'))
                                        ? const JsonEncoder.withIndent("    ")
                                            .convert(
                                            json.decode(utf8.decode(controller
                                                .result.value.codeUnits)),
                                          )
                                        : controller.result.value,
                                    style: const TextStyle(),
                                  )
                                : ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 400,
                                    ),
                                    child: WebViewWidget(
                                        controller:
                                            controller.webViewController),
                                  ),
                          ),
                          if (controller.showWebView.isTrue)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  controller.lockWebView.value =
                                      !controller.lockWebView.value;
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
                                  child: Icon(
                                      controller.lockWebView.isFalse
                                          ? Icons.lock_open
                                          : Icons.lock_outline,
                                      size: 20),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controller.showWebView.value =
                                        !controller.showWebView.value;
                                    if (controller.showWebView.isFalse) {
                                      controller.lockWebView.value = false;
                                    }
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
                                    child: Icon(
                                        controller.showWebView.isTrue
                                            ? Icons.preview
                                            : Icons.data_array,
                                        size: 20),
                                  ),
                                ),
                                GestureDetector(
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
                              ],
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            if (!element.isAuth)
              Expanded(
                child: TextField(
                  controller: element.keyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
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
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(),
                  labelText: element.isAuth
                      ? "Authorization${element.isBearer ? " - Bearer" : ''}"
                      : 'Valeur',
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: () {
              controller.headers.remove(element);
            },
            child: const Card(
              shape: CircleBorder(),
              child: Icon(
                Icons.cancel,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    )
        .paddingSymmetric(vertical: 2)
        .animate()
        .slideX(begin: 1, end: 0, duration: 100.ms);
  }

  Widget paramsWidget(ReqParams element) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: element.keyController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  labelText: 'Clé',
                ),
              ),
            ),
            const Gap(4),
            Expanded(
              flex: 2,
              child: TextField(
                controller: element.valueController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  labelText: 'Valeur',
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: () {
              controller.params.remove(element);
            },
            child: const Card(
              shape: CircleBorder(),
              child: Icon(
                Icons.cancel,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    )
        .paddingSymmetric(vertical: 4)
        .animate()
        .slideX(begin: 1, end: 0, duration: 100.ms);
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

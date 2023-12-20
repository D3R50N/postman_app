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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          urlForm(),
          const Gap(10),
          TabBar(
            isScrollable: true,
            labelColor: secondaryColor,
            unselectedLabelColor: Colors.black,
            tabs: [
              Obx(() => Tab(
                    text: "Headers (${controller.headers.length})",
                  )),
              Obx(() => Tab(
                    text: "Queries (${controller.params.length})",
                  )),
              Obx(() => Tab(
                    text: "Body (${controller.bodies.length})",
                  )),
              const Tab(
                text: "Résultat",
              ),
            ],
            controller: controller.tabController,
          ),
          const Gap(5),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                headersTab(),
                queriesTab(),
                bodyTab(),
                resultView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container urlForm() {
    return Container(
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
                        trailingIcon:
                            const Icon(Icons.keyboard_double_arrow_right_sharp),
                        leadingIcon:
                            const Icon(Icons.keyboard_double_arrow_left_sharp),
                        inputDecorationTheme: const InputDecorationTheme(
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
    );
  }

  Obx resultView() {
    return Obx(
      () => Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(controller.showWebView.isFalse ? 10 : 5),
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
                            controller.result.value.startsWith('{'))
                        ? const JsonEncoder.withIndent("    ").convert(
                            json.decode(
                                utf8.decode(controller.result.value.codeUnits)),
                          )
                        : controller.result.value,
                    style: const TextStyle(),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 400,
                    ),
                    child:
                        WebViewWidget(controller: controller.webViewController),
                  ),
          ),
          if (controller.showWebView.isTrue)
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: () {
                  controller.lockWebView.value = !controller.lockWebView.value;
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
    );
  }

  Widget queriesTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Obx(
        () => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: controller.addParams,
                    style: TextButton.styleFrom(
                      backgroundColor: secondaryColor,
                    ),
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(
                        color: Colors.white,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(5),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: controller.params
                    .map(
                      (element) => paramsWidget(element),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding headersTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Obx(
        () => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: controller.addHeaders,
                    style: TextButton.styleFrom(
                      backgroundColor: secondaryColor,
                    ),
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(
                        color: Colors.white,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(5),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: controller.headers
                    .map(
                      (element) => headersWidget(element),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding bodyTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Obx(
        () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text("Texte clair"),
                        Switch.adaptive(
                          value: controller.isText.value,
                          onChanged: (b) {
                            controller.isText.value = b;
                            if (!b) controller.isJson.value = b;
                          },
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        const Text("JSON"),
                        Switch.adaptive(
                          value: controller.isJson.value,
                          onChanged: (b) {
                            controller.isText.value = true;
                            controller.isJson.value = b;
                            if (b) {
                              controller.bodyTextController.text =
                                  const JsonEncoder.withIndent("    ").convert(
                                json.decode(utf8.decode(controller
                                    .bodyTextController.text.codeUnits)),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: controller.urlEncoded.value &&
                          controller.isText.isFalse,
                      onChanged: controller.isText.isTrue
                          ? null
                          : (b) {
                              controller.urlEncoded.value = b!;
                            },
                    ),
                    GestureDetector(
                      onTap: () {
                        if (controller.isText.isFalse) {
                          controller.urlEncoded.toggle();
                        }
                      },
                      child: const Text("Il s'agit d'un formulaire"),
                    ),
                  ],
                ),
                const Spacer(),
                if (controller.isText.isFalse)
                  TextButton(
                    onPressed: controller.addBody,
                    child: Text(
                      "Ajouter champ",
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(5),
            if (controller.isText.isFalse)
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: controller.bodies
                      .map(
                        (element) => bodyWidget(element),
                      )
                      .toList(),
                ),
              )
            else
              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      controller: controller.bodyTextController,
                      maxLines: 30,
                      onChanged: (s) {
                        if (controller.isJson.isTrue) {
                          try {
                            controller.bodyTextController.text =
                                const JsonEncoder.withIndent("    ").convert(
                              json.decode(utf8.decode(s.codeUnits)),
                            );
                          } catch (e) {}
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Opacity(
                          opacity: .7,
                          child: pasteBtn(controller.bodyTextController)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget bodyWidget(ReqBody element) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: element.keyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    labelText: 'Champs',
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: element.valueController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: const OutlineInputBorder(),
                    labelText: 'Valeur',
                    suffixIcon: pasteBtn(element.keyController),
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
                controller.bodies.remove(element);
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
          .slideX(begin: 1, end: 0, duration: 100.ms),
    );
  }

  Widget headersWidget(ReqHeaders element) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
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
              if (!element.isAuth) const Gap(8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: element.valueController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: pasteBtn(element.keyController),
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
          .paddingSymmetric(vertical: 4)
          .animate()
          .slideX(begin: 1, end: 0, duration: 100.ms),
    );
  }

  Widget paramsWidget(ReqParams element) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
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
              const Gap(8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: element.valueController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    labelText: 'Valeur',
                    suffixIcon: pasteBtn(element.valueController),
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
          .slideX(begin: 1, end: 0, duration: 100.ms),
    );
  }

  GestureDetector pasteBtn(TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        controller.text = await pasteFromClipboard();
      },
      child: const Icon(Icons.paste_outlined),
    );
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

Future<String> pasteFromClipboard() async {
  ClipboardData? data = await Clipboard.getData("text/plain");
  return data?.text ?? "";
}

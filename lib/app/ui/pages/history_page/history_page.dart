import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postman_app/app/controllers/home_controller.dart';
import 'package:postman_app/app/controllers/main_controller.dart';
import 'package:postman_app/app/ui/theme/colors.dart';
import 'package:postman_app/main.dart';
import '../../../controllers/history_controller.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des requêtes'),
      ),
      body: Obx(
        () => SafeArea(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final element = history.reversed.elementAt(index);
              return ListTile(
                dense: true,
                onTap: () async {
                  MainController mainController = Get.find<MainController>();
                  HomeController homeController = mainController
                      .onglets[mainController.currentOnglet.value].controller;
                  homeController.reqTypeController.text = element.type;
                  homeController.urlController.text = element.url;

                  homeController.result.value = element.result;
                  await homeController.webViewController.loadHtmlString(
                    element.result,
                    baseUrl: element.url.split("?").first,
                  );
                  // homeController.setTitle();

                  homeController.headers.clear();
                  for (Map header in element.headers) {
                    ReqHeaders reqHeaders = ReqHeaders();
                    reqHeaders.keyController.text = header["key"];
                    reqHeaders.valueController.text = header["value"];
                    reqHeaders.isAuth = header["isAuth"];
                    reqHeaders.isBearer = header["isBearer"];
                    homeController.headers.add(reqHeaders);
                  }

                  homeController.params.clear();
                  for (Map param in element.params) {
                    ReqParams reqParams = ReqParams();
                    reqParams.keyController.text = param["key"];
                    reqParams.valueController.text = param["value"];
                    homeController.params.add(reqParams);
                  }
                  await Future.delayed(const Duration(milliseconds: 200));
                  Get.back();
                },
                onLongPress: () {
                  history.remove(element);
                  prefs.setString(
                    "history",
                    jsonEncode(history.map((e) => e.toJson()).toList()),
                  );
                },
                title: Text(
                  element.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: primaryColor),
                ),
                subtitle: Text(element.type),
                trailing: Text(element.date.toString().split(".")[0]),
              );
            },
          ),
        ),
      ),
    );
  }
}

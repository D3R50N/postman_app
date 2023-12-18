import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:postman_app/app/ui/utils/functions.dart';
import 'package:http/http.dart' as http;

abstract class ReqType {
  static const String get = "GET";
  static const String post = "POST";
  static const String put = "PUT";
  static const String delete = "DELETE";
  static const String update = "UPDATE";

  static List<String> all = [
    get,
    post,
    update,
    put,
    delete,
  ];
}

class HomeController extends GetxController {
  TextEditingController reqTypeController =
      TextEditingController(text: ReqType.get);

  TextEditingController urlController = TextEditingController();

  RxList<ReqParams> params = <ReqParams>[].obs;
  RxBool paramsOpen = true.obs;
  late AnimationController paramsAnimationController;

  RxList<ReqHeaders> headers = <ReqHeaders>[].obs;
  RxBool headersOpen = true.obs;
  late AnimationController headersAnimationController;

  RxBool fetching = false.obs;
  RxString result = ''.obs;

  String get realUrl {
    String url = urlController.text;
    if (!url.startsWith("https://") && !url.startsWith("http://")) {
      url = url.replaceAll("://", "");
      if (!url.startsWith("www.")) url = "www.$url";
      url = "https://$url";
    }
    return url;
  }

  Future<void> fetchUrl() async {
    String url = realUrl;
    if (!url.isURL) {
      message("URL non valide");
      return;
    }
    var type = reqTypeController.text;
    if (!ReqType.all.contains(type)) message("Méthode $type invalide");

    if (!url.endsWith("/")) url = "$url/";

    for (var param in params) {
      String paramString = "${param.key}=${param.value}";
      if (!url.endsWith("?")) url = "$url?";
      url = "$url$paramString&";
    }
    if (url.endsWith("&")) url = url.substring(0, url.length - 1);

    fetching.value = true;
    Uri uri = Uri.parse(url);
    print("Requesting $uri");
    var headers = <String, String>{};
    var body = <String, String>{};
    for (var header in this.headers) {
      if (header.isAuth) {
        if (header.isBearer) {
          headers[header.key] = "Bearer ${header.value}";
        } else {
          headers[header.key] = header.value;
        }
      } else {
        headers[header.key] = header.value;
      }
    }
    // headers["Content-Type"] = "application/json";

    for (var param in params) {
      body[param.key] = param.value;
    }

    print("Headers $headers");
    print("boddy $body");
    try {
      switch (type) {
        case ReqType.get:
          result.value = (await http.get(
            uri,
            headers: headers,
          ))
              .body;
          break;
        case ReqType.post:
          result.value = (await http.post(
            uri,
            headers: headers,
            body: body,
          ))
              .body;
          break;
        case ReqType.delete:
          result.value = (await http.delete(
            uri,
            headers: headers,
            body: body,
          ))
              .body;
          break;
        case ReqType.put:
          result.value = (await http.put(
            uri,
            headers: headers,
            body: body,
          ))
              .body;
          break;
        case ReqType.update:
          result.value = (await http.put(
            uri,
            headers: headers,
            body: body,
          ))
              .body;
          break;
        default:
          return;
      }
    } catch (e) {
      result.value = e.toString();
      print(e);
    }
    fetching.value = false;

    // message(result.value);
  }

  void addParams() {
    params.add(ReqParams());
  }

  void addHeaders() {
    RxBool isAuth = false.obs;
    RxBool isBearer = false.obs;
    Get.dialog(
      Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(Get.context!).primaryColor,
                  width: 2,
                ),
              ),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckboxListTile.adaptive(
                      value: isAuth.isTrue,
                      title: const Text("Authorization"),
                      subtitle:
                          const Text("Il s'agit d'un header d'authorisation"),
                      onChanged: (b) {
                        isAuth.value = b!;
                        if (!b) isBearer.value = false;
                      },
                    ),
                    CheckboxListTile.adaptive(
                      value: isBearer.value,
                      title: const Text("Bearer"),
                      subtitle: const Text(
                          "Il s'agit d'un header d'authorisation Bearer"),
                      onChanged: (b) {
                        isBearer.value = b!;
                        if (b) isAuth.value = true;
                      },
                    ),
                    const Gap(20),
                    MaterialButton(
                      color: Colors.black,
                      onPressed: () {
                        Get.back();
                        var header = ReqHeaders();
                        header.isAuth = isAuth.value;
                        header.isBearer = isBearer.value;

                        if (header.isAuth) {
                          header.keyController.text = "Authorization";
                        }

                        headers.add(header);
                      },
                      splashColor: Colors.blueGrey,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Ajouter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReqParams {
  TextEditingController keyController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  String get key => keyController.text;
  String get value => valueController.text;
}

class ReqHeaders {
  TextEditingController keyController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  bool isAuth = false;
  bool isBearer = false;

  String get key => keyController.text;
  String get value => valueController.text;
}

void message(String text) {
  ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

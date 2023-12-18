import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:postman_app/app/routes/route.dart';
import 'package:postman_app/app/ui/pages/main_page/main_page.dart';

import 'package:postman_app/app/ui/theme/data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postman_app/http_overrides.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/bindings/main_binding.dart';

import 'app/bindings/history_binding.dart';
import 'app/ui/pages/history_page/history_page.dart';

import 'app/bindings/welcome_binding.dart';
import 'app/ui/pages/welcome_page/welcome_page.dart';

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  Animate.restartOnHotReload = true;
  prefs = await SharedPreferences.getInstance();
  // await Future.delayed(const Duration(seconds: 1));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LePosteur',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: ThemeMode.light,
      initialRoute: Routes.welcome,
      getPages: [
        GetPage(
          name: Routes.main,
          page: () => const MainPage(),
          binding: MainBinding(),
        ),
        GetPage(
          name: Routes.welcome,
          page: () => const WelcomePage(),
          binding: WelcomeBinding(),
        ),
        GetPage(
          name: Routes.history,
          page: () => const HistoryPage(),
          binding: HistoryBinding(),
        ),
      ],
    );
  }
}

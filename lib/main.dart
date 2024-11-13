import 'package:get/get.dart';
import 'package:spirootv2/view/auth/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spirootv2/core/helper/local_storage.dart';

void main() async {
  await GetStorage.init();
  final storage = LocalStorage();
  await storage.saveAppVersion(MyText.appVersion);
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
        //Locale('de', 'DE'),
        //Locale('pt', 'PT'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: MyText.appName,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: MyColor.primaryColor,
      ),
      color: MyColor.primaryColor,
      home: const SplashScreen(),
    );
  }
}

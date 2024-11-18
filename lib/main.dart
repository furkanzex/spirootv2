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
import 'package:spirootv2/controller/astrology_controller.dart';
import 'package:spirootv2/controller/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spirootv2/data/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final userController = Get.put(UserController());
  Get.put(AstrologyController());

  final storage = LocalStorage();
  await storage.saveAppVersion(MyText.appVersion);

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    await userController.loadUser(currentUser.uid);
  } else {
    userController.resetController();
    
    final userRepository = UserRepository();
    final anonymousUser = await userRepository.createAnonymousUser();
    await userController.loadUser(anonymousUser.uid);
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
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

import 'package:get/get.dart';
import 'package:spirootv2/auth/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spirootv2/core/helper/local_storage.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spirootv2/profile/user_repository.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await EasyLocalization.ensureInitialized();

  // Sweph'i başlat
  try {
    // Önce geçici dizini al
    final tempDir = await getTemporaryDirectory();
    final ephePath = '${tempDir.path}/ephe';

    // Dizin yoksa oluştur
    final epheDir = Directory(ephePath);
    if (!await epheDir.exists()) {
      await epheDir.create(recursive: true);
    }

    // Sweph'i başlat
    await Sweph.init(
      epheAssets: [
        'packages/sweph/assets/ephe/seas_18.se1',
        'packages/sweph/assets/ephe/semo_18.se1',
        'packages/sweph/assets/ephe/sepl_18.se1',
        'packages/sweph/assets/ephe/sefstars.txt',
        'packages/sweph/assets/ephe/seleapsec.txt',
      ],
      epheFilesPath: ephePath, // Oluşturduğumuz dizini kullan
    );

    // Ephe yolunu ayarla
    Sweph.swe_set_ephe_path(ephePath);
  } catch (e) {
    print('Sweph initialization error in main: $e');
    // Hata durumunda alternatif yol dene
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final altEphePath = '${appDir.path}/ephe';

      final altEpheDir = Directory(altEphePath);
      if (!await altEpheDir.exists()) {
        await altEpheDir.create(recursive: true);
      }

      Sweph.swe_set_ephe_path(altEphePath);
    } catch (e2) {
      print('Alternative path also failed: $e2');
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Get.putAsync(() async => GeminiService());

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
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr', 'TR'),
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

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:spirootv2/auth/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';
import 'package:spirootv2/firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spirootv2/core/helper/local_storage.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';
import 'dart:io';
import 'controllers/connectivity_controller.dart';
import 'widgets/no_internet_widget.dart';

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
    // Hata durumunda alternatif yol dene
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final altEphePath = '${appDir.path}/ephe';

      final altEpheDir = Directory(altEphePath);
      if (!await altEpheDir.exists()) {
        await altEpheDir.create(recursive: true);
      }

      Sweph.swe_set_ephe_path(altEphePath);
      // ignore: empty_catches
    } catch (e2) {}
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // RevenueCat'i başlat
  await PurchaseAPI().init();

  await Get.putAsync(() async => GeminiService());

  final storage = LocalStorage();
  await storage.saveAppVersion(MyText.appVersion);

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null && currentUser.uid.isNotEmpty) {
    final userController = Get.put(UserController());
    Get.put(AstrologyController());
    await userController.loadUser(currentUser.uid);
  }

  runApp(
    Phoenix(
      child: EasyLocalization(
        supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr', 'TR'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityController = Get.put(ConnectivityController());

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
      builder: (context, child) {
        return Obx(() {
          if (!connectivityController.isConnected.value) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: MyColor.darkBackgroundColor,
                body: const NoInternetWidget(),
              ),
            );
          }
          return child!;
        });
      },
    );
  }
}

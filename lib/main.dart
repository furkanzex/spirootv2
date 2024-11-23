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
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await EasyLocalization.ensureInitialized();

  // Ephemeris dosyaları için uygulama dizinini al
  final appDir = await getApplicationDocumentsDirectory();
  final ephePath = '${appDir.path}/ephe_files';

  // Dizin yoksa oluştur
  final epheDir = Directory(ephePath);
  if (!await epheDir.exists()) {
    await epheDir.create(recursive: true);
  }

  // Ephemeris dosyalarını kopyala
  await _copyEphemerisFiles(ephePath);

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
      child: Phoenix(
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> _copyEphemerisFiles(String targetPath) async {
  try {
    final bundle = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(bundle);

    final epheFiles = manifestMap.keys
        .where((String key) => key.startsWith('assets/ephe/'))
        .toList();

    for (final file in epheFiles) {
      final filename = file.split('/').last;
      final targetFile = File('$targetPath/$filename');

      if (!await targetFile.exists()) {
        final data = await rootBundle.load(file);
        final bytes = data.buffer.asUint8List();
        await targetFile.writeAsBytes(bytes);
      }
    }
  } catch (e) {
    print('Ephemeris dosyaları kopyalanırken hata: $e');
  }
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

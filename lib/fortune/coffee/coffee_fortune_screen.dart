import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/fortune/coffee/coffee_fortune_result_screen.dart';

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({Key? key}) : super(key: key);

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen> {
  CameraController? _controller;
  Future<void> _initializeControllerFuture = Future.value();
  List<File> capturedImages = [];
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      await _initializeCamera();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('İzin Gerekli'),
          content: Text('Kahve falı için kamera ve mikrofon izni gereklidir.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Tamam'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: Text('Ayarlar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('Kamera bulunamadı');
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Kamera başlatma hatası: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null) return;
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        capturedImages.add(File(image.path));
        currentImageIndex++;
      });

      if (currentImageIndex >= 4) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CoffeeFortuneResultScreen(
              images: capturedImages,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Kahve Falı',
          style: MyStyle.s1.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller!),
                ),
                Container(
                  padding: EdgeInsets.all(MySize.defaultPadding),
                  child: Column(
                    children: [
                      Text(
                        'Fotoğraf ${currentImageIndex + 1}/4',
                        style: MyStyle.s1.copyWith(
                          color: MyColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: MySize.defaultPadding),
                      FloatingActionButton(
                        backgroundColor: MyColor.primaryColor,
                        child: Icon(Icons.camera_alt),
                        onPressed: _takePicture,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/fortune/coffee/coffee_fortune_result_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({super.key});

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen> {
  CameraController? _controller;
  Future<void> _initializeControllerFuture = Future.value();
  List<File> capturedImages = [];
  int currentImageIndex = 0;
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final mediaStatus = await Permission.mediaLibrary.status;
    final photosStatus = await Permission.photos.status;

    if (!cameraStatus.isGranted ||
        (!mediaStatus.isGranted && !photosStatus.isGranted)) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: MyColor.darkBackgroundColor,
          title: Text(
            'İzin Gerekli',
            style: TextStyle(color: MyColor.white),
          ),
          content: Text(
            'Kahve falı için kamera ve galeri izinleri gerekiyor.',
            style: TextStyle(color: MyColor.white),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _requestPermissions();
              },
              child: Text(
                'İzin Ver',
                style: TextStyle(color: MyColor.primaryColor),
              ),
            ),
          ],
        ),
      );
    } else {
      _initializeCamera();
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.mediaLibrary,
      Permission.photos,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) allGranted = false;
    });

    if (allGranted) {
      _initializeCamera();
    } else {
      Get.snackbar(
        'İzin Reddedildi',
        'Ayarlardan izinleri etkinleştirmeniz gerekiyor',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: Text(
            'AYARLAR',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('Kamera bulunamadı');
        return;
      }

      await _initCameraController(cameras[selectedCameraIndex]);
    } catch (e) {
      print('Kamera başlatma hatası: $e');
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    await _initCameraController(cameras[selectedCameraIndex]);
  }

  Future<void> _pickImage() async {
    try {
      final mediaStatus = await Permission.mediaLibrary.status;
      final photosStatus = await Permission.photos.status;

      if (!mediaStatus.isGranted && !photosStatus.isGranted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: MyColor.darkBackgroundColor,
            title: Text(
              'İzin Gerekli',
              style: TextStyle(color: MyColor.white),
            ),
            content: Text(
              'Galeri erişimi için izin gerekiyor.',
              style: TextStyle(color: MyColor.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'İPTAL',
                  style: TextStyle(color: MyColor.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'İZİN VER',
                  style: TextStyle(color: MyColor.primaryColor),
                ),
              ),
            ],
          ),
        );

        if (result == true) {
          if (await Permission.mediaLibrary.request().isGranted ||
              await Permission.photos.request().isGranted) {
            _pickImageFromGallery();
          } else {
            Get.snackbar(
              'İzin Reddedildi',
              'Ayarlardan galeri iznini etkinleştirmeniz gerekiyor',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: Text(
                  'AYARLAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        }
      } else {
        _pickImageFromGallery();
      }
    } catch (e) {
      print('Galeri hatası: $e');
      Get.snackbar(
        'Hata',
        'Galeri açılırken bir hata oluştu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && currentImageIndex < 4) {
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Kamera Önizleme
            if (_controller != null && _controller!.value.isInitialized)
              Transform.scale(
                scale: 1.0,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),

            // Üst Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Geri Butonu
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              color: MyColor.primaryPurpleColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Anasayfa',
                          style: TextStyle(
                            color: MyColor.primaryPurpleColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Çekilen Fotoğraflar
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: index == currentImageIndex
                              ? MyColor.primaryLightColor
                              : MyColor.white,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: index < capturedImages.length
                            ? Image.file(
                                capturedImages[index],
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.black.withOpacity(0.3),
                              ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Alt Bar
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Alt butonlar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo_library,
                            color: Colors.white, size: 30),
                        onPressed: _pickImage,
                      ),
                      // Çekim butonu
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: MyColor.primaryColor, width: 3),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: MyColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.flip_camera_ios,
                            color: Colors.white, size: 30),
                        onPressed: cameras.length > 1 ? _switchCamera : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

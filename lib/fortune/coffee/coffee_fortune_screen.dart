import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/fortune/coffee/coffee_fortune_result_screen.dart';

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({super.key});

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<File> capturedImages = [];
  int currentImageIndex = 0;
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  bool _isRearCameraSelected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('Kamera bulunamadı');
        return;
      }

      CameraDescription? selectedCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }

      selectedCamera ??= cameras.first;

      await _initializeCameraController(selectedCamera);
    } catch (e) {
      _showError('Kamera başlatılamadı: $e');
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showError('Kamera başlatılamadı: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    Get.snackbar(
      'Hata',
      message,
      backgroundColor: MyColor.errorColor,
      colorText: MyColor.white,
      duration: Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _takePicture() async {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      _showError('Kamera hazır değil');
      return;
    }

    if (cameraController.value.isTakingPicture) {
      return;
    }

    try {
      final XFile photo = await cameraController.takePicture();

      setState(() {
        capturedImages.add(File(photo.path));
        currentImageIndex++;
      });

      if (currentImageIndex >= 4) {
        _navigateToResult();
      }
    } catch (e) {
      _showError('Fotoğraf çekilemedi: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (photo != null && currentImageIndex < 4) {
        setState(() {
          capturedImages.add(File(photo.path));
          currentImageIndex++;
        });

        if (currentImageIndex >= 4) {
          _navigateToResult();
        }
      }
    } catch (e) {
      _showError('Fotoğraf seçilemedi: $e');
    }
  }

  void _navigateToResult() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CoffeeFortuneResultScreen(
          images: capturedImages,
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;

    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });

    final newCamera = _isRearCameraSelected
        ? cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first)
        : cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.last);

    await _initializeCameraController(newCamera);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    try {
      final newMode =
          _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      await _controller!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      _showError('Flaş değiştirilemedi');
    }
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
    ].request();

    statuses.forEach((permission, status) {
      print('$permission: $status');
    });

    bool needsPermissions = statuses.values.any(
      (status) => status.isDenied || status.isPermanentlyDenied,
    );

    if (needsPermissions) {
      await openAppSettings();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              Center(
                child: CameraPreview(_controller!),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MySize.defaultPadding,
                  vertical: MySize.halfPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.back,
                          color: MyColor.white, size: MySize.iconSizeSmall),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(
                        _flashMode == FlashMode.off
                            ? CupertinoIcons.bolt_slash_fill
                            : CupertinoIcons.bolt_fill,
                        color: MyColor.white,
                        size: MySize.iconSizeSmall,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MySize.iconSizeBig,
              left: 0,
              right: 0,
              child: Container(
                height: MySize.iconSizeBig + MySize.defaultPadding,
                padding:
                    EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: MySize.iconSizeBig,
                      height: MySize.iconSizeBig,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(MySize.quarterRadius),
                        border: Border.all(
                          color: index == currentImageIndex
                              ? MyColor.primaryColor
                              : MyColor.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(MySize.quarterRadius - 2),
                        child: index < capturedImages.length
                            ? Image.file(
                                capturedImages[index],
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: MyColor.white.withOpacity(0.1),
                                child: Icon(
                                  CupertinoIcons.camera,
                                  color: MyColor.white.withOpacity(0.3),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              bottom: MySize.defaultPadding,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleButton(
                      icon: CupertinoIcons.photo,
                      onTap: _pickImage,
                      size: MySize.iconSizeMedium,
                    ),
                    _buildCircleButton(
                      icon: CupertinoIcons.camera_fill,
                      onTap: _takePicture,
                      size: MySize.iconSizeBig,
                      isMain: true,
                    ),
                    _buildCircleButton(
                      icon: CupertinoIcons.switch_camera,
                      onTap: cameras.length > 1 ? _switchCamera : null,
                      size: MySize.iconSizeMedium,
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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onTap,
    required double size,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isMain ? MyColor.primaryColor : MyColor.white.withOpacity(0.2),
          border: isMain ? Border.all(color: MyColor.white, width: 3) : null,
        ),
        child: Icon(
          icon,
          color: MyColor.white,
          size: isMain ? size * 0.5 : size * 0.4,
        ),
      ),
    );
  }
}

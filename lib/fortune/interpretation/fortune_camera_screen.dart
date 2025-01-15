import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/fortune/interpretation/fortune_result_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

enum FortuneType { coffee, palm, face }

class FortuneCameraScreen extends StatefulWidget {
  final FortuneType fortuneType;

  const FortuneCameraScreen({
    super.key,
    required this.fortuneType,
  });

  @override
  State<FortuneCameraScreen> createState() => _FortuneCameraScreenState();
}

class _FortuneCameraScreenState extends State<FortuneCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<File> capturedImages = [];
  int currentImageIndex = 0;
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  bool _isRearCameraSelected = true;
  bool _isProcessing = false;
  bool _isCameraActive = false;

  int get requiredImageCount =>
      widget.fortuneType == FortuneType.coffee ? 4 : 1;

  String get screenTitle {
    switch (widget.fortuneType) {
      case FortuneType.coffee:
        return easy.tr('fortune.coffee_fortune');
      case FortuneType.palm:
        return easy.tr('fortune.palm_fortune');
      case FortuneType.face:
        return easy.tr('fortune.face_fortune');
    }
  }

  String get instructionText {
    switch (widget.fortuneType) {
      case FortuneType.coffee:
        return easy.tr('fortune.coffee_instruction');
      case FortuneType.palm:
        return easy.tr('fortune.palm_instruction');
      case FortuneType.face:
        return easy.tr('fortune.face_instruction');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkPermissions();
      if (mounted) {
        await _initializeCamera();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    _isCameraActive = false;
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isCameraActive) return;

    try {
      debugPrint('Kamera başlatılıyor...');
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError(easy.tr('fortune.camera_not_found'));
        return;
      }

      CameraDescription selectedCamera = cameras.firstWhere(
        (camera) => _isRearCameraSelected
            ? camera.lensDirection == CameraLensDirection.back
            : camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      if (_controller != null) {
        await _disposeCamera();
      }

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.bgra8888,
      );

      debugPrint('Kamera kontrolcüsü oluşturuldu, başlatılıyor...');
      await _controller!.initialize();
      if (!mounted) return;

      debugPrint('Kamera ayarları yapılandırılıyor...');
      await Future.wait([
        _controller!.setFocusMode(FocusMode.auto),
        _controller!.setExposureMode(ExposureMode.auto),
        _controller!.setFlashMode(_flashMode),
      ]);

      // Kameranın hazır olması için biraz daha uzun bir süre bekleyelim
      await Future.delayed(Duration(milliseconds: 1000));

      if (!mounted) return;

      _isCameraActive = true;
      setState(() {});
      debugPrint('Kamera başarıyla başlatıldı ve hazır');
    } catch (e) {
      debugPrint('Kamera başlatma hatası: $e');
      _isCameraActive = false;
      if (mounted) {
        _showError(easy.tr('fortune.camera_not_found'));
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _checkPermissions();
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    Get.snackbar(
      easy.tr('errors.error'),
      message,
      backgroundColor: MyColor.errorColor,
      colorText: MyColor.white,
      duration: Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _takePicture() async {
    if (_isProcessing) {
      debugPrint('İşlem zaten devam ediyor');
      return;
    }

    if (!_isCameraActive ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      debugPrint('Kamera hazır değil, başlatma deneniyor');
      await _initializeCamera();
      return;
    }

    try {
      debugPrint('Fotoğraf çekme işlemi başlıyor');
      setState(() => _isProcessing = true);

      // Kameranın hazır olduğundan emin olmak için son bir kontrol
      if (!_controller!.value.isInitialized) {
        throw Exception('Kamera başlatılamadı');
      }

      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setExposureMode(ExposureMode.locked);

      debugPrint('Fotoğraf çekiliyor...');
      final XFile photo = await _controller!.takePicture();
      debugPrint('Fotoğraf çekildi: ${photo.path}');

      final File imageFile = File(photo.path);
      final imageBytes = await imageFile.readAsBytes();

      if (imageBytes.length < 1000) {
        throw Exception(easy.tr('fortune.image_quality_low'));
      }

      setState(() {
        capturedImages.add(imageFile);
        currentImageIndex++;
      });

      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);

      if (currentImageIndex >= requiredImageCount) {
        _navigateToResult();
      }
    } catch (e) {
      debugPrint('Fotoğraf çekme hatası: $e');
      _showError(easy.tr('fortune.image_not_taken'));
      // Hata durumunda kamerayı yeniden başlatmayı deneyelim
      _isCameraActive = false;
      await _initializeCamera();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      // Galeriye geçmeden önce kamerayı kapat
      if (_isCameraActive) {
        await _disposeCamera();
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (photo != null) {
        final File imageFile = File(photo.path);
        final imageBytes = await imageFile.readAsBytes();

        if (imageBytes.length < 1000) {
          throw Exception(easy.tr('fortune.image_quality_low'));
        }

        setState(() {
          capturedImages.add(imageFile);
          currentImageIndex++;
        });

        if (currentImageIndex >= requiredImageCount) {
          _navigateToResult();
        }
      }
    } catch (e) {
      _showError(easy.tr('fortune.image_not_selected'));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _navigateToResult() {
    Get.off(() => FortuneResultScreen(
          images: capturedImages,
          fortuneType: widget.fortuneType,
        ));
  }

  Future<void> _switchCamera() async {
    try {
      if (cameras.length < 2) return;

      await _disposeCamera();

      setState(() {
        _isRearCameraSelected = !_isRearCameraSelected;
      });

      await _initializeCamera();
    } catch (e) {
      _showError(easy.tr('fortune.camera_not_changed'));
    }
  }

  Future<void> _checkPermissions() async {
    try {
      debugPrint('İzinler kontrol ediliyor...');
      Map<Permission, PermissionStatus> statuses = {};

      if (Platform.isAndroid) {
        if (int.parse(Platform.operatingSystemVersion.split('.').first) >= 33) {
          statuses = await [
            Permission.camera,
            Permission.photos,
          ].request();
        } else {
          statuses = await [
            Permission.camera,
            Permission.storage,
          ].request();
        }
      } else {
        statuses = await [
          Permission.camera,
          Permission.photos,
        ].request();
      }

      bool allGranted = true;
      statuses.forEach((permission, status) {
        debugPrint(
            'İzin durumu - ${permission.toString()}: ${status.toString()}');
        if (!status.isGranted) {
          allGranted = false;
        }
      });

      if (!allGranted) {
        debugPrint('Bazı izinler reddedildi, dialog gösteriliyor...');
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }

      debugPrint('Tüm izinler verildi');
    } catch (e) {
      debugPrint('İzin kontrolü hatası: $e');
      // Hata mesajını burada göstermeyelim, sadece loglayalım
    }
  }

  void _showPermissionDialog() {
    Get.defaultDialog(
      title: easy.tr('permissions.title'),
      titleStyle: MyStyle.s1.copyWith(color: MyColor.white),
      backgroundColor: MyColor.darkBackgroundColor,
      content: Text(
        easy.tr('permissions.camera_required'),
        style: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
      ),
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: Text(
            easy.tr('permissions.understood'),
            style: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
          ),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await openAppSettings();
            Get.back();
          },
          child: Text(
            easy.tr('permissions.open_settings'),
            style: MyStyle.s2.copyWith(color: MyColor.primaryColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(MyIcon.back,
                color: MyColor.white, size: MySize.iconSizeSmall),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            screenTitle,
            style: MyStyle.b4.copyWith(color: MyColor.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Kamera önizlemesini koşullu olarak göster
              if (_controller != null &&
                  _controller!.value.isInitialized &&
                  _isCameraActive &&
                  mounted)
                Center(
                  child: CameraPreview(_controller!),
                )
              else
                Center(
                  child: CircularProgressIndicator(
                    color: MyColor.primaryColor,
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.halfPadding,
                        vertical: MySize.halfPadding,
                      ),
                      decoration: BoxDecoration(
                        color: MyColor.white.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(MySize.quarterRadius),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.fortuneType == FortuneType.coffee
                                ? easy.tr('fortune.coffee_count', namedArgs: {
                                    'count': requiredImageCount.toString()
                                  })
                                : widget.fortuneType == FortuneType.face
                                    ? easy.tr('fortune.face_instruction')
                                    : easy.tr('fortune.palm_instruction'),
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          widget.fortuneType == FortuneType.coffee
                              ? verticalGap(MySize.halfPadding)
                              : SizedBox.shrink(),
                          widget.fortuneType == FortuneType.coffee
                              ? Text(
                                  '$currentImageIndex/$requiredImageCount ${easy.tr('fortune.image_count')}',
                                  style: MyStyle.s3
                                      .copyWith(color: MyColor.textGreyColor),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                    Container(
                      height: MySize.iconSizeBig + MySize.defaultPadding,
                      padding: EdgeInsets.symmetric(
                          horizontal: MySize.defaultPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(requiredImageCount, (index) {
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
                              borderRadius: BorderRadius.circular(
                                  MySize.quarterRadius - 2),
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
                  ],
                ),
              ),

              Positioned(
                bottom: MySize.defaultPadding,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
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
                      if (cameras.length > 1)
                        _buildCircleButton(
                          icon: CupertinoIcons.switch_camera,
                          onTap: _switchCamera,
                          size: MySize.iconSizeMedium,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

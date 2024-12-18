import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/helper/device_helper.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/core/widget/popup/premium_popup.dart';

class DreamInterpretationScreen extends StatefulWidget {
  const DreamInterpretationScreen({super.key});

  @override
  State<DreamInterpretationScreen> createState() =>
      _DreamInterpretationScreenState();
}

class _DreamInterpretationScreenState extends State<DreamInterpretationScreen> {
  final TextEditingController _dreamController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  String? _interpretation;
  final AstrologyController _astrologyController =
      Get.find<AstrologyController>();

  Future<void> _interpretDream() async {
    if (!_astrologyController.isSubscribed.value) {
      Get.dialog(
        PremiumPopup(
          onSingleUse: () async {
            if (_dreamController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(easy.tr('fortune.please_fill_dream_field'))),
              );
              return;
            }
            await _processInterpretation();
          },
        ),
      );
      return;
    }

    if (_dreamController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(easy.tr('fortune.please_fill_dream_field'))),
      );
      return;
    }

    await _processInterpretation();
  }

  Future<void> _processInterpretation() async {
    setState(() {
      _isLoading = true;
      _interpretation = null;
    });

    try {
      final interpretation =
          await _geminiService.interpretDream(_dreamController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('fortunes')
          .add({
        'dream': _dreamController.text,
        'interpretation': interpretation,
        'type': "dream",
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _interpretation = interpretation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(easy.tr('errors.error')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: DeviceHelper.hideKeyboard,
      child: ScaffoldGradientBackground(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            MyColor.darkBackgroundColor,
            MyColor.primaryColor,
          ],
        ),
        appBar: AppBar(
          backgroundColor: MyColor.transparent,
          title: Text(
            easy.tr('fortune.dream_interpretation'),
            style: MyStyle.b4.copyWith(color: MyColor.white),
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: MyColor.white),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(MySize.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _dreamController,
                    maxLines: 6,
                    style: const TextStyle(
                      color: MyColor.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: easy.tr('fortune.please_fill_dream_detailed'),
                      hintStyle: TextStyle(
                        color: MyColor.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: MyColor.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MyColor.primaryLightColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MyColor.primaryLightColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MySize.defaultPadding),
              if (_interpretation == null)
                ElevatedButton(
                  onPressed: _isLoading ? null : _interpretDream,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryLightColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    surfaceTintColor: MyColor.transparent,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: MyColor.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          easy.tr('fortune.interpret_dream'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MyColor.white,
                          ),
                        ),
                ),
              if (_interpretation != null) ...[
                const SizedBox(height: MySize.defaultPadding * 2),
                Container(
                  padding: const EdgeInsets.all(MySize.defaultPadding),
                  decoration: BoxDecoration(
                    color: MyColor.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: MyColor.primaryLightColor.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.primaryLightColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            easy.tr('fortune.here_is_your_interpretation'),
                            style: MyStyle.s1.copyWith(
                              color: MyColor.primaryPurpleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Share.share(
                                '${easy.tr("fortune.shared_from_spiroot")}\n\n$_interpretation',
                                subject:
                                    easy.tr('fortune.dream_interpretation'),
                              );
                            },
                            icon: const Icon(
                              MingCute.upload_line,
                              color: MyColor.primaryPurpleColor,
                            ),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(
                              minWidth: MySize.iconSizeSmall,
                              minHeight: MySize.iconSizeSmall,
                            ),
                            tooltip: easy.tr('fortune.share'),
                          ),
                        ],
                      ),
                      const SizedBox(height: MySize.defaultPadding),
                      Text(
                        _interpretation!,
                        style: const TextStyle(
                          color: MyColor.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

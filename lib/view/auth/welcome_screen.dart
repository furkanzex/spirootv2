import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/widget/button/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_image.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/controller/auth_controller.dart';
import 'package:spirootv2/core/helper/device_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomeScreen extends StatefulWidget {
  final AuthController controller = AuthController();
  WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DeviceHelper.hideKeyboard(),
      child: Scaffold(
        backgroundColor: MyColor.darkBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: MySize.appBarHeight),
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: SvgPicture.asset(MyImage.welcomeImage),
                  ),
                ),
                const Spacer(),
                Text(
                  MyText.appName,
                  style: MyStyle.b1.copyWith(color: MyColor.textWhiteColor),
                ),
                Text(
                  "signin.title".tr(),
                  style: MyStyle.s1.copyWith(
                      color: MyColor.textWhiteColor,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: MySize.doublePadding,
                ),
                Row(
                  children: [
                    Expanded(
                      child: customElevatedButton(
                        onPressed: () {
                          widget.controller.signInAnonymously();
                        },
                        titleStyle: MyStyle.buttonBig
                            .copyWith(color: MyColor.primaryDarkColor),
                        bgPrimaryColor: MyColor.textWhiteColor,
                        frontColor: MyColor.primaryDarkColor,
                        title: "signin.button_label".tr(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: MySize.doublePadding,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: MySize.doublePadding),
                  child: SizedBox(
                    width: MySize.iconSizeMedium,
                    child: Image.asset(MyImage.logoImage),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

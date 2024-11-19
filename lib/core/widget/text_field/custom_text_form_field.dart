import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    required this.line,
    required this.labelText,
    required this.controller,
    super.key,
  });

  final int line;
  final String labelText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: MyColor.primaryColor,
      maxLines: line,
      style: MyStyle.s3.copyWith(color: MyColor.textWhiteColor),
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: MyColor.whiteShadowColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          borderSide: const BorderSide(
            width: 1.0,
            color: MyColor.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          borderSide: const BorderSide(
            width: 2.0,
            color: MyColor.primaryColor,
          ),
        ),
        labelText: labelText,
        labelStyle: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/widget/section/shops_section.dart';

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shopsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

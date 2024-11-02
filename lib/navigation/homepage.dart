import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/core/constant/my_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MyColor.lightBackgroundColor,
      body: Center(
        child: Icon(MingCute.bird_fill),
      ),
    );
  }
}

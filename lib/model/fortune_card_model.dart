import 'package:flutter/material.dart';

class FortuneCard {
  final String image;
  final String title;
  final Color? color;
  final VoidCallback? onTap;

  FortuneCard({
    required this.image,
    required this.title,
    this.color,
    this.onTap,
  });
}

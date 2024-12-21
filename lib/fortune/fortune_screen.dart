import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/fortune/fortune_history_section.dart';
import 'package:spirootv2/home/section/fortune_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spirootv2/profile/user_controller.dart';

class FortuneScreen extends StatelessWidget {
  const FortuneScreen({super.key});

  Future<void> _refreshFortune() async {
    final userController = Get.find<UserController>();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await userController.loadUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshFortune,
          backgroundColor: MyColor.darkBackgroundColor,
          color: MyColor.primaryPurpleColor,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('fortunes')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final hasFortunes =
                  snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(MySize.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!hasFortunes) ...[
                        fortuneSection(context: context),
                      ] else
                        fortuneHistorySection(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';

Widget fortuneHistorySection(BuildContext context) {
  String formatDate(DateTime? date) {
    if (date == null) return 'Tarih bilgisi yok'.tr();
    return DateFormat('dd MMMM yyyy, HH:mm').format(date);
  }

  return StreamBuilder<QuerySnapshot>(
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

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Text(
            'Henüz fal geçmişiniz bulunmuyor'.tr(),
            style: const TextStyle(color: MyColor.white),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(
            text: "🔮 ${easy.tr("fortune.fortune_history")}",
          ),
          verticalGap(MySize.defaultPadding),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final fortune = snapshot.data!.docs[index];
              final data = fortune.data() as Map<String, dynamic>;

              DateTime? date;
              if (data['timestamp'] != null) {
                date = (data['timestamp'] as Timestamp).toDate();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: MySize.defaultPadding),
                child: GestureDetector(
                  onTap: () => _showFortuneDetail(
                      context,
                      FortuneHistoryItem(
                        image:
                            'https://apptoic.com/spiroot/images/${data['type']}.png',
                        type: data['type'],
                        date: formatDate(date),
                        content: data['interpretation'],
                      )),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                      child: Container(
                        padding: const EdgeInsets.all(MySize.defaultPadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MySize.iconSizeMedium,
                              height: MySize.iconSizeMedium,
                              decoration: BoxDecoration(
                                color: MyColor.primaryColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(MySize.quarterRadius),
                              ),
                              child: ExtendedImage.network(
                                'https://apptoic.com/spiroot/images/${data['type']}.png',
                                cache: true,
                                fit: BoxFit.contain,
                                width: MySize.iconSizeSmall,
                                height: MySize.iconSizeSmall,
                              ),
                            ),
                            horizontalGap(MySize.threeQuartersPadding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        easy.tr("fortune.${data['type']}"),
                                        style: MyStyle.s2.copyWith(
                                          color: MyColor.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            formatDate(date),
                                            style: MyStyle.s3.copyWith(
                                              color: MyColor.textGreyColor,
                                            ),
                                          ),
                                          horizontalGap(MySize.halfPadding),
                                          GestureDetector(
                                            onTap: () async {
                                              bool? confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  backgroundColor: MyColor
                                                      .darkBackgroundColor,
                                                  title: Text(
                                                    'Yorumu Sil',
                                                    style: MyStyle.s1.copyWith(
                                                        color: MyColor.white),
                                                  ),
                                                  content: Text(
                                                    'Bu yorumu silmek istediğinizden emin misiniz?',
                                                    style: MyStyle.s2.copyWith(
                                                        color: MyColor.white),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child: Text(
                                                        'İptal',
                                                        style: MyStyle.s2.copyWith(
                                                            color: MyColor
                                                                .primaryLightColor),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: Text(
                                                        'Sil',
                                                        style: MyStyle.s2
                                                            .copyWith(
                                                                color:
                                                                    Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser?.uid)
                                                    .collection('fortunes')
                                                    .doc(fortune.id)
                                                    .delete();
                                              }
                                            },
                                            child: Icon(
                                              MingCute.delete_2_line,
                                              color: MyColor.primaryPurpleColor,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  horizontalGap(MySize.halfPadding),
                                  Text(
                                    data['interpretation'],
                                    style: MyStyle.s3.copyWith(
                                      color: MyColor.textGreyColor,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

void _showFortuneDetail(BuildContext context, FortuneHistoryItem item) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: MyColor.darkBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(MySize.halfRadius),
          ),
        ),
        child: Column(
          children: [
            // Kapat çubuğu
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
            ),
            // Başlık ve tarih
            Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MySize.iconSizeMedium,
                        height: MySize.iconSizeMedium,
                        child: ExtendedImage.network(
                          item.image,
                          cache: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        easy.tr("fortune.${item.type}"),
                        style: MyStyle.s1.copyWith(
                          color: MyColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.date,
                    style: MyStyle.s3.copyWith(
                      color: MyColor.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: MyColor.white.withOpacity(0.1),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(MySize.defaultPadding),
                child: Text(
                  item.content,
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                ),
              ),
            ),
            verticalGap(MySize.doublePadding),
          ],
        ),
      ),
    ),
  );
}

class FortuneHistoryItem {
  final String type;
  final String image;
  final String content;
  final String date;

  FortuneHistoryItem({
    required this.type,
    required this.image,
    required this.content,
    required this.date,
  });
}

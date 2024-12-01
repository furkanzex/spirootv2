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

String getInterpretationText(Map<String, dynamic> data) {
  if (data['type'] == 'tarot') {
    final interpretation = data['interpretation'] as Map<String, dynamic>;
    return '${interpretation['past']}\n\n${interpretation['present']}\n\n${interpretation['future']}';
  }
  if (data['interpretation'] is Map<String, dynamic>) {
    final interpretation = data['interpretation'] as Map<String, dynamic>;
    return interpretation.values.join('\n\n');
  }
  return data['interpretation']?.toString() ?? '';
}

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

              final content = data['type'] == 'tarot'
                  ? (data['interpretation'] as Map<String, dynamic>?)
                  : data['interpretation'];

              DateTime? revealAt;
              if (data['revealAt'] != null) {
                revealAt = (data['revealAt'] as Timestamp).toDate();
              }

              final historyItem = FortuneHistoryItem(
                image: 'https://apptoic.com/spiroot/images/${data['type']}.png',
                type: data['type'],
                date: formatDate(date),
                content: content,
                revealAt: revealAt,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: MySize.defaultPadding),
                child: GestureDetector(
                  onTap: () => _showFortuneDetail(context, historyItem),
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
                                  _buildInterpretationText(data),
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
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: MyColor.darkBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(MySize.halfRadius),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Row(
                children: [
                  Container(
                    width: MySize.iconSizeMedium,
                    height: MySize.iconSizeMedium,
                    padding: const EdgeInsets.all(MySize.quarterPadding),
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MySize.quarterRadius),
                    ),
                    child: ExtendedImage.network(
                      item.image,
                      cache: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  horizontalGap(MySize.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          easy.tr("fortune.${item.type}"),
                          style: MyStyle.s1.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MySize.defaultPadding),
                child: _buildDetailContent(item),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class FortuneHistoryItem {
  final String image;
  final String type;
  final String date;
  final dynamic content;
  final DateTime? revealAt;

  FortuneHistoryItem({
    required this.image,
    required this.type,
    required this.date,
    required this.content,
    this.revealAt,
  });
}

Widget _buildInterpretationText(Map<String, dynamic> data) {
  final revealAt = data['revealAt'] != null
      ? (data['revealAt'] as Timestamp).toDate()
      : null;

  if (revealAt != null && DateTime.now().isBefore(revealAt)) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              MingCute.time_line,
              color: MyColor.primaryPurpleColor,
              size: 16,
            ),
            horizontalGap(4),
            Text(
              'Falınız Bakılıyor',
              style: MyStyle.s3.copyWith(
                color: MyColor.primaryPurpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        verticalGap(4),
        Text(
          'Kalan Süre: ${_formatDuration(revealAt.difference(DateTime.now()))}',
          style: MyStyle.s3.copyWith(
            color: MyColor.textGreyColor,
          ),
        ),
      ],
    );
  }

  final interpretation = data['interpretation'];
  if (interpretation == null) return const SizedBox();

  // Eğer yorum bir Map ise
  if (interpretation is Map<String, dynamic>) {
    return Text(
      '${interpretation['past'] ?? ''}\n${interpretation['present'] ?? ''}\n${interpretation['future'] ?? ''}',
      style: MyStyle.s3.copyWith(
        color: MyColor.textGreyColor,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Eğer yorum bir String ise
  if (interpretation is String) {
    return Text(
      interpretation,
      style: MyStyle.s3.copyWith(
        color: MyColor.textGreyColor,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  return const SizedBox();
}

String _formatDuration(Duration duration) {
  if (duration.inHours > 0) {
    return '${duration.inHours} saat ${duration.inMinutes.remainder(60)} dakika';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes} dakika';
  } else {
    return '${duration.inSeconds} saniye';
  }
}

Widget _buildDetailContent(FortuneHistoryItem item) {
  if (item.revealAt != null && DateTime.now().isBefore(item.revealAt!)) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: MyColor.primaryPurpleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
          ),
          child: Column(
            children: [
              const Icon(
                MingCute.time_line,
                color: MyColor.primaryPurpleColor,
                size: 48,
              ),
              verticalGap(MySize.defaultPadding),
              Text(
                'Falınız Hazırlanıyor',
                style: MyStyle.s1.copyWith(
                  color: MyColor.primaryPurpleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalGap(MySize.halfPadding),
              Text(
                'Kalan Süre: ${_formatDuration(item.revealAt!.difference(DateTime.now()))}',
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                ),
                textAlign: TextAlign.center,
              ),
              verticalGap(MySize.defaultPadding),
              Text(
                'Falınız ${DateFormat('HH:mm').format(item.revealAt!)} saatinde hazır olacak',
                style: MyStyle.s3.copyWith(
                  color: MyColor.textGreyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Eğer içerik bir Map ise
  if (item.content is Map<String, dynamic>) {
    final interpretations = item.content as Map<String, dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInterpretationSection('Geçmiş', interpretations['past'] ?? ''),
        verticalGap(MySize.defaultPadding),
        _buildInterpretationSection('Şimdi', interpretations['present'] ?? ''),
        verticalGap(MySize.defaultPadding),
        _buildInterpretationSection('Gelecek', interpretations['future'] ?? ''),
      ],
    );
  }

  // Eğer içerik bir String ise
  if (item.content is String) {
    return Text(
      item.content as String,
      style: MyStyle.s2.copyWith(color: MyColor.white),
    );
  }

  return const SizedBox();
}

Widget _buildInterpretationSection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: MyStyle.s1.copyWith(
          color: MyColor.primaryPurpleColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      verticalGap(MySize.halfPadding),
      Text(
        content,
        style: MyStyle.s2.copyWith(color: MyColor.white),
      ),
    ],
  );
}

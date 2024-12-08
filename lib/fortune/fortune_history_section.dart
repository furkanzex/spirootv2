import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: MySize.iconSizeMedium,
                        height: MySize.iconSizeMedium,
                        padding: const EdgeInsets.all(MySize.quarterPadding),
                        decoration: BoxDecoration(
                          color: MyColor.primaryColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(MySize.quarterRadius),
                        ),
                        child: ExtendedImage.network(
                          item.image,
                          cache: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      horizontalGap(MySize.defaultPadding),
                      Column(
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
                    ],
                  ),
                  IconButton(
                    onPressed: () => _shareFortune(context, item),
                    icon: Icon(
                      MingCute.share_2_line,
                      color: MyColor.primaryPurpleColor,
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

void _shareFortune(BuildContext context, FortuneHistoryItem item) async {
  try {
    String shareText = '';
    final content = item.content as Map<String, dynamic>;

    switch (item.type) {
      case 'coffee':
        shareText = '''
    🔮 Kahve Falı
    📅 ${item.date}

    ${content['general']}

    ⏰ Kehanet:
    📅 Kısa Vade (1-3 ay): ${content['timing']['short_term']}
    📅 Orta Vade (3-6 ay): ${content['timing']['mid_term']}
    📅 Uzun Vade (6+ ay): ${content['timing']['long_term']}

    🎯 Görülen Semboller:
    ${(content['symbols'] as List).map((symbol) => '''
    • ${symbol['name']}
      ${symbol['meaning']}
      ${symbol['quote']}
    ''').join('\n')}

    Spiroot ile falına baktır! 🔮✨
    ''';
        break;

      case 'tarot':
        shareText = '''
    🎴 Tarot Falı
    📅 ${item.date}

    ⏳ Geçmiş:
    ${content['past']}

    📍 Şimdi:
    ${content['present']}

    🔮 Gelecek:
    ${content['future']}

    Spiroot ile falına baktır! 🔮✨
    ''';
        break;

      case 'katina':
        shareText = '''
    💝 Katina Aşk Falı
    📅 ${item.date}

    ⏳ Geçmiş:
    ${content['past']}

    📍 Şimdi:
    ${content['present']}

    🔮 Gelecek:
    ${content['future']}

    Spiroot ile falına baktır! 🔮✨
    ''';
        break;

      case 'angel':
        shareText = '''
    👼 Melek Kartı
    📅 ${item.date}

    ⏳ Geçmiş:
    ${content['past']}

    📍 Şimdi:
    ${content['present']}

    🔮 Gelecek:
    ${content['future']}

    Spiroot ile falına baktır! 🔮✨
    ''';
        break;

      case 'palm':
        shareText = '''
    🖐️ El Falı
    📅 ${item.date}

    📝 Genel Analiz:
    ${content['general']}

    📍 El Çizgileri:
    ${(content['lines'] as List).map((line) => '''
    • ${line['name']}
      ${line['analysis']}
      Öngörü: ${line['prediction']}
    ''').join('\n')}

    ✨ Özel İşaretler:
    ${(content['special_markings'] as List).map((marking) => '''
    • ${marking['name']}
      ${marking['meaning']}
      Konum: ${marking['location']}
    ''').join('\n')}

    ⏰ Öngörüler:
    📅 Kısa Vade (1-3 ay): ${content['timing']['short_term']}
    📅 Orta Vade (3-6 ay): ${content['timing']['mid_term']}
    📅 Uzun Vade (6+ ay): ${content['timing']['long_term']}

    Spiroot ile falına baktır! 🔮✨
    ''';
        break;

      case 'face':
        shareText = '''
    👤 Yüz Falı
    📅 ${item.date}

    📝 Genel Analiz:
    ${content['general']}

    📍 Yüz Özellikleri:
    ${(content['features'] as List).map((feature) => '''
    • ${feature['name']}
      ${feature['analysis']}
      İşaret ettiği özellikler: ${feature['indication']}
    ''').join('\n')}

    🌟 Yaşam Yolu:
    • Karakter: ${content['life_path']['character']}
    • Potansiyel: ${content['life_path']['potential']}
    • Zorluklar: ${content['life_path']['challenges']}
    • Öneriler: ${content['life_path']['advice']}

    ⏰ Öngörüler:
    📅 Kısa Vade (1-3 ay): ${content['predictions']['short_term']}
    📅 Orta Vade (3-6 ay): ${content['predictions']['mid_term']}
    📅 Uzun Vade (6+ ay): ${content['predictions']['long_term']}

    Spiroot ile falına baktır! 🔮✨
    ''';
        break;

      default:
        shareText = '''
    🔮 ${easy.tr("fortune.${item.type}")}
    📅 ${item.date}

    ${content['general'] ?? content['interpretation'] ?? 'Fal yorumu bulunamadı.'}

    Spiroot ile falına baktır! 🔮✨
    ''';
    }

    await Share.share(
      shareText,
      subject: '${easy.tr("fortune.${item.type}")} - Spiroot',
    );
  } catch (e) {
    print('Paylaşım hatası: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paylaşım sırasında bir hata oluştu: ${e.toString()}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
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

  switch (data['type']) {
    case 'coffee':
      final content = interpretation as Map<String, dynamic>;
      return Text(
        content['general'] ?? '',
        style: MyStyle.s3.copyWith(
          color: MyColor.textGreyColor,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );

    case 'palm':
      final content = interpretation as Map<String, dynamic>;
      return Text(
        content['general'] ?? '',
        style: MyStyle.s3.copyWith(
          color: MyColor.textGreyColor,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );

    case 'face':
      final content = interpretation as Map<String, dynamic>;
      return Text(
        content['general'] ?? '',
        style: MyStyle.s3.copyWith(
          color: MyColor.textGreyColor,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );

    case 'angel':
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
      break;

    default:
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

  final content = item.content as Map<String, dynamic>;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(MySize.defaultPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genel Yorum
        _buildFortuneSection(
          '🔮 Genel Yorum',
          content['general'] ?? '',
        ),
        verticalGap(MySize.doublePadding),

        if (item.type == 'coffee') ...[
          // Kahve Falı - Semboller Bölümü
          if ((content['symbols'] as List?)?.isNotEmpty ?? false) ...[
            Text(
              '🎯 Görülen Semboller',
              style: MyStyle.s1.copyWith(
                color: MyColor.primaryPurpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.defaultPadding),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (content['symbols'] as List).length,
              itemBuilder: (context, index) {
                final symbol = content['symbols'][index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColor.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(MySize.halfRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol['name'] ?? '',
                        style: MyStyle.s2.copyWith(
                          color: MyColor.primaryPurpleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      verticalGap(8),
                      Text(
                        'Anlamı: ${symbol['meaning'] ?? ''}',
                        style: MyStyle.s3.copyWith(color: MyColor.white),
                      ),
                      verticalGap(4),
                      Text(
                        'Konum: ${symbol['location'] ?? ''}',
                        style: MyStyle.s3.copyWith(color: MyColor.white),
                      ),
                      if (symbol['quote'] != null) ...[
                        verticalGap(8),
                        Text(
                          symbol['quote'],
                          style: MyStyle.s3.copyWith(
                            color: MyColor.textGreyColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ] else if (item.type == 'palm') ...[
          // El Falı - Çizgiler Bölümü
          if ((content['lines'] as List?)?.isNotEmpty ?? false) ...[
            Text(
              '✋ El Çizgileri',
              style: MyStyle.s1.copyWith(
                color: MyColor.primaryPurpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.defaultPadding),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (content['lines'] as List).length,
              itemBuilder: (context, index) {
                final line = content['lines'][index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColor.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(MySize.halfRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line['name'] ?? '',
                        style: MyStyle.s2.copyWith(
                          color: MyColor.primaryPurpleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      verticalGap(8),
                      Text(
                        'Analiz: ${line['analysis'] ?? ''}',
                        style: MyStyle.s3.copyWith(color: MyColor.white),
                      ),
                      verticalGap(8),
                      Text(
                        'Öngörü: ${line['prediction'] ?? ''}',
                        style:
                            MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ] else if (item.type == 'face') ...[
          // Yüz Falı - Özellikler Bölümü
          if ((content['features'] as List?)?.isNotEmpty ?? false) ...[
            Text(
              '👤 Yüz Özellikleri',
              style: MyStyle.s1.copyWith(
                color: MyColor.primaryPurpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.defaultPadding),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (content['features'] as List).length,
              itemBuilder: (context, index) {
                final feature = content['features'][index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColor.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(MySize.halfRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['name'] ?? '',
                        style: MyStyle.s2.copyWith(
                          color: MyColor.primaryPurpleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      verticalGap(8),
                      Text(
                        'Analiz: ${feature['analysis'] ?? ''}',
                        style: MyStyle.s3.copyWith(color: MyColor.white),
                      ),
                      verticalGap(8),
                      Text(
                        'İşaret: ${feature['indication'] ?? ''}',
                        style:
                            MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],

        verticalGap(MySize.doublePadding),

        // Zamanlama/Öngörüler Bölümü
        Text(
          '⏰ ${item.type == 'face' ? 'Öngörüler' : 'Kehanet'}',
          style: MyStyle.s1.copyWith(
            color: MyColor.primaryPurpleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        verticalGap(MySize.defaultPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimingSection(
                'Kısa Vadede (1-3 ay):',
                content['timing']?['short_term'] ??
                    content['predictions']?['short_term'] ??
                    ''),
            verticalGap(12),
            _buildTimingSection(
                'Orta Vadede (3-6 ay):',
                content['timing']?['mid_term'] ??
                    content['predictions']?['mid_term'] ??
                    ''),
            verticalGap(12),
            _buildTimingSection(
                'Uzun Vadede (6+ ay):',
                content['timing']?['long_term'] ??
                    content['predictions']?['long_term'] ??
                    ''),
          ],
        ),

        // Yüz Falı için Ek Yaşam Yolu Bölümü
        if (item.type == 'face' && content['life_path'] != null) ...[
          verticalGap(MySize.doublePadding),
          Text(
            '🛣️ Yaşam Yolu',
            style: MyStyle.s1.copyWith(
              color: MyColor.primaryPurpleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalGap(MySize.defaultPadding),
          _buildFortuneSection(
              'Karakter:', content['life_path']['character'] ?? ''),
          verticalGap(8),
          _buildFortuneSection(
              'Potansiyel:', content['life_path']['potential'] ?? ''),
          verticalGap(8),
          _buildFortuneSection(
              'Zorluklar:', content['life_path']['challenges'] ?? ''),
          verticalGap(8),
          _buildFortuneSection(
              'Öneriler:', content['life_path']['advice'] ?? ''),
        ],
      ],
    ),
  );
}

Widget _buildFortuneSection(String title, String content) {
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

Widget _buildTimingSection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: MyStyle.s2.copyWith(
          color: MyColor.primaryLightColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      verticalGap(4),
      Text(
        content,
        style: MyStyle.s3.copyWith(color: MyColor.white),
      ),
    ],
  );
}

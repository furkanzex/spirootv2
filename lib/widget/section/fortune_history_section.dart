import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:extended_image/extended_image.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/widget/text_field/section_title.dart';

class FortuneHistoryItem {
  final String type;
  final String image;
  final String content;
  final DateTime date;

  FortuneHistoryItem({
    required this.type,
    required this.image,
    required this.content,
    required this.date,
  });
}

Widget fortuneHistorySection(BuildContext context) {
  final List<FortuneHistoryItem> historyItems = [
    FortuneHistoryItem(
      type: "Kahve Falı",
      image: "https://apptoic.com/spiroot/images/coffee.png",
      content:
          """Fincanında gördüğüm şekiller yakın zamanda güzel bir haber alacağını gösteriyor. İş hayatında yükselişe geçeceğin bir dönem seni bekliyor. Uzun zamandır beklediğin fırsat kapını çalacak.

Fincanının sağ tarafında beliren yol işareti, yakın zamanda bir seyahate çıkacağını gösteriyor. Bu seyahat hem iş hem de özel hayatın için önemli gelişmelere vesile olacak.

Fincanının dibinde görünen şekiller, maddi açıdan rahat bir döneme gireceğini işaret ediyor. Beklemediğin bir yerden para gelebilir.

Telvenin üst kısmında oluşan kalp şekli, duygusal hayatında güzel gelişmeler yaşanacağının habercisi. Bekarsan yeni bir aşk, evliysen eşinle olan ilişkinde taze bir heyecan seni bekliyor.

Genel olarak fincanın çok olumlu mesajlar veriyor. Önündeki dönem, uzun zamandır beklediğin fırsatların gerçekleşeceği bir dönem olacak.""",
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FortuneHistoryItem(
      type: "Tarot Falı",
      image: "https://apptoic.com/spiroot/images/tarot.png",
      content:
          "Çıkan kartlar önündeki engellerin kalkacağını gösteriyor. Aşk hayatında yeni bir başlangıç yapabilirsin. Maddi konularda rahatlamaya başlayacaksın.",
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FortuneHistoryItem(
      type: "El Falı",
      image: "https://apptoic.com/spiroot/images/palm.png",
      content:
          "El çizgilerin uzun bir ömür süreceğini gösteriyor. Kariyerinde önemli başarılar elde edeceksin. Yakın gelecekte seyahat görünüyor.",
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle(
        text: "🔮 ${easy.tr("fortune.fortune_history")}",
      ),
      verticalGap(MySize.defaultPadding),
      ...historyItems
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: MySize.defaultPadding),
                child: GestureDetector(
                  onTap: () => _showFortuneDetail(context, item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(MySize.defaultPadding),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fal ikonu - 44x44pt minimum touch target
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: MyColor.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      MySize.quarterRadius),
                                ),
                                child: ExtendedImage.network(
                                  item.image,
                                  cache: true,
                                  fit: BoxFit.contain,
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // İçerik kısmı
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Fal türü ve tarih yan yana
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.type,
                                          style: MyStyle.s2.copyWith(
                                            color: MyColor.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(item.date),
                                          style: MyStyle.s3.copyWith(
                                            color: MyColor.textGreyColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Fal içeriği
                                    Text(
                                      item.content,
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
                ),
              ))
          .toList(),
    ],
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
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(8),
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
                      const SizedBox(width: 12),
                      Text(
                        item.type,
                        style: MyStyle.s1.copyWith(
                          color: MyColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(item.date),
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

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inHours < 24) {
    if (difference.inHours < 1) {
      return "${difference.inMinutes} dakika önce";
    }
    return "${difference.inHours} saat önce";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} gün önce";
  } else {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}

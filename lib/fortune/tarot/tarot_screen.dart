import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/fortune/tarot/tarot_card_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/services.dart';
import 'dart:convert';

class TarotScreen extends StatefulWidget {
  final String fortuneType; // 'tarot', 'katina', 'angel'
  final String title;
  final String cardBackImage;

  const TarotScreen({
    super.key,
    required this.fortuneType,
    required this.title,
    required this.cardBackImage,
  });

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen>
    with TickerProviderStateMixin {
  List<TarotCard>? _deck;
  final List<TarotCard?> _selectedCards = List.filled(3, null);
  late AnimationController _fanAnimationController;
  bool _isInterpreting = false;
  Timer? _interpretationTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTarotCards();
    _fanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  Future<void> _loadTarotCards() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/tarot.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _deck = jsonList
            .map((json) => TarotCard.fromJson(json as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
      _fanAnimationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(easy.tr('fortune.failed_to_load_tarot_cards')),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fanAnimationController.dispose();
    _interpretationTimer?.cancel();
    super.dispose();
  }

  Future<void> _interpretCards() async {
    if (_selectedCards.any((card) => card == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(easy.tr('fortune.please_select_3_cards')),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isInterpreting = true;
    });

    // Kartları sırayla aç
    for (var i = 0; i < _selectedCards.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _selectedCards[i]?.isRevealed = true;
      });
    }

    final random = Random();
    final waitTime = Duration(minutes: random.nextInt(14) + 1);

    try {
      final geminiService = GeminiService();
      Map<String, dynamic> interpretation;

      switch (widget.fortuneType) {
        case 'tarot':
          interpretation = await geminiService.interpretTarotCards(
              _selectedCards.whereType<TarotCard>().toList());
          break;
        case 'katina':
          interpretation = await geminiService.interpretKatinaCards(
              _selectedCards.whereType<TarotCard>().toList());
          break;
        case 'angel':
          interpretation = await geminiService.interpretAngelCards(
              _selectedCards.whereType<TarotCard>().toList());
          break;
        default:
          throw Exception(easy.tr('fortune.invalid_fortune_type'));
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('fortunes')
          .add({
        'type': widget.fortuneType,
        'cards': _selectedCards.map((card) => card!.name).toList(),
        'interpretation': interpretation,
        'timestamp': FieldValue.serverTimestamp(),
        'revealAt': Timestamp.fromDate(DateTime.now().add(waitTime)),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              easy.tr('fortune.fortune_will_be_ready_in',
                  namedArgs: {'minutes': waitTime.inMinutes.toString()}),
            ),
            backgroundColor: MyColor.primaryLightColor.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(easy.tr('errors.error')),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInterpreting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _deck == null) {
      return ScaffoldGradientBackground(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            MyColor.darkBackgroundColor,
            MyColor.primaryColor,
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: MyColor.primaryLightColor,
                  strokeWidth: 3,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              Text(
                easy.tr("astrology.loading"),
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final cardWidth = MySize.tarotCardWidth;
    final cardHeight = MySize.tarotCardHeight;

    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          MyColor.darkBackgroundColor,
          MyColor.primaryColor,
        ],
      ),
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        title: Text(
          widget.title,
          style: MyStyle.b4.copyWith(color: MyColor.white),
        ),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(MyIcon.back,
              color: MyColor.white, size: MySize.iconSizeSmall),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MyColor.transparent,
              MyColor.primaryLightColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: MySize.defaultPadding),
            Text(
              easy.tr('fortune.select_3_cards_for_past_present_future'),
              style: TextStyle(
                color: MyColor.white.withOpacity(0.9),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(MySize.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    final labels = [
                      easy.tr('past'),
                      easy.tr('present'),
                      easy.tr('future')
                    ];
                    return Column(
                      children: [
                        Text(
                          labels[index],
                          style: TextStyle(
                            color: MyColor.primaryPurpleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        verticalGap(MySize.defaultPadding),
                        Stack(
                          children: [
                            Container(
                              width: cardWidth / 1.5,
                              height: cardHeight / 1.5,
                            ),
                            Positioned.fill(
                              child: DragTarget<TarotCard>(
                                onWillAccept: (card) {
                                  if (card == null ||
                                      _selectedCards[index] != null ||
                                      card.isSelected) {
                                    return false;
                                  }
                                  return true;
                                },
                                onAccept: (card) {
                                  setState(() {
                                    card.isSelected = true;
                                    _selectedCards[index] = card;
                                  });
                                },
                                onMove: (details) {
                                  setState(() {});
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Container(
                                    width: cardWidth / 1.5,
                                    height: cardHeight / 1.5,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: candidateData.isNotEmpty
                                            ? MyColor.primaryLightColor
                                            : MyColor.primaryPurpleColor,
                                        width: candidateData.isNotEmpty ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          MySize.quarterRadius),
                                      color: candidateData.isNotEmpty
                                          ? MyColor.primaryLightColor
                                              .withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                    child: _selectedCards[index] != null
                                        ? _buildCard(_selectedCards[index]!,
                                            width: cardWidth,
                                            height: cardHeight)
                                        : Center(
                                            child: Icon(
                                              MingCute.add_circle_line,
                                              color: MyColor.primaryPurpleColor
                                                  .withOpacity(0.5),
                                              size: MySize.iconSizeSmall,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        verticalGap(MySize.halfPadding),
                        if (_selectedCards[index]?.isRevealed == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            _selectedCards[index]!.name,
                            textAlign: TextAlign.center,
                            style: MyStyle.s3.copyWith(
                              color:
                                  MyColor.primaryPurpleColor.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ),
            ),
            if (_selectedCards.any((card) => card == null))
              Expanded(
                flex: 3,
                child: _buildTarotFan(),
              ),
            if (_selectedCards.every((card) => card != null))
              Padding(
                padding: const EdgeInsets.all(MySize.doublePadding),
                child: ElevatedButton(
                  onPressed: _isInterpreting ? null : _interpretCards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryLightColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isInterpreting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: MyColor.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          easy.tr('fortune.interpret_cards'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MyColor.white,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    TarotCard card, {
    required double width,
    required double height,
  }) {
    // Her kart için benzersiz bir tag oluştur
    final heroTag =
        '${card.number}_${card.name}_${DateTime.now().microsecondsSinceEpoch}';

    return Hero(
      tag: heroTag,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MySize.quarterRadius),
          image: DecorationImage(
            image: card.isRevealed
                ? AssetImage(card.image)
                : AssetImage(widget.cardBackImage),
            fit: card.isRevealed ? BoxFit.contain : BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTarotFan() {
    if (_isLoading || _deck == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = MySize.tarotCardWidth;
    final cardHeight = MySize.tarotCardHeight;
    final centerX = screenWidth / 2;
    final centerY = MediaQuery.of(context).size.height * 0.6;
    final radius = screenWidth * 0.8;
    const totalCards = 20; // Sabit 20 kart
    final arcAngle = pi / 2.5; // Yelpaze açısı

    return Stack(
      children: List.generate(totalCards, (index) {
        final progress = index / (totalCards - 1);
        final angle = -arcAngle / 2 + arcAngle * progress;

        // Kartın pozisyonunu hesapla
        final x = centerX + radius * cos(angle - pi / 2);
        final y = centerY + radius * sin(angle - pi / 2);

        final rotationAngle = angle;

        // _deck dizisini döngüsel olarak kullan
        final cardIndex = index % _deck!.length;

        return Positioned(
          left: x - cardWidth / 2,
          top: y - cardHeight / 1,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Draggable<TarotCard>(
              data: _deck![cardIndex],
              feedback: Transform.translate(
                offset: Offset(-cardWidth / 2, -cardHeight / 7),
                child: Material(
                  color: Colors.transparent,
                  child: _buildCard(_deck![cardIndex],
                      width: cardWidth, height: cardHeight),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.2,
                child: _buildCard(_deck![cardIndex],
                    width: cardWidth, height: cardHeight),
              ),
              child: _buildCard(_deck![cardIndex],
                  width: cardWidth, height: cardHeight),
            ),
          ),
        );
      }),
    );
  }
}

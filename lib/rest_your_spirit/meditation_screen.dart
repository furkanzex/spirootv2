import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:confetti/confetti.dart';
import 'package:just_audio/just_audio.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late AnimationController _breathingController;
  String? _selectedFeeling;
  bool _isPlaying = false;
  bool _isMeditating = false;
  bool _isLoading = false;
  double _currentProgress = 0.0;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _relaxationStep = 0;
  int? _selectedDuration;

  final List<String> _relaxationSteps = [
    'Gözlerinizi kapatın ve derin bir nefes alın...',
    'Omuzlarınızı gevşetin ve rahatlayın...',
    'Zihninizi boşaltın ve anın tadını çıkarın...',
  ];

  final List<Map<String, dynamic>> _feelings = [
    {
      'name': 'Stress',
      'icon': '🌊',
      'color': Color(0xFF7B8FF7),
      'sound': 'https://apptoic.com/spiroot/sounds/1.mp3',
    },
    {
      'name': 'Gratitude',
      'icon': '🌟',
      'color': Color(0xFF9D7BF7),
      'sound': 'https://apptoic.com/spiroot/sounds/2.mp3',
    },
    {
      'name': 'Anxiety',
      'icon': '🌀',
      'color': Color(0xFF7B8FF7),
      'sound': 'https://apptoic.com/spiroot/sounds/3.mp3',
    },
    {
      'name': 'Sadness',
      'icon': '💧',
      'color': Color(0xFF9D7BF7),
      'sound': 'https://apptoic.com/spiroot/sounds/4.mp3',
    },
    {
      'name': 'Happiness',
      'icon': '✨',
      'color': Color(0xFF7B8FF7),
      'sound': 'https://apptoic.com/spiroot/sounds/5.mp3',
    },
    {
      'name': 'Anger',
      'icon': '🔥',
      'color': Color(0xFF9D7BF7),
      'sound': 'https://apptoic.com/spiroot/sounds/6.mp3',
    },
  ];

  final List<Map<String, dynamic>> _durations = [
    {'minutes': 5, 'text': '5 min'},
    {'minutes': 10, 'text': '10 min'},
    {'minutes': 15, 'text': '15 min'},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _confettiController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  Future<void> _startMeditation() async {
    if (_selectedDuration == null || _selectedFeeling == null) return;

    setState(() {
      _isLoading = true;
      _relaxationStep = 0;
    });

    // Rahatlama adımları için timer
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_relaxationStep < _relaxationSteps.length - 1) {
        setState(() {
          _relaxationStep++;
        });
      } else {
        timer.cancel();
      }
    });

    // Ses dosyasını yükle ve başlat
    try {
      final selectedSound =
          _feelings.firstWhere((f) => f['name'] == _selectedFeeling)['sound'];
      await _audioPlayer.setUrl(selectedSound);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();

      setState(() {
        _isLoading = false;
        _isMeditating = true;
        _isPlaying = true;
        _remainingSeconds = _selectedDuration! * 60;
        _currentProgress = 0.0;
      });

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            _currentProgress =
                1 - (_remainingSeconds / (_selectedDuration! * 60));
          } else {
            _completeMeditation();
          }
        });
      });
    } catch (e) {
      print('Audio error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _completeMeditation() {
    _timer?.cancel();
    _audioPlayer.stop();
    _confettiController.play();

    setState(() {
      _isMeditating = false;
      _isPlaying = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (_isMeditating) {
      return false;
    }
    return true;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildFeelingsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                children: [
                  Text(
                    'Nasıl hissediyorsun? ( Bu bilgi, daha etkili bir meditasyon egzersizi seçmek için gerekli. )',
                    style: MyStyle.s2.copyWith(color: MyColor.whiteTintColor),
                  ),
                  SizedBox(height: MySize.defaultPadding),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: MySize.defaultPadding,
                      mainAxisSpacing: MySize.defaultPadding,
                    ),
                    itemCount: _feelings.length,
                    itemBuilder: (context, index) {
                      final feeling = _feelings[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFeeling = feeling['name'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: feeling['color'],
                            borderRadius:
                                BorderRadius.circular(MySize.quarterRadius),
                            border: _selectedFeeling == feeling['name']
                                ? Border.all(color: MyColor.white, width: 2)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Text(
                                  feeling['icon'],
                                  style: TextStyle(fontSize: 60),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(MySize.defaultPadding),
                                child: Text(
                                  feeling['name'],
                                  style: MyStyle.s1.copyWith(
                                    color: MyColor.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: MySize.doublePadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ne kadar zaman ayırabilirsin? ( Bu bilgi, ne kadar uzunlukta bir meditasyon egzersizi yapacağınızı belirlemek için gerekli. )',
                        style:
                            MyStyle.s2.copyWith(color: MyColor.whiteTintColor),
                      ),
                      SizedBox(height: MySize.defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _durations.map((duration) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDuration = duration['minutes'];
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: MySize.defaultPadding * 2,
                                vertical: MySize.defaultPadding,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedDuration == duration['minutes']
                                    ? MyColor.primaryLightColor
                                    : MyColor.primaryLightColor
                                        .withOpacity(0.3),
                                borderRadius:
                                    BorderRadius.circular(MySize.halfRadius),
                              ),
                              child: Text(
                                duration['text'],
                                style:
                                    MyStyle.s2.copyWith(color: MyColor.white),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: MySize.doublePadding),
                      if (_selectedFeeling != null && _selectedDuration != null)
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _showSoundsList(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColor.primaryLightColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: MySize.doublePadding,
                                vertical: MySize.defaultPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(MySize.halfRadius),
                              ),
                            ),
                            child: Text(
                              'Start Meditation',
                              style: MyStyle.s1.copyWith(color: MyColor.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSoundsList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: MyColor.darkBackgroundColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(MySize.defaultRadius)),
        ),
        child: _buildPlayerScreen(),
      ),
    );
  }

  Widget _buildPlayerScreen() {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2A1CB0),
                  MyColor.darkBackgroundColor,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white.withOpacity(0.1)],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcOver,
              child: Opacity(
                opacity: 0.5,
                child: SvgPicture.asset(
                  'assets/svg/stars.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: !_isMeditating,
                leading: !_isMeditating
                    ? IconButton(
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: MyColor.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(MySize.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading) ...[
                        Text(
                          _relaxationSteps[_relaxationStep],
                          style: MyStyle.b3.copyWith(color: MyColor.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: MySize.defaultPadding),
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(MyColor.white),
                        ),
                      ] else if (_isMeditating) ...[
                        Text(
                          _formatTime(_remainingSeconds),
                          style: MyStyle.b1.copyWith(color: MyColor.white),
                        ),
                        SizedBox(height: MySize.defaultPadding),
                        Text(
                          'Take a deep breath...',
                          style: MyStyle.s2
                              .copyWith(color: MyColor.whiteTintColor),
                        ),
                        SizedBox(height: MySize.doublePadding),
                        LinearProgressIndicator(
                          value: _currentProgress,
                          backgroundColor:
                              MyColor.primaryColor.withOpacity(0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(MyColor.white),
                        ),
                        SizedBox(height: MySize.doublePadding),
                        ElevatedButton(
                          onPressed: _completeMeditation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.errorColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.doublePadding,
                              vertical: MySize.defaultPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(MySize.halfRadius),
                            ),
                          ),
                          child: Text(
                            'Meditasyonu Bitir',
                            style: MyStyle.s1.copyWith(color: MyColor.white),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Ready to begin your meditation?',
                          style: MyStyle.b3.copyWith(color: MyColor.white),
                        ),
                        SizedBox(height: MySize.doublePadding),
                        ElevatedButton(
                          onPressed: _startMeditation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.doublePadding,
                              vertical: MySize.defaultPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(MySize.halfRadius),
                            ),
                          ),
                          child: Text(
                            'Begin $_selectedDuration Minutes Meditation',
                            style: MyStyle.s1.copyWith(color: MyColor.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        surfaceTintColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(easy.tr("Meditasyon Egzersizi"),
            style: MyStyle.s1.copyWith(color: MyColor.white)),
      ),
      body: SafeArea(
        child: _buildFeelingsGrid(),
      ),
    );
  }
}

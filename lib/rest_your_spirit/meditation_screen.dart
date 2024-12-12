import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:confetti/confetti.dart';
import 'package:just_audio/just_audio.dart';
import 'package:animate_do/animate_do.dart';

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
  Timer? _timer;
  int? _selectedDuration;

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

  final List<String> _relaxationSteps = [
    'Gözlerinizi kapatın ve derin bir nefes alın...',
    'Omuzlarınızı gevşetin ve rahatlayın...',
    'Zihninizi boşaltın ve anın tadını çıkarın...',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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

  void _navigateToMeditationPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _MeditationPage(
          feeling: _selectedFeeling!,
          duration: _selectedDuration!,
          onComplete: () {
            Navigator.of(context).pop();
          },
          feelings: _feelings,
          relaxationSteps: _relaxationSteps,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
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
                            onPressed: () => _navigateToMeditationPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        elevation: 0,
        surfaceTintColor: MyColor.transparent,
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

class _MeditationPage extends StatefulWidget {
  final List<Map<String, dynamic>> feelings;
  final List<String> relaxationSteps;
  final String feeling;
  final int duration;
  final VoidCallback onComplete;

  const _MeditationPage({
    required this.feeling,
    required this.duration,
    required this.onComplete,
    required this.feelings,
    required this.relaxationSteps,
  });

  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<_MeditationPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _breathingController;
  // ignore: unused_field
  bool _isPlaying = false;
  // ignore: unused_field
  bool _isMeditating = false;
  bool _isPreparingMeditation = true;
  double _currentProgress = 0.0;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _relaxationStep = 0;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _remainingSeconds = widget.duration * 60;
    _startPreparation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  Future<void> _startPreparation() async {
    try {
      // Ses dosyasını yükle
      final selectedSound = widget.feelings
          .firstWhere((f) => f['name'] == widget.feeling)['sound'];
      await _audioPlayer.setUrl(selectedSound);
      await _audioPlayer.setLoopMode(LoopMode.one);

      // Rahatlama adımları
      _relaxationStep = 0;
      _startRelaxationSteps();
    } catch (e) {
      print('Preparation error: $e');
    }
  }

  void _startRelaxationSteps() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_relaxationStep < widget.relaxationSteps.length - 1) {
          _relaxationStep++;
        } else {
          timer.cancel();
          _beginMeditation();
        }
      });
    });
  }

  void _beginMeditation() {
    if (!mounted) return;

    setState(() {
      _isPreparingMeditation = false;
      _isMeditating = true;
      _isPlaying = true;
      _currentProgress = 0.0;
      _remainingSeconds = widget.duration * 60;
    });

    _audioPlayer.play();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _currentProgress = 1.0 - (_remainingSeconds / (widget.duration * 60));
        } else {
          _endMeditation();
        }
      });
    });
  }

  void _endMeditation() {
    _timer?.cancel();
    _audioPlayer.stop();

    setState(() {
      _isPlaying = false;
      _isMeditating = false;
      _currentProgress = 1.0;
      _remainingSeconds = 0;
    });

    widget.onComplete();
  }

  String _formatTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: MyColor.darkBackgroundColor,
        body: Stack(
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
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(MySize.defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isPreparingMeditation) ...[
                      Stack(alignment: Alignment.center, children: [
                        FadeInDown(
                          duration: Duration(milliseconds: 500),
                          child: Text(
                            widget.relaxationSteps[_relaxationStep],
                            style: MyStyle.b3.copyWith(color: MyColor.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Opacity(
                          opacity: 0.5,
                          child: Lottie.asset(
                            'assets/lottie/affirmation_bg.json',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ])
                    ] else ...[
                      FadeIn(
                        child: Column(
                          children: [
                            Text(
                              _formatTime(),
                              style: MyStyle.b1.copyWith(
                                color: MyColor.white,
                                fontSize: 72,
                              ),
                            ),
                            SizedBox(height: MySize.defaultPadding),
                            AnimatedBuilder(
                              animation: _breathingController,
                              builder: (context, child) {
                                return Text(
                                  _breathingController.value < 0.5
                                      ? 'Nefes Al'
                                      : 'Nefes Ver',
                                  style: MyStyle.s1.copyWith(
                                    color: MyColor.whiteTintColor,
                                    fontSize: 24,
                                  ),
                                );
                              },
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _endMeditation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColor.primaryLightColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: MySize.doublePadding,
                                      vertical: MySize.defaultPadding,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          MySize.halfRadius),
                                    ),
                                  ),
                                  child: Text(
                                    'Meditasyonu Bitir',
                                    style: MyStyle.s2
                                        .copyWith(color: MyColor.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

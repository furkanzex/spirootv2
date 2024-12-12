import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
  String? _selectedSound;
  int? _selectedDuration;
  bool _isPlaying = false;
  bool _isMeditating = false;
  double _currentProgress = 0.0;
  Timer? _timer;
  int _remainingSeconds = 0;

  final List<Map<String, dynamic>> _feelings = [
    {
      'name': 'Stress',
      'icon': '🌊',
      'color': Color(0xFF7B8FF7),
    },
    {
      'name': 'Gratitude',
      'icon': '🌟',
      'color': Color(0xFF9D7BF7),
    },
    {
      'name': 'Anxiety',
      'icon': '🌀',
      'color': Color(0xFF7B8FF7),
    },
    {
      'name': 'Sadness',
      'icon': '💧',
      'color': Color(0xFF9D7BF7),
    },
    {
      'name': 'Happiness',
      'icon': '✨',
      'color': Color(0xFF7B8FF7),
    },
    {
      'name': 'Anger',
      'icon': '🔥',
      'color': Color(0xFF9D7BF7),
    },
  ];

  final List<Map<String, dynamic>> _durations = [
    {'minutes': 3, 'text': '3 min'},
    {'minutes': 5, 'text': '5 min'},
    {'minutes': 7, 'text': '7 min'},
  ];

  final List<Map<String, dynamic>> _sounds = [
    {
      'name': 'Calm Summer Night',
      'subtitle': 'The Sounds of Nature',
      'duration': '58:24',
      'url': 'https://apptoic.com/spiroot/sounds/1.mp3',
    },
    {
      'name': 'Peaceful Rain',
      'subtitle': 'The Sounds of Nature',
      'duration': '45:30',
      'url': 'https://apptoic.com/spiroot/sounds/2.mp3',
    },
    {
      'name': 'Ocean Waves',
      'subtitle': 'The Sounds of Nature',
      'duration': '52:15',
      'url': 'https://apptoic.com/spiroot/sounds/3.mp3',
    },
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

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _startMeditation() {
    if (_selectedDuration == null) return;

    setState(() {
      _isMeditating = true;
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

    _togglePlay();
  }

  void _completeMeditation() {
    _timer?.cancel();
    _togglePlay();
    _confettiController.play();

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isMeditating = false;
        Navigator.pop(context);
      });
    });
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
    return Stack(
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
              leading: !_isMeditating
                  ? IconButton(
                      icon:
                          Icon(Icons.keyboard_arrow_down, color: MyColor.white),
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
                    if (_isMeditating) ...[
                      Text(
                        _formatTime(_remainingSeconds),
                        style: MyStyle.b1.copyWith(color: MyColor.white),
                      ),
                      SizedBox(height: MySize.defaultPadding),
                      Text(
                        'Take a deep breath...',
                        style:
                            MyStyle.s2.copyWith(color: MyColor.whiteTintColor),
                      ),
                    ] else ...[
                      Text(
                        'Calm Summer Night',
                        style: MyStyle.b3.copyWith(color: MyColor.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'The Sounds of Nature',
                        style:
                            MyStyle.s2.copyWith(color: MyColor.whiteTintColor),
                      ),
                    ],
                    SizedBox(height: MySize.doublePadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isMeditating) ...[
                          IconButton(
                            icon: Icon(Icons.favorite_border,
                                color: MyColor.white),
                            onPressed: () {},
                          ),
                          SizedBox(width: MySize.defaultPadding),
                        ],
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColor.white,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 32,
                              color: MyColor.primaryColor,
                            ),
                            onPressed: _isMeditating ? null : _togglePlay,
                          ),
                        ),
                        if (!_isMeditating) ...[
                          SizedBox(width: MySize.defaultPadding),
                          IconButton(
                            icon: Icon(Icons.share, color: MyColor.white),
                            onPressed: () {},
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: MySize.defaultPadding),
                    if (!_isMeditating) ...[
                      Slider(
                        value: _currentProgress,
                        onChanged: (value) {
                          setState(() {
                            _currentProgress = value;
                          });
                        },
                        activeColor: MyColor.white,
                        inactiveColor: MyColor.whiteTintColor,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: MySize.defaultPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '37:18',
                              style: MyStyle.s3
                                  .copyWith(color: MyColor.whiteTintColor),
                            ),
                            Text(
                              '58:24',
                              style: MyStyle.s3
                                  .copyWith(color: MyColor.whiteTintColor),
                            ),
                          ],
                        ),
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
                    ] else ...[
                      LinearProgressIndicator(
                        value: _currentProgress,
                        backgroundColor: MyColor.primaryColor.withOpacity(0.3),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(MyColor.white),
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

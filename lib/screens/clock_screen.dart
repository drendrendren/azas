import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:azas/dogu/media_query.dart';
import 'package:azas/dogu/palette.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late String _timeString;
  Color backgroundColor = Palette.primary;
  Color textColor = Palette.textPrimary;
  String fontFamily = 'VT323';
  double fontSize = 50;
  bool showSettings = false;
  bool is24HourFormat = true; // 24시간제 기본
  bool showSeconds = true; // 초 표시 여부

  final fontMap = {
    // 💡 디지털 / 테크 스타일
    'VT323': GoogleFonts.vt323, // 올드 CRT 모니터 감성
    'Orbitron': GoogleFonts.orbitron, // 디지털 시계 느낌
    'Share Tech Mono': GoogleFonts.shareTechMono, // 전자시계 감성
    // 🧩 기본형 (깔끔하고 가독성 좋은 폰트)
    'Roboto Mono': GoogleFonts.robotoMono, // 정갈하고 모노스페이스
    'Open Sans': GoogleFonts.openSans, // 현대적이고 균형잡힘
    'Noto Sans': GoogleFonts.notoSans, // 다국어 지원 훌륭함
    // 🎨 특이하거나 개성 있는 폰트
    'Press Start 2P': GoogleFonts.pressStart2p, // 레트로 픽셀 시계 느낌
    'Audiowide': GoogleFonts.audiowide, // SF, 미래적 스타일
    'Bebas Neue': GoogleFonts.bebasNeue, // 심플 + 대문자 전용 느낌 좋음
    'Russo One': GoogleFonts.russoOne, // 로봇/테크 느낌 강함
  };

  @override
  void initState() {
    super.initState();
    loadSettings();
    _timeString = _formatTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    final now = DateTime.now();
    setState(() {
      _timeString = _formatTime(now);
    });
  }

  String _formatTime(DateTime time) {
    final hour =
        is24HourFormat
            ? time.hour
            : (time.hour % 12 == 0 ? 12 : time.hour % 12);
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');

    return showSeconds ? "$hour:$minute:$second" : "$hour:$minute";
  }

  void _toggleSettings() {
    setState(() {
      showSettings = !showSettings;
    });
  }

  // setting value 불러오는 함수
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      is24HourFormat = prefs.getBool('is24HourFormat') ?? true;
      showSeconds = prefs.getBool('showSeconds') ?? true;
      fontFamily = prefs.getString('fontFamily') ?? 'VT323';
      backgroundColor = Color(
        prefs.getInt('backgroundColor') ?? Palette.primary.value,
      );
      textColor = Color(prefs.getInt('textColor') ?? Palette.textPrimary.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 시계 화면
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleSettings,
            child: Center(
              child: SizedBox(
                width: MediaQueryDogu.width(context) * 0.9,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _timeString,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: fontMap[fontFamily]!(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 설정 레이어
          if (showSettings)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 7),
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _toggleSettings,
                        child: const Text(
                          'X',
                          style: TextStyle(
                            color: Palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: MediaQueryDogu.width(context) * 0.9,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/time.svg',
                                          width: 23,
                                          height: 23,
                                          color: const Color(0xFFE3E3E3),
                                        ),
                                        const SizedBox(width: 3),
                                        const Text(
                                          'Utils',
                                          style: TextStyle(
                                            color: Palette.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // util link button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 130,
                                          child: ElevatedButton(
                                            onPressed:
                                                () => context.go('/clock'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.15),
                                              foregroundColor: Colors.white
                                                  .withOpacity(0.9),
                                              shadowColor: Colors.black
                                                  .withOpacity(0.2),
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withOpacity(0.25),
                                                  width: 1.2,
                                                ),
                                              ),
                                            ),
                                            child: const Text(
                                              'Clock',
                                              style: TextStyle(
                                                color: Palette.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        SizedBox(
                                          width: 130,
                                          child: ElevatedButton(
                                            onPressed:
                                                () => context.go('/timer'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.15),
                                              foregroundColor: Colors.white
                                                  .withOpacity(0.9),
                                              shadowColor: Colors.black
                                                  .withOpacity(0.2),
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withOpacity(0.25),
                                                  width: 1.2,
                                                ),
                                              ),
                                            ),
                                            child: const Text(
                                              'Timer',
                                              style: TextStyle(
                                                color: Palette.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 25),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/settings.svg',
                                          width: 23,
                                          height: 23,
                                          color: const Color(0xFFE3E3E3),
                                        ),
                                        const SizedBox(width: 3),
                                        const Text(
                                          'Settings',
                                          style: TextStyle(
                                            color: Palette.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // 12/24시간제 토글
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      '24 Hour',
                                                      style: TextStyle(
                                                        color:
                                                            Palette.textPrimary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Transform.scale(
                                                      scale: 0.65,
                                                      child: CupertinoSwitch(
                                                        value: is24HourFormat,
                                                        onChanged: (val) async {
                                                          setState(() {
                                                            is24HourFormat =
                                                                val;
                                                          });
                                                          final prefs =
                                                              await SharedPreferences.getInstance();
                                                          await prefs.setBool(
                                                            'is24HourFormat',
                                                            is24HourFormat,
                                                          );
                                                        },
                                                        activeColor:
                                                            Palette
                                                                .buttonSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // 초 숨기기 체크박스
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Checkbox(
                                                      value: showSeconds,
                                                      onChanged: (val) async {
                                                        setState(() {
                                                          showSeconds =
                                                              val ?? true;
                                                        });
                                                        final prefs =
                                                            await SharedPreferences.getInstance();
                                                        await prefs.setBool(
                                                          'showSeconds',
                                                          showSeconds,
                                                        );
                                                      },
                                                      activeColor:
                                                          Palette
                                                              .buttonSecondary,
                                                    ),
                                                    const Text(
                                                      'Show Seconds',
                                                      style: TextStyle(
                                                        color:
                                                            Palette.textPrimary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // 배경색 설정
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final color =
                                                        await _showColorPicker(
                                                          backgroundColor,
                                                        );
                                                    if (color != null) {
                                                      setState(() {
                                                        backgroundColor = color;
                                                      });
                                                      final prefs =
                                                          await SharedPreferences.getInstance();
                                                      await prefs.setInt(
                                                        'backgroundColor',
                                                        backgroundColor.value,
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.5),
                                                    foregroundColor: Colors
                                                        .white
                                                        .withOpacity(0.9),
                                                    shadowColor: Colors.black
                                                        .withOpacity(0.2),
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      side: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.25),
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Background Color',
                                                    style: TextStyle(
                                                      color:
                                                          Palette.textTertiary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                // 글자색 설정
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final color =
                                                        await _showColorPicker(
                                                          textColor,
                                                        );
                                                    if (color != null) {
                                                      setState(() {
                                                        textColor = color;
                                                      });
                                                      final prefs =
                                                          await SharedPreferences.getInstance();
                                                      await prefs.setInt(
                                                        'textColor',
                                                        textColor.value,
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.5),
                                                    foregroundColor: Colors
                                                        .white
                                                        .withOpacity(0.9),
                                                    shadowColor: Colors.black
                                                        .withOpacity(0.2),
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      side: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.25),
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Text Color',
                                                    style: TextStyle(
                                                      color:
                                                          Palette.textTertiary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 폰트 설정
                                            DropdownButton<String>(
                                              dropdownColor: Colors.grey[900],
                                              value: fontFamily,
                                              style: const TextStyle(
                                                color: Palette.textPrimary,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                              items:
                                                  fontMap.keys.map((font) {
                                                    return DropdownMenuItem(
                                                      value: font,
                                                      child: Text(
                                                        font,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: fontMap[font]!(
                                                          color:
                                                              Palette
                                                                  .textPrimary,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (val) async {
                                                if (val != null) {
                                                  setState(
                                                    () => fontFamily = val,
                                                  );
                                                  final prefs =
                                                      await SharedPreferences.getInstance();
                                                  await prefs.setString(
                                                    'fontFamily',
                                                    fontFamily,
                                                  );
                                                }
                                              },
                                            ),
                                            // font size setting
                                            const Text(
                                              'Font Size',
                                              style: TextStyle(
                                                color: Palette.textPrimary,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Slider(
                                              value: fontSize,
                                              min: 20,
                                              max: 400,
                                              activeColor:
                                                  Palette.sliderActivePrimary,
                                              inactiveColor:
                                                  Palette.sliderInactivePrimary,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  fontSize = newValue;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<Color?> _showColorPicker(Color initialColor) async {
    Color tempColor = initialColor;
    return showDialog<Color>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Select Color',
            style: TextStyle(
              color: Palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Palette.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempColor),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Palette.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

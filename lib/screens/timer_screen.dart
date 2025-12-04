import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:azas/dogu/media_query.dart';
import 'package:azas/dogu/palette.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? timer;

  int totalSeconds = 45 * 60; // 기본 45분

  bool isRunning = false; // 타이머 실행 중
  bool isPaused = false; // 일시정지 상태

  final TextEditingController minuteController = TextEditingController();
  final TextEditingController secondController = TextEditingController();

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (totalSeconds > 0) {
        setState(() => totalSeconds--);
      } else {
        timer?.cancel();
        setState(() {
          isRunning = false;
          isPaused = false;
        });
      }
    });
    setState(() {
      isRunning = true;
      isPaused = false;
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isPaused = true;
      isRunning = false;
    });
  }

  void resumeTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (totalSeconds > 0) {
        setState(() => totalSeconds--);
      } else {
        timer?.cancel();
        setState(() {
          isRunning = false;
          isPaused = false;
        });
      }
    });
    setState(() {
      isPaused = false;
      isRunning = true;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      totalSeconds = 45 * 60; // 기본값
      isRunning = false;
      isPaused = false;
    });
  }

  void applyInput() {
    int minutes = int.tryParse(minuteController.text) ?? 0;
    int seconds = int.tryParse(secondController.text) ?? 0;

    minutes = minutes.clamp(0, 99);
    seconds = seconds.clamp(0, 59);

    setState(() {
      totalSeconds = minutes * 60 + seconds;
    });
  }

  // ====================
  Color backgroundColor = Palette.primary;
  Color textColor = Palette.textPrimary;
  String fontFamily = 'VT323';
  double fontSize = 50;
  bool showSettings = false;

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
      fontFamily = prefs.getString('fontFamily') ?? 'VT323';
      backgroundColor = Color(
        prefs.getInt('backgroundColor') ?? Palette.primary.value,
      );
      textColor = Color(prefs.getInt('textColor') ?? Palette.textPrimary.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayMinutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final displaySeconds = (totalSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 타이머 화면
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleSettings,
            child: Center(
              child: SizedBox(
                width: MediaQueryDogu.width(context) * 0.7,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$displayMinutes:$displaySeconds",
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
            GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 230,
                                            child: Column(
                                              children: [
                                                // 입력 부분
                                                (!isRunning && !isPaused)
                                                    ? Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              width: 100,
                                                              height: 40,
                                                              child: TextField(
                                                                controller:
                                                                    minuteController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly,
                                                                  LengthLimitingTextInputFormatter(
                                                                    2,
                                                                  ),
                                                                ],
                                                                cursorColor:
                                                                    Palette
                                                                        .textfieldCursorPrimary,
                                                                style: const TextStyle(
                                                                  color:
                                                                      Palette
                                                                          .textPrimary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                ),
                                                                decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Palette
                                                                      .textfieldPrimary
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  labelText:
                                                                      'm',
                                                                  labelStyle: const TextStyle(
                                                                    color:
                                                                        Palette
                                                                            .textPrimary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .never,
                                                                  border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    borderSide: BorderSide(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.5,
                                                                          ),
                                                                      width:
                                                                          1.5,
                                                                    ),
                                                                  ),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    borderSide: BorderSide(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.8,
                                                                          ),
                                                                      width:
                                                                          1.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onChanged: (
                                                                  value,
                                                                ) {
                                                                  if (value
                                                                          .isNotEmpty &&
                                                                      int.parse(
                                                                            value,
                                                                          ) >
                                                                          99) {
                                                                    // 분 입력 99초 제한
                                                                    minuteController
                                                                            .text =
                                                                        '99';
                                                                    minuteController
                                                                        .selection = TextSelection.fromPosition(
                                                                      TextPosition(
                                                                        offset:
                                                                            minuteController.text.length,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            SizedBox(
                                                              width: 100,
                                                              height: 40,
                                                              child: TextField(
                                                                controller:
                                                                    secondController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly,
                                                                  LengthLimitingTextInputFormatter(
                                                                    2,
                                                                  ),
                                                                ],
                                                                cursorColor:
                                                                    Palette
                                                                        .textfieldCursorPrimary,
                                                                style: const TextStyle(
                                                                  color:
                                                                      Palette
                                                                          .textPrimary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                ),
                                                                decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Palette
                                                                      .textfieldPrimary
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  labelText:
                                                                      's',
                                                                  labelStyle: const TextStyle(
                                                                    color:
                                                                        Palette
                                                                            .textPrimary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .never,
                                                                  border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    borderSide: BorderSide(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.5,
                                                                          ),
                                                                      width:
                                                                          1.5,
                                                                    ),
                                                                  ),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    borderSide: BorderSide(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.5,
                                                                          ),
                                                                      width:
                                                                          1.8,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onChanged: (
                                                                  value,
                                                                ) {
                                                                  if (value
                                                                          .isNotEmpty &&
                                                                      int.parse(
                                                                            value,
                                                                          ) >
                                                                          59) {
                                                                    // 초 입력 59초 제한
                                                                    secondController
                                                                            .text =
                                                                        '59';
                                                                    secondController
                                                                        .selection = TextSelection.fromPosition(
                                                                      TextPosition(
                                                                        offset:
                                                                            secondController.text.length,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    )
                                                    : const SizedBox.shrink(),
                                                (!isRunning && !isPaused)
                                                    ? SizedBox(
                                                      width: 180,
                                                      child: ElevatedButton(
                                                        onPressed: applyInput,
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Palette
                                                              .buttonSecondary
                                                              .withOpacity(0.8),
                                                          foregroundColor:
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.9,
                                                                  ),
                                                          shadowColor: Colors
                                                              .black
                                                              .withOpacity(0.2),
                                                          surfaceTintColor:
                                                              Colors
                                                                  .transparent,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            side: BorderSide(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.25,
                                                                  ),
                                                              width: 1.2,
                                                            ),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Apply',
                                                          style: TextStyle(
                                                            color:
                                                                Palette
                                                                    .textPrimary,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    : const SizedBox.shrink(),
                                                const SizedBox(height: 7),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (!isRunning && !isPaused)
                                                      IconButton(
                                                        icon: SvgPicture.asset(
                                                          'assets/icons/start.svg',
                                                          width: 60,
                                                          height: 60,
                                                          color:
                                                              Colors.blueAccent,
                                                        ),
                                                        onPressed: () {
                                                          startTimer();
                                                          setState(() {
                                                            isRunning = true;
                                                            isPaused = false;
                                                          });
                                                        },
                                                      ),
                                                    if (isRunning && !isPaused)
                                                      IconButton(
                                                        icon: SvgPicture.asset(
                                                          'assets/icons/pause.svg',
                                                          width: 40,
                                                          height: 40,
                                                          color:
                                                              Colors
                                                                  .orangeAccent,
                                                        ),
                                                        onPressed: () {
                                                          pauseTimer();
                                                          setState(() {
                                                            isPaused = true;
                                                          });
                                                        },
                                                      ),
                                                    // Resume 버튼 → 타이머 일시정지 상태일 때
                                                    if (!isRunning && isPaused)
                                                      IconButton(
                                                        icon: SvgPicture.asset(
                                                          'assets/icons/resume.svg',
                                                          width: 40,
                                                          height: 40,
                                                          color:
                                                              Colors
                                                                  .greenAccent,
                                                        ),
                                                        onPressed: () {
                                                          resumeTimer();
                                                          setState(() {
                                                            isPaused = false;
                                                          });
                                                        },
                                                      ),
                                                    // Reset 버튼 → 항상 보여주고 싶으면 그냥 넣으면 됨
                                                    if (!isRunning && isPaused)
                                                      IconButton(
                                                        icon: SvgPicture.asset(
                                                          'assets/icons/reset.svg',
                                                          width: 40,
                                                          height: 40,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        onPressed: () {
                                                          resetTimer();
                                                          setState(() {
                                                            isRunning = false;
                                                            isPaused = false;
                                                          });
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
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
                                                          backgroundColor =
                                                              color;
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
                                                              .withOpacity(
                                                                0.25,
                                                              ),
                                                          width: 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Background Color',
                                                      style: TextStyle(
                                                        color:
                                                            Palette
                                                                .textTertiary,
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
                                                              .withOpacity(
                                                                0.25,
                                                              ),
                                                          width: 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Text Color',
                                                      style: TextStyle(
                                                        color:
                                                            Palette
                                                                .textTertiary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                                    Palette
                                                        .sliderInactivePrimary,
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

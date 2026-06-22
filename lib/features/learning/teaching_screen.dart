import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../core/router/app_router.dart';
import '../../services/ai/openai_service.dart';
import '../../data/lesson_data.dart';
import '../../models/lesson.dart';
import '../../services/analytics/analytics_service.dart';

// ─────────────────────────────────────────────
//  BRAND TOKENS (Edurance Palette + Classroom Warmth - v0 Enhanced)
// ─────────────────────────────────────────────
class _C {
  // Primary Edurance colors
  static const teal = Color(0xFF26CCC2); // Primary teal
  static const aqua = Color(0xFF6AECE1); // Secondary aqua
  static const yellow = Color(0xFFFFF57E); // Highlight yellow
  static const orange = Color(0xFFFFB76C); // Accent orange
  static const bg = Color(0xFFFFFDF7); // Background cream
  static const dark = Color(0xFF22324A); // Text primary

  // Extended classroom palette
  static const coral = Color(0xFFFF6B6B);
  static const green = Color(0xFF59D98E);
  static const purple = Color(0xFF9B6BFF);
  static const blue = Color(0xFF4AC8FF);
  static const muted = Color(0xFF7A869A);
  static const white = Colors.white;

  // v0: Warm classroom atmosphere colors
  static const cream = Color(0xFFFFF8F3); // Warm speech bubble
  static const warmBorder = Color(0xFFFFE4C4); // Peach border
  static const peachGlow = Color(0xFFFFF0E5); // Soft peach background
  static const canvasInner = Color(0xFFFFFBF5); // Learning stage interior
  static const woodAccent = Color(0xFFE8D4C4); // Subtle wood tone
  static const softShadow = Color(0x12000000); // Very soft shadows
}

// ─────────────────────────────────────────────
//  PHASE ENUM
// ─────────────────────────────────────────────
enum _Phase { intro, mcq, feedback }

// ─────────────────────────────────────────────
//  TEACHING SCREEN
// ─────────────────────────────────────────────
class TeachingScreen extends StatefulWidget {
  const TeachingScreen({super.key});

  @override
  State<TeachingScreen> createState() => _TeachingScreenState();
}

class _TeachingScreenState extends State<TeachingScreen>
    with TickerProviderStateMixin {
  // ── Lesson state
  int _letterIndex = 0;
  _Phase _phase = _Phase.intro;
  int? _selectedOption;

  bool _moduleIntroSpoken = false;

  // Guards rhyme auto-play: true while narration + delay is in progress.
  bool _autoPlaying = false;
  // Prevents duplicate completion dialogs from auto-advance + manual tap race.
  bool _completionShown = false;

  // ── Analytics
  String? _sessionId;
  late DateTime _sessionStartedAt;

  // ── Initialization guard
  bool _initialized = false;

  // ── AI explanation state
  String? _aiExplanation;
  bool _loadingExplanation = false;

  late List<Lesson> activeLessons;
  late String moduleType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Prevent re-initialization on subsequent didChangeDependencies calls
    if (_initialized) return;

    final extra = GoRouterState.of(context).extra;

    if (extra is Map) {
      final map = Map<String, String>.from(extra as Map);
      moduleType = map['module'] ?? 'rhymes';
      final rhymeId = map['rhymeId'] ?? '';

      activeLessons = rhymeLessons
          .where((l) => l.id.startsWith('${rhymeId}_line_'))
          .toList();
    } else {
      moduleType = (extra as String?) ?? 'alphabet';

      switch (moduleType) {
        case 'numbers':
          activeLessons = numberLessons;
          break;
        case 'colors':
          activeLessons = colorLessons;
          break;
        case 'shapes':
          activeLessons = shapeLessons;
          break;
        case 'alphabet':
        default:
          activeLessons = alphabetLessons;
          break;
      }
    }

    // Reset intro speech when module changes
    _moduleIntroSpoken = false;

    _initialized = true;

    // Start audio + analytics AFTER moduleType and activeLessons are ready
    _resumeAndStartAudio();
  }

  Lesson get _lesson => activeLessons[_letterIndex];

  bool _isOptionCorrect(int index) {
    if (_lesson.options.isEmpty) return true;
    final opt = _lesson.options[index].toLowerCase();
    final t = _lesson.title.toLowerCase();
    if (_lesson.module == 'alphabet') return opt.startsWith(t);
    if (_lesson.module == 'colors') {
      final correctMap = {
        "red": "apple",
        "blue": "sky",
        "yellow": "banana",
        "green": "grass",
        "orange": "orange",
        "purple": "grapes",
        "black": "coal",
        "white": "milk",
        "brown": "chocolate",
        "pink": "pig"
      };
      return opt == correctMap[t];
    }
    return opt == t;
  }

  bool get _isCorrect =>
      _selectedOption != null && _isOptionCorrect(_selectedOption!);
  bool get _isLastLetter => _letterIndex == activeLessons.length - 1;

  Object _avatarKey = Object();

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceY;
  late final ConfettiController _confettiController;
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bounceY = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(
      CurvedAnimation(
        parent: _bounceCtrl,
        curve: Curves.easeInOut,
      ),
    );

    _bounceCtrl.repeat(reverse: true);

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  Future<void> _resumeAndStartAudio() async {
    final user = await Supabase.instance.client.auth.getUser();

    if (!mounted) return;

    final metadata = user.user?.userMetadata ?? {};

    final completed = metadata["${moduleType}_completedLessons"];

    if (completed == null) {
      debugPrint('Starting analytics session');
      _sessionStartedAt = DateTime.now();
      _sessionId = await AnalyticsService.startSession(
        lessonId: activeLessons[_letterIndex].id,
        subject: moduleType,
      );
      debugPrint('Analytics session created: $_sessionId');

      debugPrint('Starting lesson audio');
      try {
        await _startLessonAudio();
      } catch (e) {
        debugPrint('Lesson audio failed: $e');
      }
      return;
    }

    final completedLessons = List<String>.from(completed);

    final nextIndex = activeLessons.indexWhere(
      (lesson) => !completedLessons.contains(lesson.id),
    );

    if (!mounted) return;

    if (nextIndex == -1) {
      setState(() => _letterIndex = activeLessons.length - 1);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showCompletionDialog(),
      );
      return;
    }

    if (nextIndex != _letterIndex) {
      setState(() => _letterIndex = nextIndex);
    }

    debugPrint('Starting analytics session');
    _sessionStartedAt = DateTime.now();
    _sessionId = await AnalyticsService.startSession(
      lessonId: activeLessons[_letterIndex].id,
      subject: moduleType,
    );
    debugPrint('Analytics session created: $_sessionId');

    debugPrint('Starting lesson audio');
    try {
      await _startLessonAudio();
    } catch (e) {
      debugPrint('Lesson audio failed: $e');
    }
  }

  Future<int?> _fetchResumeIndex() async {
    final response = await Supabase.instance.client.auth.getUser();
    final completed = response.user?.userMetadata?['${moduleType}_completedLessons'];

    if (completed == null) return 0;
    final completedList = List<String>.from(completed as List);
    final nextIndex = activeLessons.indexWhere(
      (lesson) => !completedList.contains(lesson.id),
    );
    return nextIndex == -1 ? null : nextIndex;
  }

  Future<void> _startLessonAudio() async {
    if (moduleType == 'rhymes') {
      await _speakIntroAndAutoAdvance();
    } else {
      await _speakIntro();
    }
  }

  Future<void> _speakIntroAndAutoAdvance() async {
    _autoPlaying = true;
    await _speakIntro();

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted || !_autoPlaying) return;
    _autoPlaying = false;
    _goToMcq();
  }

  void _showCompletionDialog() {
    if (_completionShown) return;
    _completionShown = true;

    if (_lesson.module == 'rhymes') {
      _confettiController.play();
      final praises = [
        'Amazing Singing!',
        'You’re a Superstar!',
        'Fantastic Job!',
        'Wonderful Reading!'
      ];
      final praise = praises[Random().nextInt(praises.length)];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: _C.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎵',
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 16),
              Text(
                praise,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: _C.dark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _C.yellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⭐', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '+10 Stars!',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: const Color(0xFFF2994A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You finished ${_lesson.title}!",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.muted,
                ),
              ),
              const SizedBox(height: 32),
              _GreenButton(
                label: 'Back to Modules',
                onTap: () {
                  if (_sessionId != null) {
                    AnalyticsService.completeSession(
                      sessionId: _sessionId!,
                      score: _isCorrect ? 1 : 0,
                      timeSpentSeconds: DateTime.now()
                          .difference(_sessionStartedAt)
                          .inSeconds,
                    );
                  }
                  Navigator.of(context).pop();
                  context.go(AppRoutes.modules);
                },
              ),
            ],
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Great job! 🎉',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: _C.dark,
          ),
        ),
        content: Text(
          "You've finished all lessons in this module 🎉",
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.muted,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              if (_sessionId != null) {
                AnalyticsService.completeSession(
                  sessionId: _sessionId!,
                  score: _isCorrect ? 1 : 0,
                  timeSpentSeconds: DateTime.now()
                      .difference(_sessionStartedAt)
                      .inSeconds,
                );
              }
              Navigator.of(context).pop();
              context.go(AppRoutes.modules);
            },
            child: Text(
              'Back to Modules',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _C.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _speak(String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await OpenAIService.speakWithOpenAI(text);
  }

  Future<void> _speakIntro() async {
    final l = _lesson;

    switch (l.module) {
      case 'alphabet':
        if (!_moduleIntroSpoken) {
          await _speak('Let’s learn alphabets.');
          await Future.delayed(const Duration(milliseconds: 300));
          _moduleIntroSpoken = true;
        }
        await _speak('This is the letter ${l.title}.');
        break;

      case 'numbers':
        if (!_moduleIntroSpoken) {
          await _speak('Let’s learn numbers.');
          await Future.delayed(const Duration(milliseconds: 300));
          _moduleIntroSpoken = true;
        }
        await _speak('This is number ${l.title}.');
        break;

      case 'colors':
        if (!_moduleIntroSpoken) {
          await _speak('Let’s learn colors.');
          await Future.delayed(const Duration(milliseconds: 300));
          _moduleIntroSpoken = true;
        }
        await _speak('This is ${l.title}.');
        break;

      case 'shapes':
        if (!_moduleIntroSpoken) {
          await _speak('Let’s learn shapes.');
          await Future.delayed(const Duration(milliseconds: 300));
          _moduleIntroSpoken = true;
        }
        await _speak('This is a ${l.title}.');
        break;

      case 'rhymes':
        if (!_moduleIntroSpoken) {
          await _speak("Let's learn ${l.title}!");
          await Future.delayed(const Duration(milliseconds: 300));
          _moduleIntroSpoken = true;
        }
        await _speak(l.prompt);
        break;
    }
  }

  Future<void> _speakMcq() async {
    await _speak(_lesson.prompt);
  }

  Future<void> _speakFeedback() async {
    if (_isCorrect) {
      await _speak('Amazing! You got it right!');
    } else {
      await _speak('Let\'s try again!');
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _confettiController.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _goToMcq() {
    if (_lesson.module == 'rhymes') {
      _autoPlaying = false;
      _saveCompletedLesson(_lesson.id);
      if (_isLastLetter) {
        _showCompletionDialog();
      } else {
        _goToNextLetter();
      }
      return;
    }
    setState(() {
      _phase = _Phase.mcq;
      _avatarKey = Object();
    });
    _speakMcq();
  }

  void _selectOption(int index) {
    if (_phase != _Phase.mcq) return;
    setState(() {
      _selectedOption = index;
      _phase = _Phase.feedback;
      _avatarKey = Object();
      _aiExplanation = null;
    });

    final isCorrect = _isOptionCorrect(index);

    if (isCorrect) {
      _saveCompletedLesson(_lesson.id);
      _speakFeedback();
    } else {
      _fetchAndSpeakExplanation(index);
    }
  }

  Future<void> _fetchAndSpeakExplanation(int wrongIndex) async {
    setState(() {
      _loadingExplanation = true;
      _aiExplanation = null;
    });

    try {
      final explanation = await OpenAIService.getWrongAnswerExplanation(
        lessonTitle: _lesson.title,
        module: _lesson.module,
        correctAnswer: _lesson.options.firstWhere(
          (opt) => _isOptionCorrect(_lesson.options.indexOf(opt)),
        ),
        wrongAnswer: _lesson.options[wrongIndex],
        question: _lesson.prompt,
      );

      if (!mounted) return;

      setState(() {
        _aiExplanation = explanation;
        _loadingExplanation = false;
        _avatarKey = Object();
      });

      await _speak(explanation);
    } catch (e) {
      debugPrint('AI explanation failed: $e');

      if (!mounted) return;

      setState(() {
        _loadingExplanation = false;
        _aiExplanation = "That's okay! Let's learn together and try again.";
      });

      await _speak(_aiExplanation!);
    }
  }

  Future<void> _saveCompletedLesson(String letter) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final existing = user.userMetadata?['${moduleType}_completedLessons'];
    final List<String> lessons = existing != null
        ? List<String>.from(existing as List)
        : <String>[];

    if (lessons.contains(letter)) return;
    lessons.add(letter);

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(
        data: {'${moduleType}_completedLessons': lessons},
      ),
    );
  }

  void _goToNextLetter() {
    _autoPlaying = false;
    setState(() {
      if (!_isLastLetter) _letterIndex++;
      _phase = _Phase.intro;
      _selectedOption = null;
      _avatarKey = Object();
    });
    _startLessonAudio();
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: moduleType == 'rhymes' ? Colors.transparent : const Color(0xFFFFF0E5),
      body: Stack(
        children: [
          if (moduleType == 'rhymes') _buildRhymeBackground(),
          if (moduleType != 'rhymes') _buildClassroomBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use scrollable layout on mobile / short viewports
                final bool useScrollable = constraints.maxHeight < 700;
                if (useScrollable) {
                  return Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTutorCorner(),
                              _buildLearningStage(scrollable: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                // Desktop / large-screen layout: preserve existing Expanded behaviour
                return Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTutorCorner(),
                          Expanded(child: _buildLearningStage(scrollable: false)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.2,
                colors: const [
                  _C.coral,
                  _C.green,
                  _C.blue,
                  _C.yellow,
                  Colors.pinkAccent,
                  Colors.orangeAccent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRhymeBackground() {
    final rhymeId = _lesson.id.split('_line_').first;
    List<Color> gradient;
    IconData icon;
    Color iconColor;

    switch (rhymeId) {
      case 'twinkle':
        gradient = [const Color(0xFF1A237E), const Color(0xFF283593)];
        icon = Icons.star_rounded;
        iconColor = Colors.white.withValues(alpha: 0.15);
        break;
      case 'rain_rain':
        gradient = [const Color(0xFFCFD8DC), const Color(0xFF90A4AE)];
        icon = Icons.water_drop_rounded;
        iconColor = Colors.white.withValues(alpha: 0.3);
        break;
      case 'baa_baa':
        gradient = [const Color(0xFFE1F5FE), const Color(0xFFAED581)];
        icon = Icons.cloud_rounded;
        iconColor = Colors.white.withValues(alpha: 0.4);
        break;
      case 'humpty':
        gradient = [const Color(0xFFFFCC80), const Color(0xFFEF9A9A)];
        icon = Icons.wb_sunny_rounded;
        iconColor = Colors.white.withValues(alpha: 0.2);
        break;
      case 'johny':
      default:
        gradient = [const Color(0xFFF8BBD0), const Color(0xFFFFF9C4)];
        icon = Icons.favorite_rounded;
        iconColor = Colors.white.withValues(alpha: 0.3);
        break;
    }

    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (context, child) {
        final val = _bgCtrl.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width * 0.15 + (val * 20),
                top: MediaQuery.of(context).size.height * 0.1 + (val * 30),
                child: Icon(icon, size: 80, color: iconColor),
              ),
              Positioned(
                right: MediaQuery.of(context).size.width * 0.1 - (val * 15),
                top: MediaQuery.of(context).size.height * 0.45 + (val * 20),
                child: Icon(icon, size: 120, color: iconColor),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.35 + (val * 40),
                bottom: MediaQuery.of(context).size.height * 0.15 - (val * 10),
                child: Icon(icon, size: 60, color: iconColor),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────── CLASSROOM ATMOSPHERE (v0 Enhanced) ────────
  Widget _buildClassroomBackground() {
    return Stack(
      children: [
        // BASE: Multi-stop gradient for depth
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.7, 1.0],
              colors: [
                Color(0xFFFFFDF7), // Pure cream at top
                Color(0xFFFFF8F0), // Warm peach mid
                Color(0xFFFFF4E8), // Deeper peach-cream
                Color(0xFFF5F0EA), // Grounded bottom
              ],
            ),
          ),
        ),
        // FLOATING GLOW: Top-left warm blob
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _C.orange.withValues(alpha: 0.08),
                  _C.orange.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // FLOATING GLOW: Bottom-right teal atmosphere
        Positioned(
          bottom: -150,
          right: -100,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _C.teal.withValues(alpha: 0.06),
                  _C.teal.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // FLOATING GLOW: Center-right yellow warmth
        Positioned(
          top: 200,
          right: -40,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _C.yellow.withValues(alpha: 0.06),
                  _C.yellow.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────── TUTOR CORNER (v0 Enhanced) ────────
  Widget _buildTutorCorner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _C.woodAccent.withValues(alpha: 0.5),
                  _C.warmBorder.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: _C.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _C.orange.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _bounceY,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _phase == _Phase.intro ? _bounceY.value : 0),
                      child: child,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: _buildAvatarCircle(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _C.teal.withValues(alpha: 0.15),
                          _C.aqua.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _C.teal.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _C.teal,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _C.teal.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your Tutor',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _C.teal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _SpeechBubble(
                      key: ValueKey(_avatarKey),
                      text: _speechBubbleText(),
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

  Widget _buildAvatarCircle() {
    final String content;
    final bool isEmoji;

    switch (_phase) {
      case _Phase.intro:
        content = _lesson.module == 'alphabet' ? _lesson.title : _lesson.emoji;
        isEmoji = _lesson.module != 'alphabet';
        break;
      case _Phase.mcq:
        content = _lesson.emoji;
        isEmoji = true;
        break;
      case _Phase.feedback:
        content = _isCorrect ? '✅' : '❌';
        isEmoji = true;
        break;
    }

    final Color glowColor = _phase == _Phase.feedback
        ? (_isCorrect ? _C.green : _C.coral)
        : _C.teal;

    return Container(
      key: ValueKey('$_letterIndex-$_phase'),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: _C.dark.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _C.white,
              _C.cream,
            ],
            stops: const [0.7, 1.0],
          ),
          border: Border.all(
            color: glowColor.withValues(alpha: 0.35),
            width: 3,
          ),
        ),
        child: Center(
          child: isEmoji
              ? Text(content, style: const TextStyle(fontSize: 52))
              : Text(
                  content,
                  style: GoogleFonts.nunito(
                    fontSize: 58,
                    fontWeight: FontWeight.w900,
                    color: _C.teal,
                    height: 1.0,
                  ),
                ),
        ),
      ),
    );
  }

  String _speechBubbleText() {
    switch (_phase) {
      case _Phase.intro:
        if (_lesson.module == 'rhymes') return _lesson.prompt;
        return _lesson.module == 'alphabet'
            ? 'Here\'s the letter ${_lesson.title}! Let\'s learn it together! 🎓'
            : 'Today we\'re learning about ${_lesson.title}! 🌈';
      case _Phase.mcq:
        return _lesson.prompt;
      case _Phase.feedback:
        if (_isCorrect) return 'You nailed it! 🌟 I\'m so proud of you!';
        if (_loadingExplanation) return 'Hmm, let me think... I\'ll help you! 🤔';
        return _aiExplanation ?? 'No worries! Every great learner makes mistakes. Let\'s try again! 💛';
    }
  }

  // ─────── LEARNING STAGE (v0 Enhanced) ────────
  Widget _buildLearningStage({bool scrollable = false}) {
    if (moduleType == 'rhymes') {
      if (scrollable) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhaseContent(scrollable: true),
            _buildProgressDots(),
            const SizedBox(height: 12),
          ],
        );
      }
      return Column(
        children: [
          Expanded(child: _buildPhaseContent(scrollable: false)),
          _buildProgressDots(),
          const SizedBox(height: 12),
        ],
      );
    }

    final phaseContent = _buildPhaseContent(scrollable: scrollable);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _C.teal.withValues(alpha: 0.15),
                  _C.aqua.withValues(alpha: 0.08),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.teal.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: _C.dark.withValues(alpha: 0.04),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _C.canvasInner,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: _C.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.dark.withValues(alpha: 0.03),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: scrollable
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _C.teal.withValues(alpha: 0.4),
                                  _C.aqua.withValues(alpha: 0.6),
                                  _C.yellow.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                          phaseContent,
                          _buildProgressDots(),
                          const SizedBox(height: 10),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _C.teal.withValues(alpha: 0.4),
                                  _C.aqua.withValues(alpha: 0.6),
                                  _C.yellow.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: phaseContent),
                          _buildProgressDots(),
                          const SizedBox(height: 10),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────── PHASE CONTENT ────────
  Widget _buildPhaseContent({bool scrollable = false}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: KeyedSubtree(
        key: ValueKey('$_letterIndex-$_phase'),
        child: switch (_phase) {
          _Phase.intro => _buildIntroContent(scrollable: scrollable),
          _Phase.mcq => _buildMcqContent(scrollable: scrollable),
          _Phase.feedback => _buildFeedbackContent(scrollable: scrollable),
        },
      ),
    );
  }

  // ── INTRO ──
  Widget _buildIntroContent({bool scrollable = false}) {
    if (_lesson.module == 'rhymes') {
      return _buildRhymeIntroContent(scrollable: scrollable);
    }

    // Shared inner scrollable body (used in both modes)
    final innerBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _C.yellow.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "TODAY'S LESSON",
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFB8860B),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(_lesson.emoji, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text(
          _lesson.title,
          style: GoogleFonts.nunito(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: _C.dark,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            _lesson.prompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _C.muted,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✦', style: TextStyle(fontSize: 11, color: Color(0xFFCCAA44))),
            SizedBox(width: 6),
            Text('✦', style: TextStyle(fontSize: 17, color: Color(0xFFCCAA44))),
            SizedBox(width: 6),
            Text('✦', style: TextStyle(fontSize: 11, color: Color(0xFFCCAA44))),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );

    final decoratedBox = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.teal.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9B6BFF), Color(0xFF4AC8FF)],
                ),
              ),
            ),
            if (scrollable)
              innerBody
            else
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: innerBody,
                ),
              ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          scrollable ? decoratedBox : Expanded(child: decoratedBox),
          const SizedBox(height: 16),
          _GreenButton(
            label: "I got it! Let's answer →",
            onTap: _goToMcq,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRhymeIntroContent({bool scrollable = false}) {
    final rhymeCard = AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        key: ValueKey(_letterIndex),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _C.blue.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _C.purple.withValues(alpha: 0.05),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _lesson.prompt,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _C.dark,
                height: 1.3,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
        children: [
          scrollable ? rhymeCard : Expanded(child: rhymeCard),
          const SizedBox(height: 16),
          _GreenButton(
            label: _isLastLetter ? 'Finish rhyme! 🎉' : 'Next line →',
            onTap: _goToMcq,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── MCQ ──
  Widget _buildMcqContent({bool scrollable = false}) {
    final optionsList = Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_lesson.options.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OptionButton(
            label: _lesson.options[i],
            state: _OptionState.idle,
            onTap: () => _selectOption(i),
          ),
        );
      }),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _C.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🤔', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _lesson.prompt,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _C.dark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // On mobile (scrollable) the outer SingleChildScrollView handles scrolling;
          // on desktop we keep the inner Expanded + scroll.
          if (scrollable)
            optionsList
          else
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: optionsList,
              ),
            ),
        ],
      ),
    );
  }

  // ── FEEDBACK ──
  Widget _buildFeedbackContent({bool scrollable = false}) {
    final feedbackOptions = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_lesson.options.length, (i) {
        final _OptionState state;
        if (_isOptionCorrect(i)) {
          state = _OptionState.correct;
        } else if (i == _selectedOption) {
          state = _OptionState.wrong;
        } else {
          state = _OptionState.idle;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OptionButton(
            label: _lesson.options[i],
            state: state,
            onTap: null,
          ),
        );
      }),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? _C.green.withValues(alpha: 0.09)
                  : _C.yellow.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isCorrect
                    ? _C.green.withValues(alpha: 0.30)
                    : const Color(0xFFFFB76C).withValues(alpha: 0.40),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(_isCorrect ? '🌟' : '💛',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect ? 'Wonderful!' : 'Almost there!',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _isCorrect
                              ? _C.green
                              : const Color(0xFFD4891A),
                        ),
                      ),
                      Text(
                        _isCorrect
                            ? 'You got it right! Keep going 🎉'
                            : 'Great try — here\'s the answer below!',
                        style: GoogleFonts.nunito(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _C.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _lesson.prompt,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _C.muted,
            ),
          ),
          const SizedBox(height: 10),
          // On mobile (scrollable) let the outer scroll view handle overflow;
          // on desktop keep the inner Expanded + scroll.
          if (scrollable)
            feedbackOptions
          else
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: feedbackOptions,
              ),
            ),
          const SizedBox(height: 12),
          _isLastLetter
              ? _GreenButton(
                  label: "I'm done! 🎉",
                  onTap: () {
                    if (_sessionId != null) {
                      AnalyticsService.completeSession(
                        sessionId: _sessionId!,
                        score: _isCorrect ? 1 : 0,
                        timeSpentSeconds: DateTime.now()
                            .difference(_sessionStartedAt)
                            .inSeconds,
                      );
                    }
                    context.go(AppRoutes.modules);
                  },
                )
              : _GreenButton(
                  label: 'Next Letter →',
                  onTap: _goToNextLetter,
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────── PROGRESS DOTS ────────
  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(activeLessons.length, (i) {
            final isCurrent = i == _letterIndex;
            final isCompleted = i < _letterIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isCurrent ? 20 : 8,
              height: isCurrent ? 10 : 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isCurrent
                    ? _C.coral
                    : isCompleted
                        ? _C.green
                        : _C.muted.withValues(alpha: 0.25),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─────── TOP BAR (v0 Enhanced) ────────
  Widget _buildTopBar() {
    final progress = (_letterIndex + 1) / activeLessons.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
      decoration: BoxDecoration(
        color: _C.bg.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: _C.dark.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.cream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _C.warmBorder.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.go(AppRoutes.modules),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _C.muted,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      moduleType.toUpperCase(),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _C.dark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        if (_sessionId != null) {
                          AnalyticsService.incrementReplayCount(_sessionId!);
                        }
                        switch (_phase) {
                          case _Phase.intro:
                            _speakIntro();
                            break;
                          case _Phase.mcq:
                            _speakMcq();
                            break;
                          case _Phase.feedback:
                            if (_isCorrect) {
                              _speakFeedback();
                            } else if (_aiExplanation != null) {
                              _speak(_aiExplanation!);
                            } else {
                              _speakFeedback();
                            }
                            break;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _C.yellow.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _C.orange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.volume_up_rounded,
                              size: 14,
                              color: const Color(0xFFD4891A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hear again',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFD4891A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _C.teal.withValues(alpha: 0.12),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                colors: [_C.teal, _C.aqua],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _C.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_letterIndex + 1}/${activeLessons.length}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _C.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SPEECH BUBBLE (v0 Enhanced)
// ─────────────────────────────────────────────
class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _C.cream,
                const Color(0xFFFFF5ED),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _C.warmBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _C.orange.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: _C.dark.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.dark,
              height: 1.5,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(24, 12),
          painter: _TrianglePainter(
            fillColor: const Color(0xFFFFF5ED),
            borderColor: _C.warmBorder,
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  const _TrianglePainter({
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = fillColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}

// ─────────────────────────────────────────────
//  OPTION BUTTON (v0 Enhanced)
// ─────────────────────────────────────────────
enum _OptionState { idle, correct, wrong }

class _OptionButton extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg, border, textColor;
    final List<BoxShadow> shadows;

    switch (state) {
      case _OptionState.correct:
        bg = _C.green.withValues(alpha: 0.12);
        border = _C.green;
        textColor = const Color(0xFF1E8A55);
        shadows = [
          BoxShadow(
            color: _C.green.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case _OptionState.wrong:
        bg = _C.coral.withValues(alpha: 0.08);
        border = _C.coral;
        textColor = _C.coral;
        shadows = [];
        break;
      case _OptionState.idle:
        bg = _C.white;
        border = _C.warmBorder;
        textColor = _C.dark;
        shadows = [
          BoxShadow(
            color: _C.dark.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ];
        break;
    }

    final Widget trailing = switch (state) {
      _OptionState.correct => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_C.green, const Color(0xFF45C77B)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _C.green.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        ),
      _OptionState.wrong => Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: _C.coral,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
        ),
      _OptionState.idle => const SizedBox.shrink(),
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: shadows,
      ),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GREEN GRADIENT BUTTON
// ─────────────────────────────────────────────
class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GreenButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF6AECE1), Color(0xFF26CCC2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF26CCC2).withValues(alpha: 0.38),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _C.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
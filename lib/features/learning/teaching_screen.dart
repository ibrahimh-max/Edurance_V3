import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/app_router.dart';
import '../../services/elevenlabs_tts_service.dart';
import '../../services/ai/openai_service.dart';
import '../../data/lesson_data.dart';
import '../../models/lesson.dart';

// ─────────────────────────────────────────────
//  BRAND TOKENS
// ─────────────────────────────────────────────
class _C {
  static const yellow = Color(0xFFFFD94A);
  static const blue   = Color(0xFF4AC8FF);
  static const coral  = Color(0xFFFF6B6B);
  static const green  = Color(0xFF56CF7E);
  static const bg     = Color(0xFFFFF9F0);
  static const dark   = Color(0xFF2D2D3A);
  static const muted  = Color(0xFF9E9EA8);
  static const white  = Colors.white;
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
    with SingleTickerProviderStateMixin {
  // ── Lesson state
  int    _letterIndex    = 0;
  _Phase _phase          = _Phase.intro;
  int?   _selectedOption;

// ── TTS
final ElevenLabsTtsService _tts =
    ElevenLabsTtsService();


  // ── AI explanation state
  String? _aiExplanation;
  bool _loadingExplanation = false;

  late List<Lesson> activeLessons;
  late String moduleType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    moduleType = (GoRouterState.of(context).extra as String?) ?? 'alphabet';
    switch (moduleType) {
      case 'numbers': activeLessons = numberLessons; break;
      case 'colors': activeLessons = colorLessons; break;
      case 'shapes': activeLessons = shapeLessons; break;
      case 'rhymes': activeLessons = rhymeLessons; break;
      case 'alphabet':
      default:
        activeLessons = alphabetLessons;
        break;
    }
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

@override
void initState() {
  super.initState();

  // ── Bounce animation initialization (fixes LateInitializationError)
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

  // Resume correct lesson BEFORE audio starts
  _resumeAndStartAudio();
}

/// Restores the next incomplete alphabet lesson index from Supabase metadata
/// then starts lesson audio for that correct letter.
Future<void> _resumeAndStartAudio() async {
  final user =
      await Supabase.instance.client.auth.getUser();

  if (!mounted) return;

  final metadata =
      user.user?.userMetadata ?? {};

  final completed =
      metadata["${moduleType}_completedLessons"];

  if (completed == null) {
    // first-time learner → start from A
    await _startLessonAudio();
    return;
  }

  final completedLessons =
      List<String>.from(completed);

  final nextIndex = activeLessons.indexWhere(
    (lesson) =>
        !completedLessons.contains(lesson.id),
  );

  if (!mounted) return;

  if (nextIndex == -1) {
    // All lessons completed
    setState(() => _letterIndex = activeLessons.length - 1);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showCompletionDialog(),
    );
    return;
  }

  if (nextIndex != _letterIndex) {
    setState(() => _letterIndex = nextIndex);
  }

  await _startLessonAudio();
}



  /// Fetches the fresh resume index from Supabase, sets up TTS,
  /// then speaks the intro for the correct letter — in that order.

  /// Returns the next incomplete letter index, or null if all are done.
  /// Returns 0 if no completedLessons metadata exists yet.
  Future<int?> _fetchResumeIndex() async {
    final response =
        await Supabase.instance.client.auth.getUser();
    final completed =
        response.user?.userMetadata?['${moduleType}_completedLessons'];

    if (completed == null) return 0; // first-time user → start from A

    final completedList = List<String>.from(completed as List);
    final nextIndex = activeLessons.indexWhere(
      (lesson) => !completedList.contains(lesson.id),
    );

    return nextIndex == -1 ? null : nextIndex; // null = all done
  }



  /// Speaks the intro for the current lesson (called after index is set).
  Future<void> _startLessonAudio() async {
    await _speakIntro();
  }

  void _showCompletionDialog() {
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
Future.delayed(const Duration(milliseconds: 300), () {
  _tts.speak(text);
});
}

  Future<void> _speakIntro() async {
    final l = _lesson;
    switch (l.module) {
      case 'alphabet':
        await _speak('Let’s learn alphabets.');
        await Future.delayed(const Duration(milliseconds: 300));
        await _speak('This is the letter ${l.title}.');
        break;
      case 'numbers':
        await _speak('Let’s learn numbers.');
        await Future.delayed(const Duration(milliseconds: 300));
        await _speak('This is number ${l.title}.');
        break;
      case 'colors':
        await _speak('Let’s learn colors.');
        await Future.delayed(const Duration(milliseconds: 300));
        await _speak('This is ${l.title}.');
        break;
      case 'shapes':
        await _speak('Let’s learn shapes.');
        await Future.delayed(const Duration(milliseconds: 300));
        await _speak('This is a ${l.title}.');
        break;
      case 'rhymes':
        await _speak('Let’s learn a rhyme.');
        await Future.delayed(const Duration(milliseconds: 300));
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
  super.dispose();
}

  // ── Phase transitions
  void _goToMcq() {
    setState(() {
      _phase     = _Phase.mcq;
      _avatarKey = Object();
    });
    _speakMcq();
  }

void _selectOption(int index) {
    if (_phase != _Phase.mcq) return;
    setState(() {
      _selectedOption = index;
      _phase          = _Phase.feedback;
      _avatarKey      = Object();
      _aiExplanation  = null;
    });

    final isCorrect = _isOptionCorrect(index);

    if (isCorrect) {
      // Correct — persist completed letter to Supabase metadata
      _saveCompletedLesson(_lesson.id);
      // Correct — just speak immediately
      _speakFeedback();
    } else {
      // Wrong — fetch AI explanation first, then speak it
      _fetchAndSpeakExplanation(index);
    }
  }

  Future<void> _fetchAndSpeakExplanation(int wrongIndex) async {
    setState(() => _loadingExplanation = true);

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
      _aiExplanation     = explanation;
      _loadingExplanation = false;
      _avatarKey          = Object(); // refresh speech bubble
    });

    // Speak the AI-generated explanation
    await _speak(explanation);
  }

  Future<void> _saveCompletedLesson(String letter) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final existing = user.userMetadata?['${moduleType}_completedLessons'];
    final List<String> lessons = existing != null
        ? List<String>.from(existing as List)
        : <String>[];

    if (lessons.contains(letter)) return; // avoid duplicates
    lessons.add(letter);

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(
        data: {'${moduleType}_completedLessons': lessons},
      ),
    );
  }

  void _goToNextLetter() {
    setState(() {
      if (!_isLastLetter) _letterIndex++;
      _phase          = _Phase.intro;
      _selectedOption = null;
      _avatarKey      = Object();
    });
    _speakIntro();
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Column(
                children: [
                  _buildAvatarSection(),
                  Expanded(child: _buildPhaseContent()),
                  _buildProgressDots(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────── TOP BAR ────────
  Widget _buildTopBar() {
    final progress = (_letterIndex + 1) / activeLessons.length;

    return Container(
      color: _C.bg,
      padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: _C.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                 
                  context.go(AppRoutes.modules);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _C.green,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${moduleType.toUpperCase()} LESSONS',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _C.dark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tap to replay speech
                    GestureDetector(
                      onTap: () {
                        switch (_phase) {
                          case _Phase.intro:     _speakIntro();    break;
                          case _Phase.mcq:       _speakMcq();      break;
                          case _Phase.feedback:  _speakFeedback(); break;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _C.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up_rounded,
                                size: 14, color: _C.blue),
                            const SizedBox(width: 3),
                            Text(
                              'Replay',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _C.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor:
                              _C.green.withValues(alpha: 0.15),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(_C.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_letterIndex + 1}/${activeLessons.length}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _C.green,
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

  // ─────── AVATAR + SPEECH BUBBLE ────────
  Widget _buildAvatarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _bounceY,
            builder: (_, child) => Transform.translate(
              offset:
                  Offset(0, _phase == _Phase.intro ? _bounceY.value : 0),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: _SpeechBubble(
              key: ValueKey(_avatarKey),
              text: _speechBubbleText(),
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

    final Color shadowColor = _phase == _Phase.feedback
        ? (_isCorrect ? _C.green : _C.coral)
        : _C.coral;

    return Container(
      key: ValueKey('$_letterIndex-$_phase'),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: _C.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: isEmoji
            ? Text(content, style: const TextStyle(fontSize: 64))
            : Text(
                content,
                style: GoogleFonts.nunito(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: _C.coral,
                  height: 1.0,
                ),
              ),
      ),
    );
  }

String _speechBubbleText() {
    switch (_phase) {
      case _Phase.intro:
        return _lesson.module == 'alphabet'
            ? 'This is the letter ${_lesson.title}! Say it with me!'
            : 'Let\'s learn ${_lesson.title}!';
      case _Phase.mcq:
        return _lesson.prompt;
      case _Phase.feedback:
        if (_isCorrect) return 'Amazing! 🌟 You got it right!';
        if (_loadingExplanation) return 'Hmm, let me explain... 🤔';
        return _aiExplanation ?? 'Let\'s try again!';
    }
  }

  // ─────── PHASE CONTENT ────────
  Widget _buildPhaseContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: KeyedSubtree(
        key: ValueKey('$_letterIndex-$_phase'),
        child: switch (_phase) {
          _Phase.intro    => _buildIntroContent(),
          _Phase.mcq      => _buildMcqContent(),
          _Phase.feedback => _buildFeedbackContent(),
        },
      ),
    );
  }

  // ── INTRO ──
  Widget _buildIntroContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _C.coral.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_lesson.emoji,
                      style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    _lesson.title,
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: _C.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _lesson.prompt,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _GreenButton(
            label: "I got it! Let's answer →",
            onTap: _goToMcq,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── MCQ ──
  Widget _buildMcqContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _lesson.prompt,
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _C.dark,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_lesson.options.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionButton(
                label: _lesson.options[i],
                state: _OptionState.idle,
                onTap: () => _selectOption(i),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── FEEDBACK ──
  Widget _buildFeedbackContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _lesson.prompt,
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _C.dark,
            ),
          ),
          const SizedBox(height: 14),
          // Scrollable options — prevents overflow when explanation is long
          Flexible(
            child: SingleChildScrollView(
              child: Column(
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
              ),
            ),
          ),
          const SizedBox(height: 12),
          _isLastLetter
              ? _GreenButton(
                  label: "I'm done! 🎉",
                  onTap: () {
                   
                    context.go(AppRoutes.modules);
                  },
                )
              : _GreenButton(
                  label: 'Next Letter →',
                  onTap: _goToNextLetter,
                ),
          const SizedBox(height: 4),
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
            final isCurrent   = i == _letterIndex;
            final isCompleted = i < _letterIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width:  isCurrent ? 20 : 8,
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
}

// ─────────────────────────────────────────────
//  SPEECH BUBBLE
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _C.muted.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _C.dark,
              height: 1.45,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(20, 10),
          painter: _TrianglePainter(color: _C.white),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path  = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ─────────────────────────────────────────────
//  OPTION BUTTON
// ─────────────────────────────────────────────
enum _OptionState { idle, correct, wrong }

class _OptionButton extends StatelessWidget {
  final String        label;
  final _OptionState  state;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg, border, textColor;

    switch (state) {
      case _OptionState.correct:
        bg        = _C.green.withValues(alpha: 0.12);
        border    = _C.green;
        textColor = _C.green;
        break;
      case _OptionState.wrong:
        bg        = _C.coral.withValues(alpha: 0.10);
        border    = _C.coral;
        textColor = _C.coral;
        break;
      case _OptionState.idle:
        bg        = _C.white;
        border    = _C.muted.withValues(alpha: 0.35);
        textColor = _C.dark;
        break;
    }

    final Widget trailing = switch (state) {
      _OptionState.correct => const Text('✅',
          style: TextStyle(fontSize: 18)),
      _OptionState.wrong   => const Text('❌',
          style: TextStyle(fontSize: 18)),
      _OptionState.idle    => const SizedBox.shrink(),
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 56,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 1.8),
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
    );
  }
}

// ─────────────────────────────────────────────
//  GREEN GRADIENT BUTTON
// ─────────────────────────────────────────────
class _GreenButton extends StatelessWidget {
  final String       label;
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
            colors: [Color(0xFF7DDFAA), _C.green],
          ),
          boxShadow: [
            BoxShadow(
              color: _C.green.withValues(alpha: 0.40),
              blurRadius: 18,
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
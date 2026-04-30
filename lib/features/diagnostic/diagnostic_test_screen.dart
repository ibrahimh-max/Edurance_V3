import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/app_router.dart';

// ─────────────────────────────────────────────
//  BRAND TOKENS
// ─────────────────────────────────────────────
class _C {
  static const yellow = Color(0xFFFFD94A);
  static const blue   = Color(0xFF4AC8FF);
  static const coral  = Color(0xFFFF6B6B);
  static const green  = Color(0xFF56CF7E);
  static const purple = Color(0xFFAB7BFF);
  static const bg     = Color(0xFFFFF9F0);
  static const dark   = Color(0xFF1A1A2E);
  static const muted  = Color(0xFF9E9EA8);

  static const subjectColors = {
    'alphabet': yellow,
    'numbers':  blue,
    'colors':   green,
    'shapes':   coral,
    'rhymes':   purple,
  };

  static const subjectEmojis = {
    'alphabet': '📖',
    'numbers':  '🔢',
    'colors':   '🎨',
    'shapes':   '🔺',
    'rhymes':   '🎵',
  };

  static const subjectGradients = {
    'alphabet': [Color(0xFFFFF3CC), Color(0xFFFFEA9F)],
    'numbers':  [Color(0xFFD6F4FF), Color(0xFFB8EEFF)],
    'colors':   [Color(0xFFD5F8E5), Color(0xFFB6F0CF)],
    'shapes':   [Color(0xFFFFDFDF), Color(0xFFFFCCCC)],
    'rhymes':   [Color(0xFFEDE0FF), Color(0xFFDBC8FF)],
  };

  static const optionLabels = ['A', 'B', 'C', 'D'];
}

// ─────────────────────────────────────────────
//  QUESTION MODEL
// ─────────────────────────────────────────────
class _Question {
  final String module;
  final String text;
  final List<String> options;
  final int correctIndex;

  const _Question({
    required this.module,
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

// ─────────────────────────────────────────────
//  HARDCODED 20 QUESTIONS (4 per subject)
// ─────────────────────────────────────────────
const _questions = <_Question>[

/// ALPHABET (3)

_Question(
module: "alphabet",
text: "Which one is the letter A?",
options: ["A","B","3","D"],
correctIndex: 0
),

_Question(
module: "alphabet",
text: "Which word starts with B?",
options: ["Ball","Cat","Dog","Sun"],
correctIndex: 0
),

_Question(
module: "alphabet",
text: "Which one is NOT a letter?",
options: ["A","M","4","Z"],
correctIndex: 2
),

/// NUMBERS (3)

_Question(
module: "numbers",
text: "Which number is 3?",
options: ["1","2","3","5"],
correctIndex: 2
),

_Question(
module: "numbers",
text: "Which group shows four?",
options: ["••••","••","•••","•••••"],
correctIndex: 0
),

_Question(
module: "numbers",
text: "Which number is bigger?",
options: ["2","5","1","3"],
correctIndex: 1
),

/// COLORS (3)

_Question(
module: "colors",
text: "Which one is red?",
options: ["Apple","Sky","Grass","Banana"],
correctIndex: 0
),

_Question(
module: "colors",
text: "Which fruit is yellow?",
options: ["Banana","Apple","Orange","Grapes"],
correctIndex: 0
),

_Question(
module: "colors",
text: "Which one is NOT blue?",
options: ["Sky","Ocean","Banana","River"],
correctIndex: 2
),

/// SHAPES (3)

_Question(
module: "shapes",
text: "Which shape is a circle?",
options: ["⚪","⬛","🔺","⭐"],
correctIndex: 0
),

_Question(
module: "shapes",
text: "Which shape has 3 sides?",
options: ["Triangle","Circle","Square","Oval"],
correctIndex: 0
),

_Question(
module: "shapes",
text: "Which one is NOT a square?",
options: ["⬛","🟦","⚪","🟥"],
correctIndex: 2
),

/// RHYMES (2)

_Question(
module: "rhymes",
text: "Twinkle twinkle little ___",
options: ["star","cat","sun","tree"],
correctIndex: 0
),

_Question(
module: "rhymes",
text: "Have you heard this rhyme before?",
options: ["Yes","No","Maybe","Not sure"],
correctIndex: 0
),

];

// ─────────────────────────────────────────────
//  DIAGNOSTIC TEST SCREEN
// ─────────────────────────────────────────────
class DiagnosticTestScreen extends StatefulWidget {
  const DiagnosticTestScreen({super.key});

  @override
  State<DiagnosticTestScreen> createState() => _DiagnosticTestScreenState();
}

class _DiagnosticTestScreenState extends State<DiagnosticTestScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedOption;
  final Map<int, int> _answers = {}; // questionIndex → selectedOption

  // Animations
  late final AnimationController _progressAnim;
  late Animation<double> _progressValue;

  late final AnimationController _cardEntrance;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardFade;

  late final AnimationController _mascotBounce;
  late final Animation<double> _mascotY;

  late final AnimationController _nextBtnAnim;
  late final Animation<double> _nextBtnScale;

  @override
  void initState() {
    super.initState();

    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _progressValue = Tween<double>(begin: 1 / 20, end: 1 / 20).animate(
      CurvedAnimation(parent: _progressAnim, curve: Curves.easeInOutCubic),
    );

    _cardEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _cardSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _cardEntrance, curve: Curves.easeOutCubic),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardEntrance, curve: Curves.easeIn),
    );
    _cardEntrance.forward();

    _mascotBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _mascotY = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _mascotBounce, curve: Curves.easeInOut),
    );

    _nextBtnAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _nextBtnScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _nextBtnAnim, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _progressAnim.dispose();
    _cardEntrance.dispose();
    _mascotBounce.dispose();
    _nextBtnAnim.dispose();
    super.dispose();
  }

  _Question get _currentQ => _questions[_currentIndex];
  Color get _accent => _C.subjectColors[_currentQ.module] ?? _C.blue;
  String get _emoji => _C.subjectEmojis[_currentQ.module] ?? '📚';
  List<Color> get _gradColors =>
      _C.subjectGradients[_currentQ.module] ?? [_C.bg, _C.bg];
  bool get _isLast => _currentIndex == _questions.length - 1;

  void _selectOption(int idx) {
    if (_selectedOption != null) return; // lock after first tap
    setState(() => _selectedOption = idx);
    _answers[_currentIndex] = idx;
    _nextBtnAnim.forward();
  }

  void _goNext() {
    if (_isLast) {
      _onComplete();
      return;
    }
    final next = _currentIndex + 1;

    // animate progress
    _progressValue = Tween<double>(
      begin: _progressValue.value,
      end: (next + 1) / _questions.length,
    ).animate(
      CurvedAnimation(parent: _progressAnim, curve: Curves.easeInOutCubic),
    );
    _progressAnim
      ..reset()
      ..forward();

    // reset card entrance + selection
    _cardEntrance.reset();
    _nextBtnAnim.reset();
    setState(() {
      _currentIndex = next;
      _selectedOption = _answers[next]; // restore if user went back (future)
    });
    _cardEntrance.forward();
    if (_selectedOption != null) _nextBtnAnim.forward();
  }

void _onComplete() {
  context.go(AppRoutes.diagnosticReport, extra: Map<int, int>.from(_answers));
}

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _gradColors[0],
              _gradColors[1],
              _C.bg,
            ],
            stops: const [0.0, 0.28, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 8),
              _buildSubjectBadge(),
              const SizedBox(height: 12),
              Expanded(child: _buildQuestionBody()),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── TOP BAR: progress ────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Back button
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.go(AppRoutes.login),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Floating mascot
                  AnimatedBuilder(
                    animation: _mascotY,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _mascotY.value),
                      child: child,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(_emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Question ${_currentIndex + 1}',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _C.dark,
                    ),
                  ),
                ],
              ),
              // Counter chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_questions.length}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          AnimatedBuilder(
            animation: _progressValue,
            builder: (_, __) {
              return Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // track dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(20, (i) {
                          return Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: _C.muted.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      // fill
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressValue.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [_accent, _accent.withValues(alpha: 0.65)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────── SUBJECT BADGE ────────
  Widget _buildSubjectBadge() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Container(
        key: ValueKey('${_currentQ.module}-$_currentIndex'),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _accent.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              _currentQ.module,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────── QUESTION BODY ────────
  Widget _buildQuestionBody() {
    return AnimatedBuilder(
      animation: _cardEntrance,
      builder: (_, child) => Opacity(
        opacity: _cardFade.value,
        child: Transform.translate(
          offset: Offset(0, _cardSlide.value),
          child: child,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // Question card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                _currentQ.text,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _C.dark,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Options
            ...List.generate(4, (i) => _buildOption(i)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int idx) {
    final isSelected = _selectedOption == idx;
    final isCorrect  = idx == _currentQ.correctIndex;
    final hasAnswered = _selectedOption != null;

    // After answering: green for correct, coral for wrong pick, muted for rest
    Color bgColor;
    Color borderColor;
    Color textColor;
    Color labelBgColor;
    Color labelTextColor;

    if (!hasAnswered) {
      bgColor       = Colors.white;
      borderColor   = _C.muted.withValues(alpha: 0.18);
      textColor     = _C.dark;
      labelBgColor  = _C.muted.withValues(alpha: 0.08);
      labelTextColor = _C.muted;
    } else if (isCorrect) {
      bgColor       = _C.green.withValues(alpha: 0.10);
      borderColor   = _C.green;
      textColor     = _C.dark;
      labelBgColor  = _C.green;
      labelTextColor = Colors.white;
    } else if (isSelected && !isCorrect) {
      bgColor       = _C.coral.withValues(alpha: 0.08);
      borderColor   = _C.coral;
      textColor     = _C.dark;
      labelBgColor  = _C.coral;
      labelTextColor = Colors.white;
    } else {
      bgColor       = Colors.white;
      borderColor   = _C.muted.withValues(alpha: 0.10);
      textColor     = _C.muted;
      labelBgColor  = _C.muted.withValues(alpha: 0.06);
      labelTextColor = _C.muted.withValues(alpha: 0.5);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: hasAnswered ? null : () => _selectOption(idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: isSelected || (hasAnswered && isCorrect)
                ? [
                    BoxShadow(
                      color: (isCorrect ? _C.green : _C.coral)
                          .withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Label (A, B, C, D)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: labelBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _C.optionLabels[idx],
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: labelTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _currentQ.options[idx],
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              // Feedback icon
              if (hasAnswered && isCorrect)
                const _FeedbackIcon(
                  icon: Icons.check_circle_rounded,
                  color: _C.green,
                ),
              if (hasAnswered && isSelected && !isCorrect)
                const _FeedbackIcon(
                  icon: Icons.cancel_rounded,
                  color: _C.coral,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── BOTTOM BAR: Next / See Results ────────
  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step dots (mini)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (i) {
              final answered = _answers.containsKey(i);
              final isCurrent = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width:  isCurrent ? 14 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? _accent
                      : answered
                          ? _accent.withValues(alpha: 0.4)
                          : _C.muted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Next / See Results button
          AnimatedBuilder(
            animation: _nextBtnScale,
            builder: (_, child) {
              return Transform.scale(
                scale: _nextBtnScale.value,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _selectedOption != null ? _goNext : null,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: _isLast
                        ? [_C.green, const Color(0xFF3DB86A)]
                        : [_accent, _accent.withValues(alpha: 0.75)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isLast ? _C.green : _accent)
                          .withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLast ? 'See Results' : 'Next',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isLast
                          ? Icons.emoji_events_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
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
}

// ─────────────────────────────────────────────
//  SMALL HELPER WIDGETS
// ─────────────────────────────────────────────

class _FeedbackIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _FeedbackIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (_, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

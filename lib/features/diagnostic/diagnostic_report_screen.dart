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
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
enum _Tier { star, almost, learn }

class _SubjectResult {
  final String name;
  final String emoji;
  final int score;   // out of 4
  final int total;
  final Color accent;
  final _Tier tier;

  const _SubjectResult({
    required this.name,
    required this.emoji,
    required this.score,
    required this.total,
    required this.accent,
    required this.tier,
  });

  double get pct => score / total;
}

// ─────────────────────────────────────────────
//  HARDCODED DUMMY REPORT DATA
// ─────────────────────────────────────────────
const _results = <_SubjectResult>[
  _SubjectResult(
    name: 'Math', emoji: '🔢', score: 4, total: 4,
    accent: _C.yellow, tier: _Tier.star,
  ),
  _SubjectResult(
    name: 'Science', emoji: '🔬', score: 3, total: 4,
    accent: _C.green, tier: _Tier.star,
  ),
  _SubjectResult(
    name: 'English', emoji: '📖', score: 2, total: 4,
    accent: _C.blue, tier: _Tier.almost,
  ),
  _SubjectResult(
    name: 'EVS', emoji: '🌍', score: 2, total: 4,
    accent: _C.purple, tier: _Tier.almost,
  ),
  _SubjectResult(
    name: 'Hindi', emoji: '🕉️', score: 1, total: 4,
    accent: _C.coral, tier: _Tier.learn,
  ),
];

// ── Section metadata
class _SectionData {
  final String title;
  final String subtitle;
  final Color color;
  final Color cardBg;
  final Color cardBorder;
  final List<Color> headerGradient;

  const _SectionData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.cardBg,
    required this.cardBorder,
    required this.headerGradient,
  });
}

final _sections = {
  _Tier.star: const _SectionData(
    title: '⭐ You\'re a Star At!',
    subtitle: 'Amazing job — keep shining!',
    color: _C.green,
    cardBg: Color(0xFFE8FFF0),
    cardBorder: Color(0xFFA8E6BE),
    headerGradient: [Color(0xFFD5F8E5), Color(0xFFBBF0D0)],
  ),
  _Tier.almost: const _SectionData(
    title: '💪 Almost There!',
    subtitle: 'Just a little more practice!',
    color: _C.yellow,
    cardBg: Color(0xFFFFF8E1),
    cardBorder: Color(0xFFFFE082),
    headerGradient: [Color(0xFFFFF3CC), Color(0xFFFFEA9F)],
  ),
  _Tier.learn: const _SectionData(
    title: '📚 Let\'s Learn This Together!',
    subtitle: 'We\'ll make it super fun!',
    color: _C.coral,
    cardBg: Color(0xFFFFF0F0),
    cardBorder: Color(0xFFFFB3B3),
    headerGradient: [Color(0xFFFFDFDF), Color(0xFFFFCCCC)],
  ),
};

// ─────────────────────────────────────────────
//  DIAGNOSTIC REPORT SCREEN
// ─────────────────────────────────────────────
class DiagnosticReportScreen extends StatefulWidget {
  const DiagnosticReportScreen({super.key});

  @override
  State<DiagnosticReportScreen> createState() => _DiagnosticReportScreenState();
}

class _DiagnosticReportScreenState extends State<DiagnosticReportScreen>
    with TickerProviderStateMixin {
  // Animations
  late final AnimationController _heroEntrance;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroFade;

  late final AnimationController _mascotBounce;
  late final Animation<double> _mascotY;

  late final AnimationController _confettiBurst;
  late final Animation<double> _confettiScale;

  late final AnimationController _ctaShimmer;
  late final Animation<double> _shimmer;

  // Staggered card entrance
  late final AnimationController _cardsEntrance;

  @override
  void initState() {
    super.initState();

    _heroEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _heroScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _heroEntrance, curve: Curves.elasticOut),
    );
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroEntrance, curve: Curves.easeIn),
    );

    _mascotBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _mascotY = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _mascotBounce, curve: Curves.easeInOut),
    );

    _confettiBurst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _confettiBurst, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _confettiBurst.forward();
    });

    _ctaShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmer = Tween<double>(begin: -2.0, end: 3.0).animate(
      CurvedAnimation(parent: _ctaShimmer, curve: Curves.easeInOut),
    );

    _cardsEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _cardsEntrance.forward();
    });
  }

  @override
  void dispose() {
    _heroEntrance.dispose();
    _mascotBounce.dispose();
    _confettiBurst.dispose();
    _ctaShimmer.dispose();
    _cardsEntrance.dispose();
    super.dispose();
  }

  void _onStart() => context.go(AppRoutes.modules);

  // Total score
  int get _totalScore => _results.fold(0, (sum, r) => sum + r.score);
  int get _totalPossible => _results.fold(0, (sum, r) => sum + r.total);

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8FFF0), Color(0xFFFFF9F0), Color(0xFFFFF9F0)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHero(),
                const SizedBox(height: 28),
                _buildScoreRing(),
                const SizedBox(height: 32),
                ..._buildSections(),
                const SizedBox(height: 28),
                _buildCtaButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────── HERO ────────
  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _heroEntrance,
      builder: (_, child) => Opacity(
        opacity: _heroFade.value,
        child: Transform.scale(scale: _heroScale.value, child: child),
      ),
      child: Column(
        children: [
          // Mascot + confetti
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // confetti emojis
                AnimatedBuilder(
                  animation: _confettiScale,
                  builder: (_, __) => Transform.scale(
                    scale: _confettiScale.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ConfettiEmoji(emoji: '🎊', dx: -50, dy: -20),
                        _ConfettiEmoji(emoji: '✨', dx: -30, dy: -35),
                        _ConfettiEmoji(emoji: '🌟', dx: 30, dy: -30),
                        _ConfettiEmoji(emoji: '🎉', dx: 50, dy: -15),
                      ],
                    ),
                  ),
                ),
                // Mascot
                AnimatedBuilder(
                  animation: _mascotY,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _mascotY.value),
                    child: child,
                  ),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _C.green.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Great Job! 🎉',
            style: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: _C.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Here\'s how you did on the diagnostic test',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _C.muted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────── SCORE RING ────────
  Widget _buildScoreRing() {
    final pct = _totalScore / _totalPossible;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _C.green.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular score indicator
          SizedBox(
            width: 80,
            height: 80,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) {
                return CustomPaint(
                  painter: _RingPainter(
                    progress: value,
                    trackColor: _C.muted.withValues(alpha: 0.12),
                    fillColor: _C.green,
                    strokeWidth: 8,
                  ),
                  child: Center(
                    child: Text(
                      '${(value * 100).round()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _C.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Score',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.muted,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$_totalScore',
                        style: GoogleFonts.nunito(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: _C.dark,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: ' / $_totalPossible',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _C.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _totalScore >= 15
                      ? 'Outstanding! You\'re a superstar! 🌟'
                      : _totalScore >= 10
                          ? 'Good effort! Keep going! 💪'
                          : 'Great start! Let\'s learn together! 📚',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────── SECTIONS ────────
  List<Widget> _buildSections() {
    final grouped = <_Tier, List<_SubjectResult>>{};
    for (final r in _results) {
      grouped.putIfAbsent(r.tier, () => []).add(r);
    }

    final widgets = <Widget>[];
    var cardIndex = 0;

    for (final tier in [_Tier.star, _Tier.almost, _Tier.learn]) {
      final subjects = grouped[tier];
      if (subjects == null || subjects.isEmpty) continue;
      final section = _sections[tier]!;

      widgets.add(
        _buildSectionBlock(section, subjects, cardIndex),
      );
      cardIndex += subjects.length;
      widgets.add(const SizedBox(height: 20));
    }

    return widgets;
  }

  Widget _buildSectionBlock(
    _SectionData section,
    List<_SubjectResult> subjects,
    int startIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: section.headerGradient),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: section.cardBorder.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _C.dark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                section.subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Subject cards
        ...List.generate(subjects.length, (i) {
          final delay = (startIndex + i) / (_results.length + 2);
          return _StaggeredCard(
            animation: _cardsEntrance,
            delay: delay,
            child: _SubjectCard(
              result: subjects[i],
              section: section,
            ),
          );
        }),
      ],
    );
  }

  // ─────── CTA BUTTON ────────
  Widget _buildCtaButton() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        return GestureDetector(
          onTap: _onStart,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(_shimmer.value - 1, -0.3),
                end: Alignment(_shimmer.value + 1, 0.3),
                colors: [
                  _C.green,
                  const Color(0xFF6EE09A),
                  Colors.white.withValues(alpha: 0.25),
                  const Color(0xFF6EE09A),
                  _C.green,
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.green.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Start Learning!',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🚀', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  SUBJECT CARD
// ─────────────────────────────────────────────
class _SubjectCard extends StatelessWidget {
  final _SubjectResult result;
  final _SectionData section;

  const _SubjectCard({required this.result, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: section.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: section.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: section.color.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Subject emoji bubble
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: result.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: result.accent.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                result.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name + score bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.dark,
                  ),
                ),
                const SizedBox(height: 8),
                // Score bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: result.pct),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) {
                      return Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: section.cardBorder.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: section.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Score text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: section.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${result.score}/${result.total}',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: section.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STAGGERED ENTRANCE ANIMATION WRAPPER
// ─────────────────────────────────────────────
class _StaggeredCard extends StatelessWidget {
  final Animation<double> animation;
  final double delay; // 0.0 – 1.0
  final Widget child;

  const _StaggeredCard({
    required this.animation,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + 0.4).clamp(0, 1), curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (_, child) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curved.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  CONFETTI HELPER
// ─────────────────────────────────────────────
class _ConfettiEmoji extends StatelessWidget {
  final String emoji;
  final double dx;
  final double dy;

  const _ConfettiEmoji({
    required this.emoji,
    required this.dx,
    required this.dy,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}

// ─────────────────────────────────────────────
//  RING PAINTER (circular progress)
// ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Fill arc
    const startAngle = -1.5708; // -π/2  (12 o'clock)
    final sweepAngle = 6.2832 * progress; // 2π * progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

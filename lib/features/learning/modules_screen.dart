import 'dart:math' as math;

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
//  SUBJECT MODEL
// ─────────────────────────────────────────────
class _Subject {
  final String name;
  final String emoji;
  final String currentTopic;
  final double progress;     // 0.0 – 1.0
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final List<Color> gradient;

  const _Subject({
    required this.name,
    required this.emoji,
    required this.currentTopic,
    required this.progress,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.gradient,
  });
}

// ─────────────────────────────────────────────
//  HARDCODED DUMMY DATA
// ─────────────────────────────────────────────
const _subjects = <_Subject>[
  _Subject(
    name: 'Math',
    emoji: '➕',
    currentTopic: 'Addition & Subtraction',
    progress: 0.72,
    accent: _C.yellow,
    accentLight: Color(0xFFFFF8D6),
    accentDark: Color(0xFFE6B800),
    gradient: [Color(0xFFFFE566), Color(0xFFFFD94A)],
  ),
  _Subject(
    name: 'English',
    emoji: '📖',
    currentTopic: 'Nouns & Pronouns',
    progress: 0.45,
    accent: _C.blue,
    accentLight: Color(0xFFDFF6FF),
    accentDark: Color(0xFF1AAEE6),
    gradient: [Color(0xFF73D6FF), Color(0xFF4AC8FF)],
  ),
  _Subject(
    name: 'Science',
    emoji: '🔬',
    currentTopic: 'Plants & Their Parts',
    progress: 0.60,
    accent: _C.green,
    accentLight: Color(0xFFDCFAEB),
    accentDark: Color(0xFF38B564),
    gradient: [Color(0xFF7DDFAA), Color(0xFF56CF7E)],
  ),
  _Subject(
    name: 'Hindi',
    emoji: 'अ',
    currentTopic: 'स्वर और व्यंजन',
    progress: 0.30,
    accent: _C.coral,
    accentLight: Color(0xFFFFEBEB),
    accentDark: Color(0xFFE64444),
    gradient: [Color(0xFFFF9090), Color(0xFFFF6B6B)],
  ),
  _Subject(
    name: 'EVS',
    emoji: '🌿',
    currentTopic: 'Our Environment',
    progress: 0.85,
    accent: _C.purple,
    accentLight: Color(0xFFF0E8FF),
    accentDark: Color(0xFF8A56E6),
    gradient: [Color(0xFFC49EFF), Color(0xFFAB7BFF)],
  ),
];

// ─────────────────────────────────────────────
//  MODULES SCREEN
// ─────────────────────────────────────────────
class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen>
    with TickerProviderStateMixin {
  // Child name (hardcoded; will come from auth/state later)
  static const _childName = 'Aarav';

  // Animations
  late final AnimationController _headerEntrance;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerSlide;

  late final AnimationController _gridEntrance;

  late final AnimationController _mascotBounce;
  late final Animation<double> _mascotY;

  late final AnimationController _streakPulse;
  late final Animation<double> _streakScale;

  @override
  void initState() {
    super.initState();

    _headerEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerEntrance, curve: Curves.easeIn),
    );
    _headerSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _headerEntrance, curve: Curves.easeOutCubic),
    );

    _gridEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _gridEntrance.forward();
    });

    _mascotBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _mascotY = Tween<double>(begin: 0, end: -7).animate(
      CurvedAnimation(parent: _mascotBounce, curve: Curves.easeInOut),
    );

    _streakPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _streakScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _streakPulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _headerEntrance.dispose();
    _gridEntrance.dispose();
    _mascotBounce.dispose();
    _streakPulse.dispose();
    super.dispose();
  }

  void _onSubjectTap(_Subject subject) {
    // TODO: pass subject name via GoRouter extras once extras API is wired
    context.go(AppRoutes.teaching);
  }

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
            colors: [Color(0xFFFFF3CC), Color(0xFFFFF9F0)],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildStreakBanner()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Your Subjects',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _C.dark,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                sliver: _buildGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── HEADER ────────
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerEntrance,
      builder: (_, child) => Opacity(
        opacity: _headerFade.value,
        child: Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hello $_childName! ',
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _C.dark,
                          ),
                        ),
                        const TextSpan(
                          text: '👋',
                          style: TextStyle(fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What are we learning today?',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _C.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Floating mascot avatar
            AnimatedBuilder(
              animation: _mascotY,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _mascotY.value),
                child: child,
              ),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _C.yellow.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🦁', style: TextStyle(fontSize: 30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────── STREAK BANNER ────────
  Widget _buildStreakBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AnimatedBuilder(
        animation: _streakScale,
        builder: (_, child) => Transform.scale(
          scale: _streakScale.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9A3C), Color(0xFFFF6B6B)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _C.coral.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5-Day Streak!',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Keep it up — you\'re on fire!',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⭐ 320 pts',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── SUBJECT GRID ────────
  SliverGrid _buildGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final subject = _subjects[index];
          // staggered delay per card
          final delay = index * 0.15;
          final end   = (delay + 0.5).clamp(0.0, 1.0);
          final curved = CurvedAnimation(
            parent: _gridEntrance,
            curve: Interval(delay, end, curve: Curves.easeOutCubic),
          );
          return AnimatedBuilder(
            animation: curved,
            builder: (_, child) => Opacity(
              opacity: curved.value,
              child: Transform.translate(
                offset: Offset(0, 40 * (1 - curved.value)),
                child: child,
              ),
            ),
            child: _SubjectCard(
              subject: subject,
              onTap: () => _onSubjectTap(subject),
            ),
          );
        },
        childCount: _subjects.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.88,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SUBJECT CARD WIDGET
// ─────────────────────────────────────────────
class _SubjectCard extends StatefulWidget {
  final _Subject subject;
  final VoidCallback onTap;

  const _SubjectCard({required this.subject, required this.onTap});

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _pressScale;
  late final Animation<double> _pressElevation;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
    _pressElevation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _press.forward();
  void _onTapUp(_) => _press.reverse();
  void _onTapCancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final s = widget.subject;

    return AnimatedBuilder(
      animation: _press,
      builder: (_, child) => Transform.scale(
        scale: _pressScale.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _pressElevation,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: s.accent.withValues(alpha: 0.35 * _pressElevation.value),
                  blurRadius: 20 * _pressElevation.value,
                  offset: Offset(0, 8 * _pressElevation.value),
                ),
                BoxShadow(
                  color: s.accent.withValues(alpha: 0.15 * _pressElevation.value),
                  blurRadius: 8 * _pressElevation.value,
                  offset: Offset(0, 2 * _pressElevation.value),
                ),
              ],
            ),
            child: child,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: s.gradient,
                ),
              ),
              child: Stack(
                children: [
                  // Background decoration circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: -15,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Card content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: emoji + progress ring
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji badge
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: s.name == 'Hindi'
                                    ? Text(
                                        s.emoji,
                                        style: GoogleFonts.nunito(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        s.emoji,
                                        style: const TextStyle(fontSize: 26),
                                      ),
                              ),
                            ),
                            // Circular progress
                            SizedBox(
                              width: 46,
                              height: 46,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: s.progress),
                                duration: const Duration(milliseconds: 1100),
                                curve: Curves.easeOutCubic,
                                builder: (_, value, __) {
                                  return CustomPaint(
                                    painter: _RingPainter(
                                      progress: value,
                                      trackColor: Colors.white.withValues(alpha: 0.3),
                                      fillColor: Colors.white,
                                      strokeWidth: 4.5,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${(value * 100).round()}%',
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Subject name
                        Text(
                          s.name,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Current topic chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s.currentTopic,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: s.progress),
                            duration: const Duration(milliseconds: 1100),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, __) {
                              return Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 6,
                                      color: Colors.white,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RING PAINTER (reused from report screen)
// ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,           // 12 o'clock
      2 * math.pi * progress,
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

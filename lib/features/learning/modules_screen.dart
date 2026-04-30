import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/router/app_router.dart';
import '../../providers/signup_notifier.dart';
import '../../data/lesson_data.dart';
import '../../models/lesson.dart';


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

class _Subject {
  final String name;
  final String emoji;
  final String currentTopic;
  final double progress;
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

  String get displayName {
    switch (name.toLowerCase()) {
      case 'english': return 'Alphabets';
      case 'maths': return 'Numbers';
      case 'science': return 'Colors';
      case 'evs': return 'Shapes';
      case 'hindi': return 'Rhymes';
      default: return name;
    }
  }

  _Subject copyWith({double? progress}) => _Subject(
    name: name,
    emoji: emoji,
    currentTopic: currentTopic,
    progress: progress ?? this.progress,
    accent: accent,
    accentLight: accentLight,
    accentDark: accentDark,
    gradient: gradient,
  );
}

const _subjects = <_Subject>[
  _Subject(
    name: 'English',
    emoji: '📖',
    currentTopic: 'Alphabets A–Z',
    progress: 0.0,
    accent: _C.blue,
    accentLight: Color(0xFFDFF6FF),
    accentDark: Color(0xFF1AAEE6),
    gradient: [Color(0xFF73D6FF), Color(0xFF4AC8FF)],
  ),
  _Subject(
    name: 'Maths',
    emoji: '🔢',
    currentTopic: 'Primary Colours',
    progress: 0.0,
    accent: _C.coral,
    accentLight: Color(0xFFFFE5E5),
    accentDark: Color(0xFFE64444),
    gradient: [Color(0xFFFF9A8B), Color(0xFFFF6B6B)],
  ),
  _Subject(
    name: 'Science',
    emoji: '🔬',
    currentTopic: 'Basic Shapes',
    progress: 0.0,
    accent: _C.green,
    accentLight: Color(0xFFDFFFF0),
    accentDark: Color(0xFF3AB85A),
    gradient: [Color(0xFF7DDFAA), Color(0xFF56CF7E)],
  ),
  _Subject(
    name: 'Hindi',
    emoji: '📝',
    currentTopic: 'Short Poems',
    progress: 0.0,
    accent: _C.purple,
    accentLight: Color(0xFFF0E6FF),
    accentDark: Color(0xFF8A55E6),
    gradient: [Color(0xFFC5A3FF), Color(0xFFAB7BFF)],
  ),
  _Subject(
    name: 'EVS',
    emoji: '🌍',
    currentTopic: 'My Family & Home',
    progress: 0.0,
    accent: _C.yellow,
    accentLight: Color(0xFFFFF8D6),
    accentDark: Color(0xFFE6B800),
    gradient: [Color(0xFFFFE07A), Color(0xFFFFD94A)],
  ),
];

class ModulesScreen extends ConsumerStatefulWidget {
  const ModulesScreen({super.key});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends ConsumerState<ModulesScreen>
    with TickerProviderStateMixin {

  late final AnimationController _headerEntrance;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerSlide;

  late final AnimationController _gridEntrance;

  late final AnimationController _mascotBounce;
  late final Animation<double> _mascotY;

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
  }

  @override
  void dispose() {
    _headerEntrance.dispose();
    _gridEntrance.dispose();
    _mascotBounce.dispose();
    super.dispose();
  }

  void _onSubjectTap(_Subject subject) {
    String moduleType = 'alphabet';
    switch (subject.name.toLowerCase()) {
      case 'english': moduleType = 'alphabet'; break;
      case 'maths': moduleType = 'numbers'; break;
      case 'science': moduleType = 'colors'; break;
      case 'hindi': moduleType = 'rhymes'; break;
      case 'evs': moduleType = 'shapes'; break;
    }
    context.go(AppRoutes.teaching, extra: moduleType);
  }

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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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

  Widget _buildHeader() {
    final childName = ref.watch(signupProvider).childName.isEmpty
        ? 'Learner'
        : ref.watch(signupProvider).childName;
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
                          text: 'Hello $childName! ',
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
                    'What do you want to learn today? 🚀',
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
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.go(AppRoutes.parentControl),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👨\u200d👩\u200d👧',
                      style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Subject> _sortedSubjects() {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;

    // ── Compute real progress from completedLessons metadata ──
    final rawLessons = meta?['completedLessons'];
    final List<String> completedList = rawLessons is List ? List<String>.from(rawLessons) : [];

    double getProgress(List<Lesson> lessons) {
      if (lessons.isEmpty) return 0.0;
      final count = lessons.where((l) => completedList.contains(l.id)).length;
      return (count / lessons.length).clamp(0.0, 1.0);
    }

    final double englishProgress = getProgress(alphabetLessons);
    final double mathsProgress   = getProgress(numberLessons);
    final double scienceProgress = getProgress(colorLessons);
    final double hindiProgress   = getProgress(rhymeLessons);
    final double evsProgress     = getProgress(shapeLessons);

    _Subject applyProgress(_Subject s) {
      switch (s.name.toLowerCase()) {
        case 'english': return s.copyWith(progress: englishProgress);
        case 'maths':   return s.copyWith(progress: mathsProgress);
        case 'science': return s.copyWith(progress: scienceProgress);
        case 'hindi':   return s.copyWith(progress: hindiProgress);
        case 'evs':     return s.copyWith(progress: evsProgress);
        default:        return s;
      }
    }

    if (meta == null || meta['diagnosticCompleted'] != true) {
      return List.of(_subjects).map(applyProgress).toList();
    }

    int priority(String level) {
      switch (level) {
        case 'learn':  return 0;
        case 'almost': return 1;
        case 'star':   return 2;
        default:       return 1; // fallback to middle
      }
    }

    String metaKey(String subjectName) {
      // "Maths" → "math", others lowercase as-is
      final lower = subjectName.toLowerCase();
      final base = lower.endsWith('s') ? lower.substring(0, lower.length - 1) : lower;
      return '${base}Level';
    }

    final sorted = List.of(_subjects).map(applyProgress).toList();
    sorted.sort((a, b) {
      final pa = priority((meta[metaKey(a.name)] as String?) ?? 'almost');
      final pb = priority((meta[metaKey(b.name)] as String?) ?? 'almost');
      return pa.compareTo(pb);
    });
    return sorted;
  }

  SliverGrid _buildGrid() {
    final subjects = _sortedSubjects();
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final subject = subjects[index];
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
        childCount: subjects.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.92,
      ),
    );
  }
}

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

    // ── Determine diagnostic level for shadow emphasis ──
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    final level = (meta?['${widget.subject.name.toLowerCase()}Level'] as String?) ?? 'star';

    // "learn" → +40% blur, slight elevation boost; "almost" → +15% blur
    final double blurMul = switch (level) {
      'learn'  => 1.40,
      'almost' => 1.15,
      _        => 1.0,
    };
    final double elevMul = switch (level) {
      'learn'  => 1.20,
      _        => 1.0,
    };

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
                  color: s.accent.withValues(
                      alpha: 0.35 * _pressElevation.value),
                  blurRadius: 20 * blurMul * _pressElevation.value,
                  offset: Offset(0, 8 * elevMul * _pressElevation.value),
                ),
                BoxShadow(
                  color: s.accent.withValues(
                      alpha: 0.15 * _pressElevation.value),
                  blurRadius: 8 * blurMul * _pressElevation.value,
                  offset: Offset(0, 2 * elevMul * _pressElevation.value),
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
                  Positioned(
                    top: -20, right: -20,
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30, left: -15,
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(s.emoji,
                                    style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                            SizedBox(
                              width: 46, height: 46,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: s.progress),
                                duration: const Duration(milliseconds: 1100),
                                curve: Curves.easeOutCubic,
                                builder: (_, value, __) {
                                  return CustomPaint(
                                    painter: _RingPainter(
                                      progress: value,
                                      trackColor:
                                          Colors.white.withValues(alpha: 0.3),
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
                        Text(
                          s.displayName,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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
      center, radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
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
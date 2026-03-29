import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const white  = Colors.white;
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class _SubjectSchedule {
  final String name;
  final String emoji;
  final Color  accent;
  final Color  accentLight;
  final List<Color> gradient;

  // Mutable state — booleans for each day (Mon–Sun)
  final List<bool> active;

  _SubjectSchedule({
    required this.name,
    required this.emoji,
    required this.accent,
    required this.accentLight,
    required this.gradient,
    required List<bool> defaults,
  }) : active = List<bool>.from(defaults);
}

// ─────────────────────────────────────────────
//  PARENT CONTROL SCREEN
// ─────────────────────────────────────────────
class ParentControlScreen extends StatefulWidget {
  const ParentControlScreen({super.key});

  @override
  State<ParentControlScreen> createState() => _ParentControlScreenState();
}

class _ParentControlScreenState extends State<ParentControlScreen>
    with TickerProviderStateMixin {

  // ── Schedule data (default active days hardcoded)
  late final List<_SubjectSchedule> _schedules;

  // ── Animations
  late final AnimationController _headerEntrance;
  late final Animation<double>   _headerFade;
  late final Animation<double>   _headerSlide;

  late final AnimationController _summaryPulse;
  late final Animation<double>   _summaryScale;

  late final AnimationController _cardsEntrance;

  late final AnimationController _saveShimmer;
  late final Animation<double>   _shimmer;

  bool _savePressed = false;

  @override
  void initState() {
    super.initState();

    // Defaults: weekday-only for most subjects, weekend for Maths
    _schedules = [
      _SubjectSchedule(
        name: 'Math', emoji: '➕',
        accent: _C.yellow, accentLight: const Color(0xFFFFF8D6),
        gradient: const [Color(0xFFFFE566), Color(0xFFFFD94A)],
        defaults: [true, true, false, true, true, true, false],
      ),
      _SubjectSchedule(
        name: 'English', emoji: '📖',
        accent: _C.blue, accentLight: const Color(0xFFDFF6FF),
        gradient: const [Color(0xFF73D6FF), Color(0xFF4AC8FF)],
        defaults: [true, false, true, false, true, false, false],
      ),
      _SubjectSchedule(
        name: 'Science', emoji: '🔬',
        accent: _C.green, accentLight: const Color(0xFFDCFAEB),
        gradient: const [Color(0xFF7DDFAA), Color(0xFF56CF7E)],
        defaults: [false, true, false, true, false, false, false],
      ),
      _SubjectSchedule(
        name: 'Hindi', emoji: 'अ',
        accent: _C.coral, accentLight: const Color(0xFFFFEBEB),
        gradient: const [Color(0xFFFF9090), Color(0xFFFF6B6B)],
        defaults: [true, false, false, true, false, false, true],
      ),
      _SubjectSchedule(
        name: 'EVS', emoji: '🌿',
        accent: _C.purple, accentLight: const Color(0xFFF0E8FF),
        gradient: const [Color(0xFFC49EFF), Color(0xFFAB7BFF)],
        defaults: [false, false, true, false, false, true, false],
      ),
    ];

    _headerEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerEntrance, curve: Curves.easeIn),
    );
    _headerSlide = Tween<double>(begin: -24, end: 0).animate(
      CurvedAnimation(parent: _headerEntrance, curve: Curves.easeOutCubic),
    );

    _summaryPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _summaryScale = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _summaryPulse, curve: Curves.easeInOut),
    );

    _cardsEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardsEntrance.forward();
    });

    _saveShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmer = Tween<double>(begin: -2.0, end: 3.0).animate(
      CurvedAnimation(parent: _saveShimmer, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _headerEntrance.dispose();
    _summaryPulse.dispose();
    _cardsEntrance.dispose();
    _saveShimmer.dispose();
    super.dispose();
  }

  // ── Computed totals
  int get _totalSessions =>
      _schedules.fold(0, (sum, s) => sum + s.active.where((a) => a).length);

  int _subjectSessions(_SubjectSchedule s) => s.active.where((a) => a).length;

  void _toggleDay(_SubjectSchedule schedule, int dayIdx) {
    setState(() => schedule.active[dayIdx] = !schedule.active[dayIdx]);
  }

  void _onSave() {
    // TODO: persist to Supabase
    setState(() => _savePressed = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _savePressed = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('✅', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Schedule saved! $_totalSessions sessions/week',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _C.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
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
            colors: [Color(0xFFFFECEC), Color(0xFFFFF9F0)],
            stops: [0.0, 0.32],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildSummaryCard()),
              SliverToBoxAdapter(child: _buildSectionLabel()),
              ..._buildScheduleCards(),
              SliverToBoxAdapter(child: _buildTipsCard()),
              SliverToBoxAdapter(child: _buildSaveButton()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── TOP BAR ────────
  Widget _buildTopBar() {
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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parent Dashboard',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _C.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Set your child\'s weekly learning plan 📅',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.muted,
                    ),
                  ),
                ],
              ),
            ),
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEBEB), Color(0xFFFFD6D6)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _C.coral.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text('👨‍👩‍👧', style: TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────── SUMMARY CARD ────────
  Widget _buildSummaryCard() {
    final total = _totalSessions;
    return AnimatedBuilder(
      animation: _summaryScale,
      builder: (_, child) => Transform.scale(
        scale: _summaryScale.value,
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8F8F), _C.coral],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _C.coral.withValues(alpha: 0.4),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Big count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total',
                  style: GoogleFonts.nunito(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: _C.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  'sessions this week',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Per-subject mini dots
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: _schedules.map((s) {
                final count = _subjectSessions(s);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.name,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mini day dots
                      ...List.generate(7, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: s.active[i]
                                ? _C.white
                                : _C.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _C.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────── SECTION LABEL ────────
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Row(
        children: [
          Text(
            'Weekly Schedule',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _C.dark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _C.coral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Tap to toggle days',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.coral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────── SCHEDULE CARDS ────────
  List<Widget> _buildScheduleCards() {
    return List.generate(_schedules.length, (index) {
      final delay = index * 0.15;
      final end   = (delay + 0.45).clamp(0.0, 1.0);
      final curved = CurvedAnimation(
        parent: _cardsEntrance,
        curve: Interval(delay, end, curve: Curves.easeOutCubic),
      );
      return SliverToBoxAdapter(
        child: AnimatedBuilder(
          animation: curved,
          builder: (_, child) => Opacity(
            opacity: curved.value,
            child: Transform.translate(
              offset: Offset(0, 36 * (1 - curved.value)),
              child: child,
            ),
          ),
          child: _ScheduleCard(
            schedule: _schedules[index],
            onToggle: (dayIdx) => _toggleDay(_schedules[index], dayIdx),
            sessionCount: _subjectSessions(_schedules[index]),
          ),
        ),
      );
    });
  }

  // ─────── TIPS CARD ────────
  Widget _buildTipsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _C.blue.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expert Tip',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _C.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Research shows 20–30 minutes of focused learning per subject, '
                  '3–4 days per week gives the best results for young learners. '
                  'Keep it fun and consistent! 🌟',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3D3D52),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────── SAVE BUTTON ────────
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (_, __) => GestureDetector(
          onTap: _savePressed ? null : _onSave,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _savePressed
                  ? LinearGradient(
                      colors: [
                        _C.green,
                        const Color(0xFF3DB86A),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment(_shimmer.value - 1, -0.3),
                      end:   Alignment(_shimmer.value + 1,  0.3),
                      colors: const [
                        _C.coral,
                        Color(0xFFFF9A3C),
                        _C.yellow,
                        Color(0xFFFF9A3C),
                        _C.coral,
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
              boxShadow: [
                BoxShadow(
                  color: (_savePressed ? _C.green : _C.coral)
                      .withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _savePressed
                      ? const Text('✅', key: ValueKey('saved'),
                          style: TextStyle(fontSize: 22))
                      : const Text('💾', key: ValueKey('save'),
                          style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _savePressed ? 'Schedule Saved!' : 'Save Schedule',
                    key: ValueKey(_savePressed),
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _C.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SCHEDULE CARD WIDGET
// ─────────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  final _SubjectSchedule schedule;
  final ValueChanged<int> onToggle;
  final int sessionCount;

  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.sessionCount,
  });

  @override
  Widget build(BuildContext context) {
    final s = schedule;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: s.accent.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row
          Row(
            children: [
              // Subject gradient badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: s.gradient),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: s.accent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: s.name == 'Hindi'
                      ? Text(
                          s.emoji,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          s.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _C.dark,
                      ),
                    ),
                    Text(
                      '$sessionCount day${sessionCount == 1 ? '' : 's'} per week',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
              ),
              // Session count badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sessionCount > 0
                      ? s.accent.withValues(alpha: 0.12)
                      : _C.muted.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sessionCount > 0 ? '$sessionCount/7' : 'none',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: sessionCount > 0 ? s.accent : _C.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Day chips row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isActive = s.active[i];
              return _DayChip(
                label: _days[i],
                isActive: isActive,
                accent: s.accent,
                accentLight: s.accentLight,
                onTap: () => onToggle(i),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DAY CHIP WIDGET
// ─────────────────────────────────────────────
class _DayChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final Color accent;
  final Color accentLight;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.isActive,
    required this.accent,
    required this.accentLight,
    required this.onTap,
  });

  @override
  State<_DayChip> createState() => _DayChipState();
}

class _DayChipState extends State<_DayChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _bounce, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounce.forward().then((_) => _bounce.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 38,
          height: 48,
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.accent
                : _C.muted.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive
                  ? widget.accent
                  : _C.muted.withValues(alpha: 0.18),
              width: 2,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.38),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label.substring(0, 1), // single letter: M T W T F S S
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: widget.isActive
                      ? _C.white
                      : _C.muted.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? _C.white.withValues(alpha: 0.7)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

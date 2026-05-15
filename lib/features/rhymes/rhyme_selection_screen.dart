import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../data/rhyme_data.dart';
import '../../models/rhyme.dart';

// ─────────────────────────────────────────────
//  BRAND TOKENS (mirrored from TeachingScreen)
// ─────────────────────────────────────────────
class _C {
  static const yellow = Color(0xFFFFD94A);
  static const blue   = Color(0xFF4AC8FF);
  static const coral  = Color(0xFFFF6B6B);
  static const green  = Color(0xFF56CF7E);
  static const purple = Color(0xFFAB7BFF);
  static const bg     = Color(0xFFFFF9F0);
  static const dark   = Color(0xFF2D2D3A);
  static const muted  = Color(0xFF9E9EA8);
  static const white  = Colors.white;
}

// Accent colours cycling per card
const _cardColors = [
  Color(0xFFAB7BFF), // purple
  Color(0xFF4AC8FF), // blue
  Color(0xFFFF6B6B), // coral
  Color(0xFF56CF7E), // green
  Color(0xFFFFD94A), // yellow
];

class RhymeSelectionScreen extends StatelessWidget {
  const RhymeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pick a Rhyme! 🎶',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _C.dark,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose the one you want to learn today.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.muted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: allRhymes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final rhyme = allRhymes[index];
                  final color = _cardColors[index % _cardColors.length];
                  return _RhymeCard(
                    rhyme: rhyme,
                    color: color,
                    onTap: () => context.go(
                      AppRoutes.teaching,
                      extra: {
                        'module': 'rhymes',
                        'rhymeId': rhyme.id,
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
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
                onTap: () => context.go(AppRoutes.modules),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _C.green,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'RHYMES',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _C.dark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RHYME CARD
// ─────────────────────────────────────────────
class _RhymeCard extends StatefulWidget {
  final Rhyme rhyme;
  final Color color;
  final VoidCallback onTap;

  const _RhymeCard({
    required this.rhyme,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RhymeCard> createState() => _RhymeCardState();
}

class _RhymeCardState extends State<_RhymeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: c.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Coloured emoji slab
              Container(
                width: 72,
                height: 80,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.18),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.rhyme.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title + line count
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.rhyme.title,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _C.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.rhyme.lines.length} lines',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow chevron
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: c,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

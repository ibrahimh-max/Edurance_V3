
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/router/app_router.dart';
import '../../providers/signup_notifier.dart';
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

  // Page-accent pairs  [bg-gradient top, bg-gradient bottom, accent]
  static const pageAccents = [
    [Color(0xFFFFF3CC), Color(0xFFFFEA9F), yellow],   // page 0 – name
    [Color(0xFFD6F4FF), Color(0xFFB8EEFF), blue],     // page 1 – gender
    [Color(0xFFD5F8E5), Color(0xFFB6F0CF), green],    // page 2 – age/class
    [Color(0xFFFFDFDF), Color(0xFFFFCCCC), coral],    // page 3 – mobile
  ];

  static const mascots = ['🦁', '🐨', '🦊', '🐸'];
  static const pageTitles = [
    'What\'s your name?',
    'I am a…',
    'How old are you?',
    'Parent\'s number',
  ];
  static const pageSubtitles = [
    'Tell us so we can cheer for you!',
    'Pick one — you\'re awesome either way!',
    'So we can match you with the right lessons!',
    'We\'ll only use this in emergencies 🛡️',
  ];
}

// ─────────────────────────────────────────────
//  ENTRY POINT (for quick standalone testing)
//  Remove this and wire via GoRouter when ready
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
//  SIGNUP SCREEN
// ─────────────────────────────────────────────
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  // ── PageController
  final _pageController = PageController();
  int _currentPage = 0;

  // ── Form data
  final _nameController    = TextEditingController();
  final _mobileController  = TextEditingController();
  String? _gender;       // 'Boy' | 'Girl' | 'Other'
  int    _age   = 7;
  int?   _grade;         // 1–5

  // ── Animation controllers
  late final AnimationController _progressAnim;
  late final AnimationController _mascotBounce;
  late final AnimationController _mascotWiggle;
  late final AnimationController _ctaShimmer;

  late Animation<double> _progressValue;
  late Animation<double> _mascotOffset;
  late Animation<double> _mascotAngle;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressValue = Tween<double>(begin: 0.25, end: 0.25).animate(
      CurvedAnimation(parent: _progressAnim, curve: Curves.easeInOutCubic),
    );

    _mascotBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _mascotOffset = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _mascotBounce, curve: Curves.easeInOut),
    );

    _mascotWiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _mascotAngle = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _mascotWiggle, curve: Curves.easeInOut),
    );

    _ctaShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctaShimmer, curve: Curves.easeInOut),
    );

    _nameController.addListener(_rebuild);
    _nameController.addListener(() {
      ref.read(signupProvider.notifier)
          .updateChildName(_nameController.text.trim());
    });
    _mobileController.addListener(_rebuild);
    _mobileController.addListener(() {
      ref.read(signupProvider.notifier)
          .updateParentMobile(_mobileController.text.trim());
    });
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _progressAnim.dispose();
    _mascotBounce.dispose();
    _mascotWiggle.dispose();
    _ctaShimmer.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // ── Validation
  bool get _isCurrentPageValid {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _gender != null;
      case 2:
        return _grade != null;
      case 3:
        return _mobileController.text.trim().length == 10;
      default:
        return false;
    }
  }

  // ── Navigation
  void _animateProgress(int toPage) {
    final target = (toPage + 1) / 4;
    _progressValue = Tween<double>(
      begin: _progressValue.value,
      end: target,
    ).animate(CurvedAnimation(parent: _progressAnim, curve: Curves.easeInOutCubic));
    _progressAnim
      ..reset()
      ..forward();
  }

  void _goNext() {
    if (!_isCurrentPageValid) return;
    _triggerMascotWiggle();
    final next = _currentPage + 1;
    if (next >= 4) {
      _onSubmit();
      return;
    }
    setState(() => _currentPage = next);
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
    _animateProgress(next);
  }

  void _goBack() {
    if (_currentPage == 0) return;
    final prev = _currentPage - 1;
    setState(() => _currentPage = prev);
    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
    _animateProgress(prev);
  }

  void _triggerMascotWiggle() {
    _mascotWiggle.reset();
    _mascotWiggle.forward().orCancel.then((_) {
      if (mounted) _mascotWiggle.reverse();
    }).catchError((_) {/* cancelled – ignore */});
  }

Future<void> _onSubmit() async {

  final signupState = ref.read(signupProvider);

  final email =
      '${signupState.parentMobile}@edurance.app';

  final password =
      signupState.parentMobile;

  final supabase =
      Supabase.instance.client;

  AuthResponse response;

  try {

    response =
        await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

  } catch (_) {

    response =
        await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'childName': signupState.childName,
        'gender': signupState.gender,
        'age': signupState.age,
        'classLevel': signupState.classLevel,
        'parentMobile': signupState.parentMobile,
        'diagnosticCompleted': false,
      },
    );

  }

  if (!mounted) return;

  context.go(AppRoutes.diagnosticTest);

}

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final accent = _C.pageAccents[_currentPage][2];
    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _C.pageAccents[_currentPage][0],
              _C.pageAccents[_currentPage][1],
              _C.bg,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(accent),
              _buildMascot(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _PageWrapper(child: _buildPage0()),
                    _PageWrapper(child: _buildPage1()),
                    _PageWrapper(child: _buildPage2()),
                    _PageWrapper(child: _buildPage3()),
                  ],
                ),
              ),
              _buildBottomBar(accent),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── TOP BAR (back + progress) ────────
  Widget _buildTopBar(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
      child: Row(
        children: [
          // Back button
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                shadowColor: accent.withValues(alpha: 0.3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _currentPage > 0 ? _goBack : null,
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentPage + 1} of 4',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.muted,
                      ),
                    ),
                    Text(
                      '${((_currentPage + 1) / 4 * 100).round()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _progressValue,
                  builder: (_, __) {
                    return Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressValue.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [accent, accent.withValues(alpha: 0.7)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────── FLOATING MASCOT ────────
  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mascotBounce, _mascotWiggle]),
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _mascotOffset.value),
          child: Transform.rotate(
            angle: _mascotWiggle.isAnimating ? _mascotAngle.value : 0,
            child: Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(top: 16, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _C.pageAccents[_currentPage][2]
                        .withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _C.mascots[_currentPage],
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────── BOTTOM BAR (titles + CTA) ────────
  Widget _buildBottomBar(Color accent) {
    final isLast   = _currentPage == 3;
    final isValid  = _isCurrentPageValid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Step dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width:  isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? accent : _C.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // CTA button
          AnimatedBuilder(
            animation: _shimmerAnim,
            builder: (_, child) {
              return GestureDetector(
                onTap: isValid ? _goNext : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isValid
                        ? LinearGradient(
                            begin: Alignment(_shimmerAnim.value - 1, 0),
                            end:   Alignment(_shimmerAnim.value + 1, 0),
                            colors: [
                              accent,
                              accent.withValues(alpha: 0.85),
                              Colors.white.withValues(alpha: 0.25),
                              accent.withValues(alpha: 0.85),
                              accent,
                            ],
                            stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                          )
                        : LinearGradient(
                            colors: [
                              _C.muted.withValues(alpha: 0.2),
                              _C.muted.withValues(alpha: 0.15),
                            ],
                          ),
                    boxShadow: isValid
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLast ? 'Let\'s Go! 🚀' : 'Next',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _isCurrentPageValid
                        ? _C.white
                        : _C.muted.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: _isCurrentPageValid
                        ? _C.white
                        : _C.muted.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ],
              ],
            ),
          ),
          // Login link — only on the first page
          if (_currentPage == 0) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: Text(
                'Already have an account? Login',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.muted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  PAGE 0 — Child Name
  // ═══════════════════════════════════════════
  Widget _buildPage0() {
    return _PageContent(
      title: _C.pageTitles[0],
      subtitle: _C.pageSubtitles[0],
      child: _EduranceTextField(
        controller: _nameController,
        hint: 'My name is…',
        icon: Icons.auto_awesome_rounded,
        accent: _C.yellow,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.name,
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  PAGE 1 — Gender Selector
  // ═══════════════════════════════════════════
  Widget _buildPage1() {
    const options = [
      ('Boy',  '🧒', _C.blue),
      ('Girl', '👧', _C.coral),
    ];
    return _PageContent(
      title: _C.pageTitles[1],
      subtitle: _C.pageSubtitles[1],
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: options.map((opt) {
          final (label, emoji, color) = opt;
          final isSelected = _gender == label;
          return _GenderPill(
            label: label,
            emoji: emoji,
            color: color,
            isSelected: isSelected,
            onTap: () {
                setState(() => _gender = label);
                ref.read(signupProvider.notifier).updateGender(label);
              },
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  PAGE 2 — Age Stepper + Class Grid
  // ═══════════════════════════════════════════
  Widget _buildPage2() {
    return _PageContent(
      title: _C.pageTitles[2],
      subtitle: _C.pageSubtitles[2],
      child: Column(
        children: [
          // Age stepper
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _C.green.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepperButton(
                  icon: Icons.remove_rounded,
                  onTap: _age > 5
                      ? () {
                          setState(() => _age--);
                          ref.read(signupProvider.notifier).updateAge(_age);
                        }
                      : null,
                  color: _C.green,
                ),
                Column(
                  children: [
                    Text(
                      '$_age',
                      style: GoogleFonts.nunito(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: _C.green,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'years old',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
                _StepperButton(
                  icon: Icons.add_rounded,
                  onTap: _age < 10
                      ? () {
                          setState(() => _age++);
                          ref.read(signupProvider.notifier).updateAge(_age);
                        }
                      : null,
                  color: _C.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Class label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My class',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.dark,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Class grid 1–5
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final gradeNum = i + 1;
              final isSelected = _grade == gradeNum;
              return _ClassChip(
                label: 'Class $gradeNum',
                isSelected: isSelected,
                color: _C.green,
                onTap: () {
                    setState(() => _grade = gradeNum);
                    ref.read(signupProvider.notifier).updateClassLevel(gradeNum);
                  },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  PAGE 3 — Parent Mobile
  // ═══════════════════════════════════════════
  Widget _buildPage3() {
    return _PageContent(
      title: _C.pageTitles[3],
      subtitle: _C.pageSubtitles[3],
      child: Column(
        children: [
          _EduranceTextField(
            controller: _mobileController,
            hint: '10-digit mobile number',
            icon: Icons.phone_android_rounded,
            accent: _C.coral,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.coral.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _C.coral.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_rounded, size: 18, color: _C.coral),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your number is safe with us. We never share it.',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.coral,
                    ),
                  ),
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
//  REUSABLE SUB-WIDGETS
// ─────────────────────────────────────────────

/// Full-page wrapper with scroll so content never overflows on small screens
class _PageWrapper extends StatelessWidget {
  final Widget child;
  const _PageWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
  }
}

/// Consistent page layout — title, subtitle, content
class _PageContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _PageContent({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: _C.dark,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _C.muted,
          ),
        ),
        const SizedBox(height: 28),
        child,
      ],
    );
  }
}

/// Custom branded text field
class _EduranceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color accent;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _EduranceTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.accent,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _C.dark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(
            fontSize: 16,
            color: _C.muted,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: accent, size: 24),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 56),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: accent.withValues(alpha: 0.25), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: accent, width: 2.5),
          ),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

/// Gender pill button
class _GenderPill extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderPill({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : _C.muted.withValues(alpha: 0.25),
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : _C.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// +/− stepper button
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: enabled ? color.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Icon(
            icon,
            color: enabled ? color : _C.muted.withValues(alpha: 0.35),
            size: 26,
          ),
        ),
      ),
    );
  }
}

/// Class chip (1–5 grid item)
class _ClassChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ClassChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 270),
        curve: Curves.easeInOutCubic,
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : _C.muted.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : _C.dark,
          ),
        ),
      ),
    );
  }
}

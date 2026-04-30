import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/router/app_router.dart';

// ─────────────────────────────────────────────
//  SHARED BRAND TOKENS  (mirrors signup_screen)
// ─────────────────────────────────────────────
class _C {
  static const yellow  = Color(0xFFFFD94A);
  static const blue    = Color(0xFF4AC8FF);
  static const coral   = Color(0xFFFF6B6B);
  static const green   = Color(0xFF56CF7E);
  static const bg      = Color(0xFFFFF9F0);
  static const dark    = Color(0xFF1A1A2E);
  static const muted   = Color(0xFF9E9EA8);

  // Warm hero gradient for the top hero card
  static const gradientHero = [Color(0xFFFFEA9F), Color(0xFFFFD6D6)];
}

// ─────────────────────────────────────────────
//  LOGIN SCREEN
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Controllers
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus   = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  // ── Animations
  late final AnimationController _heroAnim;
  late final AnimationController _shimmerAnim;
  late final AnimationController _mascotFloat;
  late final AnimationController _formSlide;

  late final Animation<double> _mascotY;
  late final Animation<double> _shimmer;
  late final Animation<double> _formOffset;
  late final Animation<double> _formFade;

  @override
  void initState() {
    super.initState();

    // mascot gentle float
    _mascotFloat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _mascotY = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _mascotFloat, curve: Curves.easeInOut),
    );

    // CTA shimmer
    _shimmerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmer = Tween<double>(begin: -2.0, end: 3.0).animate(
      CurvedAnimation(parent: _shimmerAnim, curve: Curves.easeInOut),
    );

    // hero entrance
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    // form slide-up entrance
    _formSlide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _formOffset = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _formSlide, curve: Curves.easeOutCubic),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formSlide, curve: Curves.easeIn),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formSlide.forward();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _heroAnim.dispose();
    _shimmerAnim.dispose();
    _mascotFloat.dispose();
    _formSlide.dispose();
    super.dispose();
  }

  // Routes the user based on current Supabase session state.
  void _onLogin() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      context.go(AppRoutes.modules);
    } else {
      context.go(AppRoutes.signup);
    }
  }

  void _onSignupTap() => context.go(AppRoutes.signup);

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _buildHeroSection(),
                _buildFormSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────── HERO SECTION ────────
  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnim,
      builder: (_, child) => Opacity(
        opacity: _heroAnim.value,
        child: child,
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _C.gradientHero,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft:  Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
        child: Column(
          children: [
            // ── Brand logo row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Star spark
                _SparkIcon(color: _C.yellow),
                const SizedBox(width: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'edu',
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _C.dark,
                        ),
                      ),
                      TextSpan(
                        text: 'rance',
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _C.coral,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SparkIcon(color: _C.blue),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Learning that feels like play ✨',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.muted,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 24),
            // ── Floating mascot + welcome card
            AnimatedBuilder(
              animation: _mascotY,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _mascotY.value),
                child: child,
              ),
              child: _WelcomeCard(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────── FORM SECTION ────────
  Widget _buildFormSection() {
    return AnimatedBuilder(
      animation: _formSlide,
      builder: (_, child) => Opacity(
        opacity: _formFade.value,
        child: Transform.translate(
          offset: Offset(0, _formOffset.value),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Back to signup
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.signup),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── Heading
            Text(
              'Welcome back! 👋',
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: _C.dark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Continue as existing learner',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.muted,
              ),
            ),
            const SizedBox(height: 28),

            // ── Email field
            _buildFieldLabel('Email'),
            const SizedBox(height: 8),
            _EduranceField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              hint: 'parent@email.com',
              icon: Icons.email_rounded,
              accent: _C.blue,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 20),

            // ── Password field
            _buildFieldLabel('Password'),
            const SizedBox(height: 8),
            _PasswordField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSubmitted: (_) => _onLogin(),
            ),
            const SizedBox(height: 10),

            // ── Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // TODO: forgot password flow
                },
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.coral,
                    decoration: TextDecoration.underline,
                    decorationColor: _C.coral,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── CTA button
            _buildCtaButton(),
            const SizedBox(height: 24),

            // ── Sign up link
            _buildSignupLink(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: _C.dark,
      ),
    );
  }

  // ─────── GRADIENT CTA BUTTON ────────
  Widget _buildCtaButton() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        return GestureDetector(
          onTap: _onLogin,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(_shimmer.value - 1, -0.3),
                end:   Alignment(_shimmer.value + 1,  0.3),
                colors: const [
                  _C.coral,
                  Color(0xFFFF9A3C),
                  _C.yellow,
                  Color(0xFFFF9A3C),
                  _C.coral,
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.coral.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: _C.yellow.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
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

  // ─────── SIGN UP LINK ────────
  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New here?  ',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _C.muted,
          ),
        ),
        GestureDetector(
          onTap: _onSignupTap,
          child: Text(
            'Sign Up',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _C.coral,
              decoration: TextDecoration.underline,
              decorationColor: _C.coral,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  WELCOME CARD (mascot + greeting)
// ─────────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _C.coral.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: _C.yellow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(-4, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Row(
        children: [
          // Mascot bubble
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFEA9F), Color(0xFFFFD6D6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.yellow.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🦁', style: TextStyle(fontSize: 38)),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello again!',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _C.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to keep\nlearning today? 🌟',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          // Decorative stars
          Column(
            children: [
              _MiniStar(color: _C.yellow, size: 18),
              const SizedBox(height: 8),
              _MiniStar(color: _C.blue, size: 12),
              const SizedBox(height: 6),
              _MiniStar(color: _C.green, size: 10),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REUSABLE FIELD WIDGET
// ─────────────────────────────────────────────
class _EduranceField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final Color accent;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _EduranceField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.accent,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<_EduranceField> createState() => _EduranceFieldState();
}

class _EduranceFieldState extends State<_EduranceField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() => setState(() => _focused = widget.focusNode.hasFocus);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _focused
              ? widget.accent
              : widget.accent.withValues(alpha: 0.2),
          width: _focused ? 2.5 : 2.0,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: widget.accent.withValues(alpha: 0.22),
                  blurRadius: 18,
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
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _C.dark,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.nunito(
            fontSize: 15,
            color: _C.muted,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              widget.icon,
              color: _focused ? widget.accent : _C.muted,
              size: 22,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 52, minHeight: 52),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PASSWORD FIELD (with show/hide toggle)
// ─────────────────────────────────────────────
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onSubmitted;

  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.onToggle,
    this.onSubmitted,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField>
    with SingleTickerProviderStateMixin {
  bool _focused = false;
  late final AnimationController _eyeAnim;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    _eyeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _eyeAnim.dispose();
    super.dispose();
  }

  void _onFocusChange() =>
      setState(() => _focused = widget.focusNode.hasFocus);

  void _handleToggle() {
    widget.onToggle();
    if (widget.obscure) {
      _eyeAnim.forward();
    } else {
      _eyeAnim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _focused
              ? _C.coral
              : _C.coral.withValues(alpha: 0.2),
          width: _focused ? 2.5 : 2.0,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: _C.coral.withValues(alpha: 0.2),
                  blurRadius: 18,
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
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscure,
        textInputAction: TextInputAction.done,
        onSubmitted: widget.onSubmitted,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _C.dark,
          letterSpacing: widget.obscure ? 3 : 0,
        ),
        decoration: InputDecoration(
          hintText: 'Enter password',
          hintStyle: GoogleFonts.nunito(
            fontSize: 15,
            color: _C.muted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.lock_rounded,
              color: _focused ? _C.coral : _C.muted,
              size: 22,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 52, minHeight: 52),
          suffixIcon: SizedBox(
            width: 52,
            height: 52,
            child: IconButton(
              onPressed: _handleToggle,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  widget.obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  key: ValueKey(widget.obscure),
                  color: _focused ? _C.coral : _C.muted,
                  size: 22,
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DECORATIVE ATOMS
// ─────────────────────────────────────────────

/// Rotating 6-point spark icon used in the logo row
class _SparkIcon extends StatefulWidget {
  final Color color;
  const _SparkIcon({required this.color});

  @override
  State<_SparkIcon> createState() => _SparkIconState();
}

class _SparkIconState extends State<_SparkIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _spin,
      builder: (_, __) => Transform.rotate(
        angle: _spin.value * 2 * math.pi,
        child: Icon(Icons.auto_awesome_rounded, color: widget.color, size: 18),
      ),
    );
  }
}

/// Small star shape for the welcome card decoration
class _MiniStar extends StatelessWidget {
  final Color color;
  final double size;
  const _MiniStar({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star_rounded, color: color.withValues(alpha: 0.7), size: size);
  }
}

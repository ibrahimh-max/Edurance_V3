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
  static const bg     = Color(0xFFFFF9F0);
  static const dark   = Color(0xFF1A1A2E);
  static const muted  = Color(0xFF9E9EA8);
}

// ─────────────────────────────────────────────
//  HARDCODED LESSON DATA
// ─────────────────────────────────────────────
class _LessonData {
  final String title;
  final String body;
  final String emoji;

  const _LessonData({
    required this.title,
    required this.body,
    required this.emoji,
  });
}

const _lessonTitle   = 'Plants & Their Parts 🌱';
const _lessonSubject = 'Science';
const _subjectEmoji  = '🔬';
const _subjectAccent = _C.green;
const _subjectGradient = [Color(0xFF7DDFAA), Color(0xFF56CF7E)];

const _lessonSections = <_LessonData>[
  _LessonData(
    emoji: '🌿',
    title: 'What is a Plant?',
    body:
        'Plants are living things that grow in soil and make their own food using sunlight! '
        'You can find plants everywhere — in your garden, in the park, even in your kitchen! '
        'Did you know there are over 3,00,000 different types of plants on Earth? 🌍\n\n'
        'Plants are very important because they give us food to eat, air to breathe, and '
        'shade to rest under. Your mango tree, the grass in your garden, the tulsi plant '
        'on your balcony — they are all plants!',
  ),
  _LessonData(
    emoji: '🌱',
    title: 'Parts of a Plant',
    body:
        'Every plant has different parts, and each part has a special job to do:\n\n'
        '🫚  Roots — They hold the plant in the soil and drink up water and minerals. '
        'Roots are like the plant\'s mouth!\n\n'
        '🪵  Stem — The stem carries water from the roots to the leaves. '
        'Think of it as the plant\'s straw!\n\n'
        '🍃  Leaves — Leaves use sunlight, water, and air to make food for the plant. '
        'This is called photosynthesis. Leaves are the plant\'s kitchen!\n\n'
        '🌸  Flowers — Flowers help plants make seeds so new plants can grow. '
        'They are also very pretty and smell wonderful!\n\n'
        '🍎  Fruits — Fruits grow from flowers and carry seeds inside. '
        'We eat many fruits like mangoes, bananas, and apples!',
  ),
  _LessonData(
    emoji: '☀️',
    title: 'How Do Plants Make Food?',
    body:
        'Plants are amazing chefs! They make their own food using three things:\n\n'
        '1. 💧 Water from the soil (absorbed by roots)\n'
        '2. ☀️ Sunlight (captured by leaves)\n'
        '3. 💨 Carbon dioxide from the air (breathed in through tiny holes in leaves)\n\n'
        'This process is called PHOTOSYNTHESIS (say it: fo-to-SIN-the-sis). '
        'As a result, plants also release oxygen — the air we breathe! '
        'So every time you breathe in, you should say thank you to a plant! 🙏',
  ),
  _LessonData(
    emoji: '🌻',
    title: 'Fun Plant Facts!',
    body:
        '⚡ The fastest-growing plant is bamboo — it can grow 91 cm in just ONE day!\n\n'
        '🎋 The world\'s oldest tree is nearly 5,000 years old.\n\n'
        '🌊 Some plants like water lily float on water!\n\n'
        '🍫 Chocolate comes from the cacao plant. So plants give us chocolate too!\n\n'
        '🌵 Cactus plants can survive without water for years in the desert.\n\n'
        'Remember: Plants are our best friends. Take care of them and they will '
        'take care of us! 💚',
  ),
];

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
  final _doubtController  = TextEditingController();
  final _doubtFocus       = FocusNode();
  final _contentScroll    = ScrollController();
  bool _hasDoubtText      = false;
  bool _isSending         = false;

  // Animations
  late final AnimationController _cardEntrance;
  late final Animation<double>   _cardSlide;
  late final Animation<double>   _cardFade;

  late final AnimationController _mascotBounce;
  late final Animation<double>   _mascotY;

  late final AnimationController _sendBtnPulse;
  late final Animation<double>   _sendBtnScale;

  // Chat-style doubt bubbles (local only)
  final _doubts = <String>[];

  @override
  void initState() {
    super.initState();

    _cardEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _cardSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _cardEntrance, curve: Curves.easeOutCubic),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardEntrance, curve: Curves.easeIn),
    );

    _mascotBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _mascotY = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _mascotBounce, curve: Curves.easeInOut),
    );

    _sendBtnPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _sendBtnScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _sendBtnPulse, curve: Curves.easeInOut),
    );

    _doubtController.addListener(() {
      final hasText = _doubtController.text.trim().isNotEmpty;
      if (hasText != _hasDoubtText) setState(() => _hasDoubtText = hasText);
    });

    _doubtFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _doubtController.dispose();
    _doubtFocus.dispose();
    _contentScroll.dispose();
    _cardEntrance.dispose();
    _mascotBounce.dispose();
    _sendBtnPulse.dispose();
    super.dispose();
  }

  void _onAskDoubt(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isSending = true;
      _doubts.add(trimmed);
    });
    _doubtController.clear();
    FocusScope.of(context).unfocus();

    // Simulate AI "thinking" (TODO: wire to Gemini API)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Great question! AI response coming soon…',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: _subjectAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _onBack() {
    // TODO: GoRouter.of(context).pop()
    Navigator.of(context).maybePop();
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ─────── TOP BAR ────────
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _subjectGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 20, 14),
          child: Row(
            children: [
              // Back button
              SizedBox(
                width: 48,
                height: 48,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _onBack,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Subject badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _subjectEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _lessonSubject,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Lesson title
              Expanded(
                child: Text(
                  _lessonTitle,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                        color: _subjectAccent.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🔬', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── BODY ────────
  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;

        return Column(
          children: [
            // Content card — 65%
            SizedBox(
              height: totalH * 0.65,
              child: _buildContentCard(),
            ),
            // Doubt area — 35%
            Expanded(child: _buildDoubtArea()),
          ],
        );
      },
    );
  }

  // ─────── CONTENT CARD (65%) ────────
  Widget _buildContentCard() {
    return AnimatedBuilder(
      animation: _cardEntrance,
      builder: (_, child) => Opacity(
        opacity: _cardFade.value,
        child: Transform.translate(
          offset: Offset(0, _cardSlide.value),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _subjectAccent.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              // Card top strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDCFAEB), Color(0xFFF0FFF5)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _subjectAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _subjectAccent.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '📘 Lesson',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _subjectAccent,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_lessonSections.length} sections',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable lesson content
              Expanded(
                child: ListView.separated(
                  controller: _contentScroll,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  itemCount: _lessonSections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (_, i) => _LessonSection(
                    section: _lessonSections[i],
                    index: i,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────── DOUBT AREA (35%) ────────
  Widget _buildDoubtArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider label
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  height: 2,
                  width: 24,
                  decoration: BoxDecoration(
                    color: _subjectAccent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Got a doubt? Ask away! 🙋',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.muted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: _subjectAccent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recent doubts (scrollable mini feed)
          if (_doubts.isNotEmpty)
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _doubts.length,
                itemBuilder: (_, i) {
                  final idx = _doubts.length - 1 - i;
                  return _DoubtBubble(text: _doubts[idx]);
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '💬',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No doubts yet — ask anything!',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.muted.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Input bar
          _buildDoubtInputBar(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDoubtInputBar() {
    final focused = _doubtFocus.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: focused
              ? _C.coral
              : _C.coral.withValues(alpha: 0.2),
          width: focused ? 2.5 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.coral.withValues(alpha: focused ? 0.18 : 0.06),
            blurRadius: focused ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _doubtController,
              focusNode: _doubtFocus,
              textInputAction: TextInputAction.send,
              onSubmitted: _onAskDoubt,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _C.dark,
              ),
              decoration: InputDecoration(
                hintText: 'Ask a doubt... 💬',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 14,
                  color: _C.muted,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: _hasDoubtText ? () => _onAskDoubt(_doubtController.text) : null,
            child: AnimatedBuilder(
              animation: _sendBtnScale,
              builder: (_, child) => Transform.scale(
                scale: _hasDoubtText ? _sendBtnScale.value : 1.0,
                child: child,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 44,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: _hasDoubtText
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF8F8F), _C.coral],
                        )
                      : LinearGradient(
                          colors: [
                            _C.muted.withValues(alpha: 0.15),
                            _C.muted.withValues(alpha: 0.10),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: _hasDoubtText
                      ? [
                          BoxShadow(
                            color: _C.coral.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: _isSending
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: _hasDoubtText
                            ? Colors.white
                            : _C.muted.withValues(alpha: 0.35),
                        size: 20,
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
//  LESSON SECTION WIDGET
// ─────────────────────────────────────────────
class _LessonSection extends StatelessWidget {
  final _LessonData section;
  final int index;

  const _LessonSection({required this.section, required this.index});

  // Per-section accent colour cycling through brand palette
  static const _sectionColors = [_C.green, _C.blue, _C.yellow, _C.coral];

  @override
  Widget build(BuildContext context) {
    final color = _sectionColors[index % _sectionColors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - v)),
          child: child,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    section.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _C.dark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Accent left border + body text
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    section.body,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3D3D52),
                      height: 1.65,
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
//  DOUBT BUBBLE
// ─────────────────────────────────────────────
class _DoubtBubble extends StatelessWidget {
  final String text;
  const _DoubtBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _C.coral.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.only(
                  topLeft:     Radius.circular(16),
                  topRight:    Radius.circular(16),
                  bottomLeft:  Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: _C.coral.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.dark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _C.coral.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👧', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

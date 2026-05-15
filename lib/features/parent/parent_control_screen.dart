import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../models/parent_dashboard_data.dart';
import '../../services/analytics/dashboard_service.dart';
import '../../features/parent/parent_settings_service.dart';

class _C {
  static const yellow = Color(0xFFFFD94A);
  static const blue = Color(0xFF4AC8FF);
  static const coral = Color(0xFFFF6B6B);
  static const green = Color(0xFF56CF7E);
  static const purple = Color(0xFF9B7BFF);

  static const bg = Color(0xFFFFF9F0);
  static const dark = Color(0xFF1A1A2E);
  static const muted = Color(0xFF9E9EA8);
  static const white = Colors.white;
}

class ParentControlScreen extends StatefulWidget {
  const ParentControlScreen({super.key});

  @override
  State<ParentControlScreen> createState() =>
      _ParentControlScreenState();
}

class _ParentControlScreenState
    extends State<ParentControlScreen> {

  int mathCount = 4;
  int scienceCount = 7;
  int englishCount = 5;
  int hindiCount = 3;
  int evsCount = 2;

  late Future<ParentDashboardData> _dashboardFuture;

  bool _loadingSettings = true;

  @override
  void initState() {
    super.initState();

    _dashboardFuture =
        DashboardService.fetchDashboardData();

    _loadSettings();
  }

  Future<void> _loadSettings() async {

    final settings =
        await ParentSettingsService.fetchSettings();

    if (!mounted) return;

    setState(() {
      mathCount = settings.mathWeekly;
      scienceCount = settings.scienceWeekly;
      englishCount = settings.englishWeekly;
      hindiCount = settings.hindiWeekly;
      evsCount = settings.evsWeekly;

      _loadingSettings = false;
    });
  }

  Future<void> _refreshDashboard() async {

    setState(() {
      _dashboardFuture =
          DashboardService.fetchDashboardData();
    });

    await _loadSettings();
  }

  Future<void> _saveSchedule() async {

    await ParentSettingsService.saveSettings(
      mathWeekly: mathCount,
      scienceWeekly: scienceCount,
      englishWeekly: englishCount,
      hindiWeekly: hindiCount,
      evsWeekly: evsCount,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _C.bg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: _C.yellow,

        title: Text(
          'Parent Dashboard',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: _C.dark,
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: _C.dark,
          onPressed: () =>
              context.go(AppRoutes.modules),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshDashboard,

        child: _loadingSettings
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<ParentDashboardData>(

                future: _dashboardFuture,

                builder: (context, snapshot) {

                  final data =
                      snapshot.data ??
                      ParentDashboardData.empty();

                  return ListView(
                    padding: const EdgeInsets.all(18),

                    children: [

                      // HERO CARD

                      _buildHeroCard(data),

                      const SizedBox(height: 16),

                      // AI INSIGHT CARD

                      _buildInsightCard(data),

                      const SizedBox(height: 18),

                      Text(
                        "Today's Summary",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _C.dark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle_rounded,
                              title: 'Lessons',
                              value:
                                  '${data.lessonsCompletedToday}',
                              color: _C.green,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.timer_rounded,
                              title: 'Minutes',
                              value:
                                  '${data.totalTimeMinutesToday}',
                              color: _C.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.replay_rounded,
                              title: 'Replays',
                              value:
                                  '${data.totalReplayCountToday}',
                              color: _C.coral,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildStatCard(
                              icon:
                                  Icons.psychology_rounded,
                              title: 'Focus Area',
                              value:
                                  _capitalize(
                                    data.weakSubject,
                                  ),
                              color: _C.purple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // RECENT LESSONS

                      if (data.recentLessons.isNotEmpty) ...[

                        Text(
                          'Recent Lessons',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _C.dark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,

                          children:
                              data.recentLessons.map((e) {

                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),

                              decoration: BoxDecoration(
                                color: _C.white,
                                borderRadius:
                                    BorderRadius.circular(
                                        14),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(
                                            alpha: 0.04),
                                    blurRadius: 8,
                                    offset:
                                        const Offset(0, 3),
                                  ),
                                ],
                              ),

                              child: Text(
                                _capitalize(e),

                                style:
                                    GoogleFonts.nunito(
                                  fontWeight:
                                      FontWeight.w800,
                                  color: _C.dark,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // WEEKLY SCHEDULE

                      Text(
                        'Weekly Schedule',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _C.dark,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildScheduleCard(
                        emoji: '🔢',
                        subject: 'Math',
                        value: mathCount,
                        color: _C.blue,

                        onAdd: () {
                          setState(() => mathCount++);
                          _saveSchedule();
                        },

                        onRemove: () {

                          if (mathCount > 0) {
                            setState(() => mathCount--);
                            _saveSchedule();
                          }
                        },
                      ),

                      _buildScheduleCard(
                        emoji: '🧪',
                        subject: 'Science',
                        value: scienceCount,
                        color: _C.green,

                        onAdd: () {
                          setState(() => scienceCount++);
                          _saveSchedule();
                        },

                        onRemove: () {

                          if (scienceCount > 0) {
                            setState(() => scienceCount--);
                            _saveSchedule();
                          }
                        },
                      ),

                      _buildScheduleCard(
                        emoji: '📖',
                        subject: 'English',
                        value: englishCount,
                        color: _C.coral,

                        onAdd: () {
                          setState(() => englishCount++);
                          _saveSchedule();
                        },

                        onRemove: () {

                          if (englishCount > 0) {
                            setState(() => englishCount--);
                            _saveSchedule();
                          }
                        },
                      ),

                      _buildScheduleCard(
                        emoji: '🪔',
                        subject: 'Hindi',
                        value: hindiCount,
                        color: _C.yellow,

                        onAdd: () {
                          setState(() => hindiCount++);
                          _saveSchedule();
                        },

                        onRemove: () {

                          if (hindiCount > 0) {
                            setState(() => hindiCount--);
                            _saveSchedule();
                          }
                        },
                      ),

                      _buildScheduleCard(
                        emoji: '🌱',
                        subject: 'EVS',
                        value: evsCount,
                        color: _C.purple,

                        onAdd: () {
                          setState(() => evsCount++);
                          _saveSchedule();
                        },

                        onRemove: () {

                          if (evsCount > 0) {
                            setState(() => evsCount--);
                            _saveSchedule();
                          }
                        },
                      ),

                      const SizedBox(height: 28),

                      // FOOTER

                      Container(
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: _C.white,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: Text(
                          'Consistent small learning sessions build strong foundations 🌱',

                          textAlign: TextAlign.center,

                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _C.dark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () =>
                            context.go(AppRoutes.modules),

                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _C.green,

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),

                        child: Text(
                          'Back to Learning',

                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeroCard(
    ParentDashboardData data,
  ) {

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD94A),
            Color(0xFFFFC857),
          ],
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            'Good Evening 👋',

            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _C.dark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your child completed ${data.lessonsCompletedToday} lessons today!',

            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.dark.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    ParentDashboardData data,
  ) {

    String insight =
        'A great day of learning today!';

    if (data.lessonsCompletedToday == 0) {

      insight =
          'A short learning session today can help maintain consistency 🌱';
    }

    else if (data.totalReplayCountToday == 0) {

      insight =
          'Replay activity was low today, showing strong understanding ✨';
    }

    else if (data.totalReplayCountToday > 3) {

      insight =
          'Extra revision may help strengthen understanding in ${_capitalize(data.weakSubject)} 📘';
    }

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: _C.blue.withValues(alpha: 0.25),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: _C.blue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.auto_awesome_rounded,
              color: _C.blue,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'AI Learning Insight',

                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _C.dark,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  insight,

                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        _C.dark.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: _C.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
                color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.12),

              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            value,

            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _C.dark,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,

            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String emoji,
    required String subject,
    required int value,
    required Color color,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: _C.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                color.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [

          Text(
            emoji,
            style: const TextStyle(fontSize: 26),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              subject,

              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _C.dark,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.10),

              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Row(
              children: [

                IconButton(
                  onPressed: onRemove,

                  icon: Icon(
                    Icons.remove,
                    color: color,
                  ),
                ),

                Text(
                  value.toString(),

                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _C.dark,
                  ),
                ),

                IconButton(
                  onPressed: onAdd,

                  icon: Icon(
                    Icons.add,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {

    if (value.isEmpty || value == '—') {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1).toLowerCase();
  }
}


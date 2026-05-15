import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/parent/parent_settings_service.dart';


class LessonScheduleService {
  static final _db = Supabase.instance.client;

  /// Returns a map of module-key → available (true/false).
  ///
  /// Module keys match the `subject` values stored in learning_sessions:
  /// 'alphabet', 'numbers', 'colors', 'shapes', 'rhymes'
  ///
  /// A module is unavailable when the child has completed >= the parent's
  /// weekly limit for that subject within the current Mon–Sun week.
  static Future<Map<String, bool>> getWeeklyModuleAvailability() async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) return _allAvailable();

      // ── Current Mon–Sun week range (UTC) ──────────────────────
      final now      = DateTime.now().toUtc();
      final monday   = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime.utc(monday.year, monday.month, monday.day);
      final weekEnd   = weekStart.add(const Duration(days: 7));

      // ── Fetch parent limits ───────────────────────────────────
      final settings = await ParentSettingsService.fetchSettings();

      // Map module-key → weekly limit
      final limits = <String, int>{
        'alphabet': settings.englishWeekly,
        'numbers':  settings.mathWeekly,
        'colors':   settings.scienceWeekly,
        'shapes':   settings.evsWeekly,
        'rhymes':   settings.hindiWeekly,
      };

      // ── Fetch completed sessions this week ────────────────────
      final rows = await _db
          .from('learning_sessions')
          .select('subject, completed')
          .eq('user_id', userId)
          .eq('completed', true)
          .gte('started_at', weekStart.toIso8601String())
          .lt('started_at', weekEnd.toIso8601String());

      debugPrint('LessonScheduleService → ${rows.length} completed sessions this week');

      // Count completions per subject
      final counts = <String, int>{};
      for (final row in rows) {
        final subject = (row['subject'] as String?) ?? '';
        if (subject.isNotEmpty) {
          counts[subject] = (counts[subject] ?? 0) + 1;
        }
      }

      debugPrint('LessonScheduleService → counts: $counts, limits: $limits');

      // Build availability map
      final availability = <String, bool>{};
      for (final entry in limits.entries) {
        final module    = entry.key;
        final limit     = entry.value;
        final completed = counts[module] ?? 0;
        availability[module] = completed < limit;
      }

      return availability;
    } catch (e, stack) {
      debugPrint('LessonScheduleService ERROR: $e');
      debugPrintStack(stackTrace: stack);
      return _allAvailable(); // fail-open: never block lessons on error
    }
  }

  static Map<String, bool> _allAvailable() => {
    'alphabet': true,
    'numbers':  true,
    'colors':   true,
    'shapes':   true,
    'rhymes':   true,
  };
}

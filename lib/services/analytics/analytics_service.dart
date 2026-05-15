import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  static final _db = Supabase.instance.client;

  /// Inserts a new learning_sessions row and returns the generated session id.
  /// Returns null if the user is not authenticated or the insert fails.
  static Future<String?> startSession({
    required String lessonId,
    required String subject,
  }) async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _db
          .from('learning_sessions')
          .insert({
            'user_id':   userId,
            'lesson_id': lessonId,
            'subject':   subject,
          })
          .select('id')
          .single();

      return response['id'] as String?;
    } catch (e) {
      debugPrint('Analytics startSession error: $e');
      return null;
    }
  }

  /// Updates the session row with final score, time, and marks it completed.
  static Future<void> completeSession({
    required String sessionId,
    required int    score,
    required int    timeSpentSeconds,
  }) async {
    try {
      await _db
          .from('learning_sessions')
          .update({
            'score':              score,
            'time_spent_seconds': timeSpentSeconds,
            'completed':          true,
            'completed_at':       DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);
    } catch (e) {
      debugPrint('Analytics completeSession error: $e');
    }
  }

  /// Increments the replays_used counter for the given session by 1.
  static Future<void> incrementReplayCount(String sessionId) async {
    try {
      final row = await _db
          .from('learning_sessions')
          .select('replays_used')
          .eq('id', sessionId)
          .single();

      final current = (row['replays_used'] as num?)?.toInt() ?? 0;

      await _db
          .from('learning_sessions')
          .update({'replays_used': current + 1})
          .eq('id', sessionId);
    } catch (e) {
      debugPrint('Analytics incrementReplayCount error: $e');
    }
  }
}

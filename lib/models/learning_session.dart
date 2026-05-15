class LearningSession {
  final String  id;
  final String  userId;
  final String  lessonId;
  final String  subject;
  final int     score;
  final int     hintsUsed;
  final int     replaysUsed;
  final int     timeSpentSeconds;
  final bool    completed;
  final DateTime startedAt;
  final DateTime? completedAt;

  const LearningSession({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.subject,
    required this.score,
    required this.hintsUsed,
    required this.replaysUsed,
    required this.timeSpentSeconds,
    required this.completed,
    required this.startedAt,
    this.completedAt,
  });

  factory LearningSession.fromMap(Map<String, dynamic> map) {
    return LearningSession(
      id:               map['id'] as String,
      userId:           map['user_id'] as String,
      lessonId:         map['lesson_id'] as String,
      subject:          map['subject'] as String,
      score:            (map['score'] as num?)?.toInt() ?? 0,
      hintsUsed:        (map['hints_used'] as num?)?.toInt() ?? 0,
      replaysUsed:      (map['replays_used'] as num?)?.toInt() ?? 0,
      timeSpentSeconds: (map['time_spent_seconds'] as num?)?.toInt() ?? 0,
      completed:        (map['completed'] as bool?) ?? false,
      startedAt:        DateTime.parse(map['started_at'] as String),
      completedAt:      map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':                 id,
      'user_id':            userId,
      'lesson_id':          lessonId,
      'subject':            subject,
      'score':              score,
      'hints_used':         hintsUsed,
      'replays_used':       replaysUsed,
      'time_spent_seconds': timeSpentSeconds,
      'completed':          completed,
      'started_at':         startedAt.toIso8601String(),
      if (completedAt != null)
        'completed_at': completedAt!.toIso8601String(),
    };
  }
}

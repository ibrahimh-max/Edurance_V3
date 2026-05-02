class Lesson {
  final String id;
  final String module;
  final String title;
  final String emoji;
  final String prompt;
  final List<String> options;

  const Lesson({
    required this.id,
    required this.module,
    required this.title,
    required this.emoji,
    required this.prompt,
    required this.options,
  });
}

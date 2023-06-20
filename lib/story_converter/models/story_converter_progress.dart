part of story_converter;

/// {@template storyConverterProgress}
/// Результатов возврата для прогресса выполнения конвертации
/// {@endtemplate}
class StoryConverterProgress extends StoryConverterResponseBase {
  /// Путь до сохраняемого файла
  final String path;

  /// Номер фрагмента
  final int fragment;

  /// Путь до исходного файла
  final String source;

  /// Проценты
  final int percent;

  /// {@macro storyConverterProgress}
  StoryConverterProgress({
    required this.path,
    required this.fragment,
    required this.percent,
    required this.source,
    required super.sessionId,
  });
}

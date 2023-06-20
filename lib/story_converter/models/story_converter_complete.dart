part of story_converter;

/// {@template storyConverterComplete}
/// Результатов возврата завершения выполнения конвертации
/// {@endtemplate}
class StoryConverterComplete extends StoryConverterResponseBase {
  /// Путь до сохраняемого файла
  final String path;

  /// Номер фрагмента
  final int fragment;

  /// {@macro storyConverterComplete}
  StoryConverterComplete({
    required this.path,
    required this.fragment,
    super.sessionId,
    super.sessionReturnCode,
    required super.sessionDuration,
  });
}

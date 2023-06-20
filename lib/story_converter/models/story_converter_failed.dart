part of story_converter;

/// {@template storyConverterFailed}
/// Результатов возврата при ошибки выполнения конвертации
/// {@endtemplate}
class StoryConverterFailed extends StoryConverterResponseBase {
  /// Ошибка выполнения конвертации
  final Object? error;

  /// {@macro storyConverterFailed}
  StoryConverterFailed({
    required this.error,
    super.sessionId,
    super.sessionReturnCode,
    super.sessionDuration,
  });
}

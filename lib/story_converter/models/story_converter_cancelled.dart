part of story_converter;

/// {@template storyConverterCancelled}
/// Результатов возврата при отмене выполнения конвертации
/// {@endtemplate}
class StoryConverterCancelled extends StoryConverterResponseBase {
  final String source;

  /// {@macro storyConverterCancelled}
  StoryConverterCancelled({
    required this.source,
    super.sessionId,
    super.sessionReturnCode,
    required super.sessionDuration,
  });
}

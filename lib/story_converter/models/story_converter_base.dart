part of story_converter;

/// {@template storyConverterResponseBase}
/// Базовый класс для результатов возврата методов конвертора
/// {@endtemplate}
abstract class StoryConverterResponseBase {
  /// Id сессии конвертации
  final int? sessionId;

  /// Код завершённой операции конвертирования
  final ReturnCode? sessionReturnCode;

  /// Длительность выполнения операции
  final int? sessionDuration;

  /// {@macro storyConverterResponseBase}
  const StoryConverterResponseBase({
    this.sessionId,
    this.sessionReturnCode,
    this.sessionDuration,
  });
}

part of story_converter;

/// {@template storyConverterInitial}
/// Результатов возврата при инициализации выполнения конвертации
/// {@endtemplate}
class StoryConverterInitial extends StoryConverterResponseBase {
  final String source;
  final int fragmentCount;

  /// {@macro storyConverterInitial}
  StoryConverterInitial({
    required this.source,
    required this.fragmentCount,
  });
}

part of story_converter;

const defaultMaxDuration = Duration(seconds: 60);
const defaultChunkDuration = Duration(seconds: 15);
const defaultAspectRatio = 16 / 9;

/// {@template storyConverterConfiguration}
/// Конфигурация для нарезки видео
/// {@endtemplate}
class StoryConverterConfiguration {
  /// Локальный путь до файла
  final String source;

  /// Максимальная длительность видео
  final Duration maxDuration;

  /// Длительность фрагмента
  final Duration fragmentDuration;

  /// Соотношение сторон итогового видео
  final double aspectRatio;

  /// {@macro storyConverterConfiguration}
  const StoryConverterConfiguration({
    required this.source,
    this.maxDuration = defaultMaxDuration,
    this.fragmentDuration = defaultChunkDuration,
    this.aspectRatio = defaultAspectRatio,
  });
}

part of story_converter;

/// {@template fragmentInterval}
/// Интервал для фрагментов
/// {@endtemplate}
class FragmentInterval {
  final int start;
  final Duration duration;

  /// {@macro fragmentInterval}
  const FragmentInterval({
    required this.start,
    required this.duration,
  });
}

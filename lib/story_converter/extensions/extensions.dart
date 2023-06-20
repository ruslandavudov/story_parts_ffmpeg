part of story_converter;

/// Расширения для **[Duration]**.
extension DurationToHmsString on Duration {
  /// Получение строки из **[Duration]** вида "HH:mm:ss"
  String get hms => [
    inHours.remainder(24),
    inMinutes.remainder(60),
    inSeconds.remainder(60)
  ].map((seg) {
    return seg.toString().padLeft(2, '0');
  }).join(':');
}

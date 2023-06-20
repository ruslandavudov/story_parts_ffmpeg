part of story_converter;

/// Путь к каталогу, в который приложение может поместить данные, сгенерированные пользователем
Future<Directory> get documentsDirectory => getTemporaryDirectory();

/// Получения разрешения медиа-файла из **[mediaInformation]**
Size getSizeFromMediaInformation(Map<dynamic, dynamic>? mediaInformation) {
  int? width;
  int? height;
  if (mediaInformation is Map && mediaInformation['streams'] != null) {
    final streamsData = mediaInformation['streams'];
    if (streamsData is List && streamsData.isNotEmpty) {
      if (streamsData[0] is Map<dynamic, dynamic>) {
        final stream = streamsData[0] as Map<dynamic, dynamic>;
        if (stream['width'] != null) {
          width = int.tryParse(stream['width']?.toString() ?? '');
        }
        if (stream['height'] != null) {
          height = int.tryParse(stream['height']?.toString() ?? '');
        }
      }
    }
  }

  if (width != null && height != null) {
    return Size(width.toDouble(), height.toDouble());
  }

  return Size.zero;
}

/// Получение длительности из **[mediaInformation]**
Duration getDurationFromMediaInformation(
  Map<dynamic, dynamic>? mediaInformation,
) {
  var duration = Duration.zero;
  if (mediaInformation is Map && mediaInformation['streams'] != null) {
    final streamsData = mediaInformation['streams'];
    if (streamsData is List && streamsData.isNotEmpty) {
      if (streamsData[0] is Map<dynamic, dynamic>) {
        final stream = streamsData[0] as Map<dynamic, dynamic>;
        if (stream['duration'] != null) {
          final seconds = double.tryParse(stream['duration']?.toString() ?? '');
          if (seconds != null) {
            duration = Duration(microseconds: (seconds * 1000000).toInt());
          }
        }
      }
    }
  }

  return duration;
}

String now() {
  final now = DateTime.now();
  return "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}.${now.millisecond}";
}

void ffPrint(String text) {
  final pattern = RegExp('.{1,900}');
  final nowString = now();
  pattern
      .allMatches(text)
      .forEach((match) => debugPrint("$nowString - ${match.group(0)!}"));
}
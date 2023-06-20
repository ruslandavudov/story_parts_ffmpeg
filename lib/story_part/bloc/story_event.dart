part of story_part;

abstract class StoryBaseEvent {
  const StoryBaseEvent();
}

class StoryOpened extends StoryBaseEvent {
  final String source;

  const StoryOpened({required this.source});
}

class StoryConvertStart extends StoryBaseEvent {
  /// Локальный путь до файла
  final String source;

  /// Максимальная длительность видео
  final Duration maxDuration;

  /// Длительность фрагмента
  final Duration chunkDuration;

  const StoryConvertStart({
    required this.source,
    this.maxDuration = defaultMaxDuration,
    this.chunkDuration = defaultChunkDuration,
  });
}

class StoryConvertCancel extends StoryBaseEvent {

  const StoryConvertCancel();
}

class StoryClear extends StoryBaseEvent {}

class StoryOnInitial extends StoryBaseEvent {
  final StoryConverterInitial result;

  const StoryOnInitial({required this.result});
}

class StoryOnCompleted extends StoryBaseEvent {
  final StoryConverterComplete result;

  const StoryOnCompleted({required this.result});
}

class StoryOnProgress extends StoryBaseEvent {
  final StoryConverterProgress result;

  const StoryOnProgress({required this.result});
}

class StoryOnFailed extends StoryBaseEvent {
  final StoryConverterFailed result;

  const StoryOnFailed({required this.result});
}

class StoryOnCancelled extends StoryBaseEvent {
  final StoryConverterCancelled result;

  const StoryOnCancelled({required this.result});
}

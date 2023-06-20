part of story_part;

class VideoData with EquatableMixin {
  final String path;
  final VideoPlayerController controller;

  const VideoData({
    required this.path,
    required this.controller,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoData &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          controller == other.controller;

  @override
  int get hashCode => Object.hash(path, controller.hashCode);

  @override
  List<Object?> get props => [path, controller];
}

class StoryState with EquatableMixin {
  final VideoData? source;
  final int chunksCount;
  final List<VideoData?> data;
  final bool isProgress;
  final Object? error;

  const StoryState({
    this.source,
    this.chunksCount = 0,
    this.data = const [],
    this.isProgress = false,
    this.error,
  });

  /// Короткая запись для получения стейта с isProgress == true, с удалением ошибки
  StoryState get progressState =>
      copyWith(isProgress: true).copyWithNull(error: null);

  /// Короткая запись для получения стейта с ошибкой выполенния
  StoryState errorState(Object? error) =>
      copyWith(isProgress: false).copyWithNull(error: error);

  StoryState copyWith({
    int? chunksCount,
    List<VideoData?>? data,
    bool? isProgress,
  }) =>
      StoryState(
        source: source,
        chunksCount: chunksCount ?? this.chunksCount,
        data: data ?? this.data,
        isProgress: isProgress ?? this.isProgress,
        error: error,
      );

  StoryState copyWithNull({
    Object? source = CopyWithExclude,
    Object? error = CopyWithExclude,
  }) =>
      StoryState(
        source: source is VideoData ? source : this.source,
        chunksCount: chunksCount,
        data: data,
        isProgress: isProgress,
        error: error == CopyWithExclude ? this.error : error,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryState &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          chunksCount == other.chunksCount &&
          isProgress == other.isProgress &&
          error == other.error &&
          listEquals(data, other.data);

  @override
  int get hashCode => Object.hash(
        source,
        chunksCount,
        isProgress,
        error.hashCode,
        data.fold(0, (p, c) => p.hashCode ^ c.hashCode),
      );

  @override
  List<Object?> get props =>
      [source, chunksCount, data, isProgress, error];
}

class CopyWithExclude {
  const CopyWithExclude();
}

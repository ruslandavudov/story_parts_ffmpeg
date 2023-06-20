part of story_converter;

/// {@template storyConverterRepository}
/// Репозиторий для работы с конвертацией "историй" через **[FFmpegKit]**
/// {@endtemplate}
class StoryConverterRepository {
  final _onInitialStreamController = PublishSubject<StoryConverterInitial>();
  final _onCompletedStreamController = PublishSubject<StoryConverterComplete>();
  final _onProgressStreamController = PublishSubject<StoryConverterProgress>();
  final _onFailedStreamController = PublishSubject<StoryConverterFailed>();
  final _onCancelledStreamController =
      PublishSubject<StoryConverterCancelled>();

  final _onMediaInformationFetchedController =
      PublishSubject<_MediaInformationData>();

  /// Стрим для получения **[StoryConverterComplete]** при завершение процесса конвертации
  Stream<StoryConverterComplete> get onCompleted =>
      _onCompletedStreamController.stream;

  /// Стрим для получения **[StoryConverterProgress]** при выполнение процесса конвертации
  Stream<StoryConverterProgress> get onProgress =>
      _onProgressStreamController.stream;

  /// Стрим для получения **[StoryConverterFailed]** при ошибки выполнения процесса конвертации
  Stream<StoryConverterFailed> get onFailed => _onFailedStreamController.stream;

  /// Стрим для получения **[StoryConverterCancelled]** при отмене процесса конвертации
  Stream<StoryConverterCancelled> get onCancelled =>
      _onCancelledStreamController.stream;

  /// Стрим для получения **[StoryConverterInitial]** при инициализации процесса конвертации
  Stream<StoryConverterInitial> get onInitial =>
      _onInitialStreamController.stream;

  /// Слушатель для события получения медиа-информации
  StreamSubscription<_MediaInformationData>?
      _onMediaInformationFetchedSubscription;

  /// {@macro processingRepository}
  StoryConverterRepository() {
    _onMediaInformationFetchedSubscription =
        _onMediaInformationFetchedController.stream
            .listen(_onMediaInformationFetched);
  }

  /// Обработка полученной медиа-информации и запуск конвертации
  Future<void> _onMediaInformationFetched(_MediaInformationData data) async {
    if (data.mediaInformation?.isNotEmpty ?? false) {
      final path = (await documentsDirectory).path;
      final basename = p.basenameWithoutExtension(data.configuration.source);
      final size = getSizeFromMediaInformation(data.mediaInformation);
      var videoDuration = getDurationFromMediaInformation(data.mediaInformation);

      final maxDuration = data.configuration.maxDuration;
      final fragmentDuration = data.configuration.fragmentDuration;

      if (videoDuration > maxDuration) {
        videoDuration = maxDuration;
      }

      final width = size.width.toInt();
      final height = size.height.toInt();

      final aspectRatio = data.configuration.aspectRatio;
      final positionY = ((width * aspectRatio) / 2 - height / 2).toInt();

      final intervals =
          _getFragmentIntervals(videoDuration: videoDuration, fragmentDuration: fragmentDuration);

      _onInitialStreamController.add(
        StoryConverterInitial(
          source: data.configuration.source,
          fragmentCount: intervals.length,
        ),
      );
      for (var i = 0; i < intervals.length; i++) {
        final intervalStart = Duration(microseconds: intervals[i].start);
        final intervalDuration = intervals[i].duration;
        final outPath = '$path/${basename}_$i.mp4';
        final command = '-hide_banner -f lavfi'
            ' -i color=black:s=${width}x${(width * aspectRatio).toInt()} '
            ' -i "${data.configuration.source}" -ss ${intervalStart.hms} -t "${intervalDuration.hms}" '
            ' -filter_complex '
            ' "[1:v]setpts=PTS-STARTPTS,scale=$width:-1,setsar=1:1[media1], '
            ' [0:v][media1]overlay=x=0:y=$positionY:shortest=1"'
            ' -fps_mode auto  -y "$outPath" ';
        await _executeAsync(
          source: data.configuration.source,
          command: command,
          duration: videoDuration,
          path: outPath,
          fragment: i,
        );
      }
    } else {
      _onFailedStreamController.add(
        StoryConverterFailed(error: MediaInformationException()),
      );
    }
  }

  List<FragmentInterval> _getFragmentIntervals({
    required Duration videoDuration,
    required Duration fragmentDuration,
  }) {
    final intervals = <FragmentInterval>[];
    var elapsedTime = Duration.zero;

    do {
      Duration duration;
      final delta = videoDuration - (elapsedTime + fragmentDuration);
      if (delta <= fragmentDuration ~/ 3) {
        duration = videoDuration - elapsedTime;
      } else {
        duration = fragmentDuration;
      }
      intervals.add(
        FragmentInterval(start: elapsedTime.inMicroseconds, duration: duration),
      );

      elapsedTime += duration;
    } while (elapsedTime < videoDuration);

    return intervals;
  }

  /// Запуск выполнения построенной команды с обратными вызовами
  Future<FutureOr<void>> _executeAsync({
    required String source,
    required String command,
    required Duration duration,
    required String path,
    required int fragment,
  }) async {
    debugPrint(command);

    await FFmpegKit.executeAsync(
      command,
      (session) async {
        final returnCode = await session.getReturnCode();
        final sessionDuration = await session.getDuration();
        final sessionId = session.getSessionId();

        if (ReturnCode.isSuccess(returnCode)) {
          final storyConverterComplete = StoryConverterComplete(
            sessionId: sessionId,
            sessionReturnCode: returnCode,
            sessionDuration: sessionDuration,
            path: path,
            fragment: fragment,
          );
          _onCompletedStreamController.add(storyConverterComplete);
        } else if (ReturnCode.isCancel(returnCode)) {
          final result = StoryConverterCancelled(
            source: source,
            sessionId: sessionId,
            sessionReturnCode: returnCode,
            sessionDuration: sessionDuration,
          );
          _onCancelledStreamController.add(result);
        } else {
          final failStackTrace = await session.getFailStackTrace();
          final result = StoryConverterFailed(
            sessionId: sessionId,
            sessionReturnCode: returnCode,
            sessionDuration: sessionDuration,
            error: failStackTrace,
          );
          _onFailedStreamController.add(result);
        }
      },
      (log) => ffPrint(log.getMessage()),
      (statistics) {
        final sessionId = statistics.getSessionId();
        final timeInMilliseconds = statistics.getTime();
        final totalVideoDuration = duration.inMilliseconds;
        final percent = (timeInMilliseconds * 100) ~/ totalVideoDuration;

        final storyConverterProgress = StoryConverterProgress(
          source: source,
          sessionId: sessionId,
          percent: percent,
          path: path,
          fragment: fragment,
        );
        _onProgressStreamController.add(storyConverterProgress);
      },
    );
  }

  /// Запуск процесса конвертации и разбитие на части видео
  Future<void> convert({
    required StoryConverterConfiguration configuration,
  }) async {
    await getMediaInformationAsync(configuration);
  }

  /// Получение медиа информации по медиа-файлу
  Future<void> getMediaInformationAsync(
    StoryConverterConfiguration configuration,
  ) async {
    await FFprobeKit.getMediaInformationAsync(configuration.source,
        (session) async {
      final information = session.getMediaInformation();
      final mediaInformation = information?.getAllProperties();
      _onMediaInformationFetchedController.add(
        _MediaInformationData(
          mediaInformation: mediaInformation,
          configuration: configuration,
        ),
      );
    });
  }

  /// Отменяет сессию конвертации с **[sessionId]**
  /// Если **[sessionId] == null** отменяет все сессии конвертации
  Future<void> cancel([int? sessionId]) => FFmpegKit.cancel(sessionId);

  /// Получение списка всех сессий конвертации
  Future<List<FFmpegSession>> listSessions() => FFmpegKit.listSessions();

  Future<void> dispose() async {
    await _onMediaInformationFetchedSubscription?.cancel();
    await _onInitialStreamController.close();
    await _onCompletedStreamController.close();
    await _onCancelledStreamController.close();
    await _onFailedStreamController.close();
    await _onProgressStreamController.close();
    await _onMediaInformationFetchedController.close();
  }
}

/// {@template _mediaInformationData}
/// Промежуточный класс, содержащий данные по медиа-информации файла
/// {@endtemplate}
class _MediaInformationData {
  /// Медиа информация
  final Map<dynamic, dynamic>? mediaInformation;

  /// Конфигурация для нарезки видео
  final StoryConverterConfiguration configuration;

  /// {@macro _mediaInformationData}
  const _MediaInformationData({
    required this.mediaInformation,
    required this.configuration,
  });
}

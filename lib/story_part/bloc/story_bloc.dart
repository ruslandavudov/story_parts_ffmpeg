part of story_part;

class StoryBloc extends Bloc<StoryBaseEvent, StoryState> {
  final StoryConverterRepository repository;

  late StreamSubscription<StoryConverterInitial>
      _onStoryConverterInitialSubscription;
  late StreamSubscription<StoryConverterComplete>
      _onStoryConverterCompleteSubscription;
  late StreamSubscription<StoryConverterProgress>
      _onStoryConverterProgressSubscription;
  late StreamSubscription<StoryConverterFailed>
      _onStoryConverterFailedSubscription;
  late StreamSubscription<StoryConverterCancelled>
      _onStoryConverterCancelledSubscription;

  StoryBloc({
    required this.repository,
  }) : super(const StoryState()) {
    _onStoryConverterInitialSubscription =
        repository.onInitial.listen((e) => add(StoryOnInitial(result: e)));
    _onStoryConverterCompleteSubscription =
        repository.onCompleted.listen((e) => add(StoryOnCompleted(result: e)));
    _onStoryConverterProgressSubscription =
        repository.onProgress.listen((e) => add(StoryOnProgress(result: e)));
    _onStoryConverterFailedSubscription =
        repository.onFailed.listen((e) => add(StoryOnFailed(result: e)));
    _onStoryConverterCancelledSubscription =
        repository.onCancelled.listen((e) => add(StoryOnCancelled(result: e)));

    on(_onStoryOpened);
    on(_onStoryClear);

    on(_onStoryConvertStart);
    on(_onStoryConvertCancel);

    on(_onInitial);
    on(_onCompleted);
    on<StoryOnProgress>(
      _onProgress,
      transformer: sequential(),
    );
    on(_onFailed);
    on(_onCancelled);
  }

  Future<void> _onStoryConvertStart(
    StoryConvertStart event,
    Emitter<StoryState> emit,
  ) async {
    emit(state.progressState);
    final configuration = StoryConverterConfiguration(
      source: event.source,
      maxDuration: event.maxDuration,
      fragmentDuration: event.chunkDuration,
    );
    await _freeControllers(emit);
    await repository.convert(configuration: configuration);
  }

  Future<void> _onStoryConvertCancel(
    StoryConvertCancel event,
    Emitter<StoryState> emit,
  ) =>
      repository.cancel();

  void _onInitial(
    StoryOnInitial event,
    Emitter<StoryState> emit,
  ) =>
      emit(state.copyWith(chunksCount: event.result.fragmentCount));

  Future<void> _onCompleted(
    StoryOnCompleted event,
    Emitter<StoryState> emit,
  ) async {
    final path = event.result.path;
    final data = List<VideoData?>.from(state.data);
    final index = data.indexWhere((e) => e?.path == path);
    if (index < 0) {
      try {
        final videoData = await _fetchVideoData(path);
        data.add(videoData);
      } catch (e) {
        emit(state.errorState(e));
      }

      final isProgress = state.chunksCount != event.result.fragment + 1;

      emit(
        state
            .copyWith(data: data, isProgress: isProgress)
            .copyWithNull(error: null),
      );
    }
  }

  void _onProgress(
    StoryOnProgress event,
    Emitter<StoryState> emit,
  ) {
    //todo: нечто что обрабатывает событие прогресса
  }

  void _onFailed(
    StoryOnFailed event,
    Emitter<StoryState> emit,
  ) =>
      emit(state.errorState(event.result.error));

  void _onCancelled(
    StoryOnCancelled event,
    Emitter<StoryState> emit,
  ) =>
      emit(state.copyWith(isProgress: false));

  FutureOr<void> _onStoryOpened(
    StoryOpened event,
    Emitter<StoryState> emit,
  ) async {
    try {
      emit(state.progressState);
      final sourceData = await _fetchVideoData(event.source);
      emit(
        state.copyWith(isProgress: false).copyWithNull(source: sourceData),
      );
    } catch (e) {
      emit(state.errorState(e));
    }
  }

  Future<VideoData?> _fetchVideoData(String source) async {
    final file = File(source);
    final fileExists = await file.exists();

    if (fileExists) {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      await controller.setLooping(true);
      final videoData = VideoData(
        path: source,
        controller: controller,
      );

      return videoData;
    }

    return null;
  }

  Future<FutureOr<void>> _onStoryClear(
    StoryClear event,
    Emitter<StoryState> emit,
  ) async {
    await state.source?.controller.dispose();
    await _freeControllers(emit);
  }

  Future<void> _freeControllers(Emitter<StoryState> emit) async {
    for (final data in state.data) {
      await data?.controller.dispose();
    }
    emit(state.copyWith(data: []));
  }

  @override
  Future<void> close() async {
    await _onStoryConverterInitialSubscription.cancel();
    await _onStoryConverterCompleteSubscription.cancel();
    await _onStoryConverterProgressSubscription.cancel();
    await _onStoryConverterFailedSubscription.cancel();
    await _onStoryConverterCancelledSubscription.cancel();

    await super.close();
  }
}

extension StoryBlocBuildContextX on BuildContext {
  /// Инстанс [StoryBloc] из контекста.
  StoryBloc get storyBloc => read<StoryBloc>();
}

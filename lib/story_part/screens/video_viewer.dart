part of story_part;

class VideoViewer extends StatefulWidget {
  const VideoViewer({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  bool _isPlayed = false;
  String _timeCode = '';

  @override
  void initState() {
    widget.controller.addListener(_videoControllerListener);

    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      widget.controller.removeListener(_videoControllerListener);
    }

    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _videoControllerListener() {
    setState(() {
      _timeCode = widget.controller.value.position.hms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
          setState(() {
            _isPlayed = false;
          });
        } else {
          widget.controller.play();
          setState(() {
            _isPlayed = true;
          });
        }
      },
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: VideoPlayer(widget.controller),
          ),
          if (!_isPlayed)
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 40)
          else
            const Icon(Icons.pause, color: Colors.grey, size: 40),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _timeCode,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

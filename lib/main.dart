import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_parts_ffmpeg/story_converter/converter.dart';
import 'package:story_parts_ffmpeg/story_part/story_part.dart';

void main() {
  runApp(const MyApp());
}

const localPath =
    // '/Users/steel/Library/Developer/CoreSimulator/Devices/DC67C61B-234E-4BA7-A0FD-FC8AD1555AE7/data/Containers/Data/Application/499FB6F9-90F4-4451-B827-DD94E29D9AFD/tmp/.video/1685704954.000000_IMG_0007.MP4';
// '/Users/steel/Library/Developer/CoreSimulator/Devices/DC67C61B-234E-4BA7-A0FD-FC8AD1555AE7/data/Containers/Data/Application/4E69D5CE-2B7C-4C89-8359-C31A53603C38/tmp/.video/1687294737.783441_IMG_0014.MP4';
'/Users/steel/Library/Developer/CoreSimulator/Devices/DC67C61B-234E-4BA7-A0FD-FC8AD1555AE7/data/Containers/Data/Application/4E69D5CE-2B7C-4C89-8359-C31A53603C38/tmp/.video/1686769283.920606_IMG_0013.MP4';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'story_parts_ffmpeg',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => StoryBloc(
          repository: StoryConverterRepository(),
        )..add(const StoryOpened(source: localPath)),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: const RoundedRectangleBorder(
        side: BorderSide(),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('story_parts_ffmpeg'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<StoryBloc, StoryState>(
          builder: (context, state) {
            Widget child;

            if (state.data.isEmpty &&
                !state.isProgress &&
                state.error == null) {
              child = const Center(child: Text('пусто...'));
            } else {
              if (state.isProgress) {
                child = const Center(child: CircularProgressIndicator());
              } else if (state.error != null) {
                child = const Center(child: Text('Ошибка ¯\\_(ツ)_/¯'));
              } else {
                final data = state.data;
                child = PageView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    Widget child;
                    final videoData = data[index];
                    if (videoData != null) {
                      child = SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: VideoViewer(controller: videoData.controller),
                      );
                    } else {
                      child = const Center(
                        child: Text(
                          'не получилось\n ¯\\_(ツ)_/¯',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: child,
                    );
                  },
                );
              }
            }

            return Column(
              children: [
                SizedBox(
                  height: 100,
                  child: state.source != null
                      ? VideoViewer(controller: state.source!.controller)
                      : null,
                ),
                Row(
                  children: [
                    TextButton(
                      style: buttonStyle,
                      onPressed: !state.isProgress
                          ? () {
                              context.storyBloc.add(
                                const StoryConvertStart(source: localPath),
                              );
                            }
                          : null,
                      child: const Text('start'),
                    ),
                    TextButton(
                      style: buttonStyle,
                      onPressed: () =>
                          context.storyBloc.add(const StoryConvertCancel()),
                      child: const Text('cancel'),
                    ),
                  ],
                ),
                Text('count: ${state.data.length}'),
                SizedBox(
                  height: 300,
                  child: child,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:ffmpeg_timeshift/ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FFMPEG Kit Timeshift & Overlay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String state = "not done rendering";
  File? file;

  void _startFfmpeg() async {
    final videoFile = await Ffmpeg().startOverlayProcess();
    setState(() {
      state = "done rendering";
      file = videoFile;
      controller = VideoPlayerController.file(videoFile);
    });
    await controller!.initialize();
  }

  VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Video(file: file, controller: controller),
            Text(
              state,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: _startFfmpeg,
              child: const Text("start ffmpeg render"),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ],
        ),
      ),
    );
  }
}

class Video extends StatelessWidget {
  const Video({super.key, this.file, this.controller});

  final File? file;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    controller?.play();
    if (file != null) {
      return Column(
        children: [
          SizedBox(height: 240, child: VideoPlayer(controller!)),
          TextButton(
            onPressed: () {
              controller?.initialize().then((_) => controller?.play());
            },
            child: const Text("start video over"),
          )
        ],
      );
    }
    return const SizedBox();
  }
}

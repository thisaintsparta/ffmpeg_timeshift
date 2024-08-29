import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Ffmpeg {
  Future<File> startOverlayProcess() async {
    final completer = Completer<File>();
    FFmpegKitConfig.enableLogCallback((log) {
      final message = log.getMessage();
      print('FFmpegKit: $message');
    });
    final vidData = await rootBundle.load('assets/example.mp4');
    final vid2Data = await rootBundle.load('assets/example2.mp4');
    final picData = await rootBundle.load('assets/Bad_Luck_Brian.jpg');
    final vidBytes = vidData.buffer.asUint8List();
    final vid2Bytes = vid2Data.buffer.asUint8List();
    final picBytes = picData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final video = File('${tempDir.path}/example.mp4');
    final video2 = File('${tempDir.path}/example2.mp4');
    final picture = File('${tempDir.path}/Bad_Luck_Brian.jpg');
    final output = File('${tempDir.path}/output.mp4');
    if (output.existsSync()) output.deleteSync();
    await video.writeAsBytes(vidBytes);
    await video2.writeAsBytes(vid2Bytes);
    await picture.writeAsBytes(picBytes);
    await FFmpegKit.cancel();
    final command = [
      '-y',
      '-i',
      video2.path,
      '-i',
      video.path,
      '-filter_complex',
      '[0:v]setpts=PTS+2/TB[timeshiftedVid];'
          '[timeshiftedVid][1:v]overlay=[outv]',
      '-map',
      '[outv]',
      output.path,
    ];
    final session = await FFmpegKit.executeWithArgumentsAsync(command);
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final state = await session.getState();
      print(state);
      if (state == SessionState.completed) {
        timer.cancel();
        completer.complete((output));
      }
    });
    return completer.future;
  }
}

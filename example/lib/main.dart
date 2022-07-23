import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiver/async.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool recording = false;
  int _time = 0;

  requestPermissions() async {
    await [
      Permission.photos,
      Permission.storage,
      Permission.microphone,
    ].request();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startTimer();
  }

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: 1000),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() => _time++);
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Screen Recording'),
        ),
        body: Builder(
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Time: $_time\n'),
                !recording
                    ? Center(
                        child: ElevatedButton(
                          child: Text("Record Screen"),
                          onPressed: () => startScreenRecord(context, audio: false),
                        ),
                      )
                    : Container(),
                !recording
                    ? Center(
                        child: ElevatedButton(
                          child: Text("Record Screen & audio"),
                          onPressed: () => startScreenRecord(context, audio: true),
                        ),
                      )
                    : Center(
                        child: ElevatedButton(
                          child: Text("Stop Record"),
                          onPressed: () => stopScreenRecord(),
                        ),
                      )
              ],
            );
          }
        ),
      ),
    );
  }

  startScreenRecord(BuildContext context, {bool audio}) async {
    bool start = false;
    await Future.delayed(const Duration(milliseconds: 1000));

    final size = MediaQuery.of(context).size / 4;
    final width = size.width.round();
    final height = size.height.round();

    if (audio) {
      start = await FlutterScreenRecording.startRecordScreenAndAudio(
        "Title" + _time.toString(),
        titleNotification: "dsffad",
        messageNotification: "sdffd",
        width: width,
        height: height,
      );
    } else {
      start = await FlutterScreenRecording.startRecordScreen(
        "Title",
        width: width,
        height: height,
        titleNotification: "Notification Title",
        messageNotification: "Notification Message",
      );
    }

    if (start) {
      setState(() => recording = !recording);
      print("Recording started at $_time");
    }

    return start;
  }

  stopScreenRecord() async {
    String path = await FlutterScreenRecording.stopRecordScreen;
    setState(() {
      recording = !recording;
      print("Recording stopped at $_time");
    });
    File videoFile = File(path);
    int fileSizeBytes = await videoFile.length();
    print('Video file size $fileSizeBytes bytes');

    print("Opening video");
    print(path);
    OpenFile.open(path);
  }
}

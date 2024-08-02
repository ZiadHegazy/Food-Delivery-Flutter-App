import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
class VoiceRecorder extends StatefulWidget {
  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _openRecorder();
  }

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder!.openRecorder();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/flutter_sound_example.aac';
    setState(() {
      _filePath = tempPath;
      _isRecording = true;
    });
    await _recorder!.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
    );
  }

   Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    if (_filePath != null) {
      await _uploadToFirebase();
    }
  }

  Future<void> _uploadToFirebase() async {
    if (_filePath == null) return;
    File file = File(_filePath!);
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('recordings/${file.uri.pathSegments.last}');
      await ref.putFile(file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded to Firebase Storage')),
      );
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              iconSize: 64.0,
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
            SizedBox(height: 20),
            Text(_isRecording ? 'Recording...' : 'Press the mic to start recording'),
            if (_filePath != null) ...[
              SizedBox(height: 20),
              Text('Recording saved at:'),
              Text(_filePath!),
            ],
          ],
        ),
      ),
    );
  }
}

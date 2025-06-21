import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle_swaja/screens/game_screen.dart';

import '../utils/share_utils.dart';
import 'dart:ui' as ui;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalScore = 0;
  bool hasSavedGame = false;
  bool screenshotCapturing = false;
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadScoreAndSavedGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadScoreAndSavedGame();
  }

  Future<void> _loadScoreAndSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('totalScore') ?? 0;
    final saved = prefs.getBool('hasGame') ?? false;

    setState(() {
      totalScore = score;
      hasSavedGame = saved;
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("How to Play"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🎯 Guess a 5-letter word in 6 tries."),
            Text("🟩 Green = correct letter & position"),
            Text("🟨 Yellow = correct letter, wrong position"),
            Text("⬜ Gray = wrong letter"),
            const SizedBox(height: 10),
            Text("Scoring:"),
            Text("✔ (6 - attemptNo) * 10"),
            Text("❌ 0 if time ends or all attempts fail."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Wordle Game"),
          actions: [
            IconButton(onPressed: _showInfoDialog, icon: Icon(Icons.info_outline))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Image.asset('assets/word.png'),
              const SizedBox(height: 50),
              Text("Total Score: $totalScore", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(hasSavedGame ? "Resume Game" : "Start Game"),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(resume: hasSavedGame),
                    ),
                  );

                  _loadScoreAndSavedGame();
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _captureScreenShotPng,
                child: screenshotCapturing?CircularProgressIndicator(color: Colors.blue,):Text("Share Score"),
              ),
            ],
          ),
        ),
      ),
    );
  }

 /* Future<void> _captureScreenShotPng() {
    if (mounted) {
      setState(() {
        screenshotCapturing = true;
      });
    }
    List<String> imagePaths = [];
    final RenderBox box = context.findRenderObject() as RenderBox;
    return Future.delayed(const Duration(milliseconds: 500), () async {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      File imgFile = File('$directory/screenshot.png');
      imagePaths.add(imgFile.path);
      imgFile.writeAsBytes(pngBytes).then((value) async {
        await Share.shareFiles(imagePaths,
            subject: 'My Score',
            text:
            'hey myb score is',
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        setState(() {
          screenshotCapturing = false;
        });
      }).catchError((onError) {
        setState(() {
          screenshotCapturing = false;
        });
        if (kDebugMode) {
          pr(onError);
        }
      });
    });
  }*/

  Future<void> _captureScreenShotPng() async {
    if (mounted) setState(() => screenshotCapturing = true);

    final RenderBox box = context.findRenderObject() as RenderBox;

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/screenshot.png';
      final imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        subject: 'My Score',
        text: 'Hey! I scored $totalScore in the Wordle Flutter Game! '
            'It\'s awesome 🤩.\n\nTry it: https://www.linkedin.com/in/rajendra-4120bb208/',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (kDebugMode) print('Error sharing screenshot: $e');
    } finally {
      if (mounted) setState(() => screenshotCapturing = false);
    }
  }
}

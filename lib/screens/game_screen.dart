import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/game_controller.dart';
import '../widgets/letter_box.dart';
import '../widgets/keyboard.dart';
import 'result_screen.dart';
import '../utils/word_list.dart';

class GameScreen extends StatefulWidget {
  final bool resume;
  const GameScreen({required this.resume});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = GameController();
    _initGame();
  }

  Future<void> _initGame() async {
    if (widget.resume) {
      await controller.loadGame();
    } else {
      controller.initNewGame();
    }
    _startTimer();
    setState(() => isLoading = false);
  }

  void _startTimer() {
    controller.startTimer(() => setState(() {}), _endGame);
  }

  void _endGame() async {
    await controller.saveScore();
    await controller.clearGame();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: controller.score,
          correctWord: controller.correctWord,
        ),
      ),
    );
  }

  void _handleSubmit() {
    setState(() {
      controller.submitWord();
      if (controller.isGameOver) {
        _endGame();
      } else {
        controller.saveGame();
      }
    });
  }

  void _handleKeyTap(String letter) {
    setState(() {
      controller.addLetter(letter);
    });
  }

  void _handleDelete() {
    setState(() {
      controller.removeLetter();
    });
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pause Game"),
        content: Text("Are you sure you want to resume later?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes")),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  bool get _isSubmitEnabled {
    final guess = controller.board[controller.currentRow].join('');
    return controller.currentCol == 5 && wordList.contains(guess.toLowerCase());
  }

  String get _submitButtonText {
    final guess = controller.board[controller.currentRow].join('');
    if (controller.currentCol < 5) {
      return "Submit"; ///////for defautl
    } else if (!wordList.contains(guess.toLowerCase())) {
      return "Not a Word";
    }
    return "Submit";
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: Text('Wordle')),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Time: ${Duration(seconds: controller.timerRemaining).inMinutes}:${(controller.timerRemaining % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...List.generate(6, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (col) {
                  return LetterBox(
                    letter: controller.board[row][col],
                    status: controller.boardColor[row][col],
                  );
                }),
              );
            }),
            const SizedBox(height: 20),
         /*   Keyboard(
              onLetterTap: _handleKeyTap,
              onDelete: _handleDelete,
              onEnter: _handleSubmit,
              keyStatus: controller.keyStatus,
              submitLabel: _submitButtonText,
            ),*/



            Keyboard(
              onLetterTap: _handleKeyTap,
              onDelete: _handleDelete,
              onEnter: _isSubmitEnabled ? _handleSubmit : null,
              keyStatus: controller.keyStatus,
              submitLabel: _submitButtonText,
            ),
          ],
        ),
      ),
    );
  }
}


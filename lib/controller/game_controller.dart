import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/word_list.dart';

class GameController {
  List<List<String>> board = List.generate(6, (_) => List.filled(5, ''));
  List<List<String>> boardColor = List.generate(6, (_) => List.filled(5, 'white'));
  int currentRow = 0;
  int currentCol = 0;
  String correctWord = '';
  int timerRemaining = 300;
  int score = 0;
  bool isGameOver = false;
  Map<String, String> keyStatus = {};
  Timer? _timer;

  void initNewGame() {
    correctWord = wordList[Random().nextInt(wordList.length)].toUpperCase();
    board = List.generate(6, (_) => List.filled(5, ''));
    boardColor = List.generate(6, (_) => List.filled(5, 'white'));
    currentRow = 0;
    currentCol = 0;
    timerRemaining = 300;
    keyStatus = {};
  }

  void addLetter(String letter) {
    if (currentCol < 5 && !isGameOver) {
      board[currentRow][currentCol] = letter;
      currentCol++;
    }
  }

  void removeLetter() {
    if (currentCol > 0 && !isGameOver) {
      currentCol--;
      board[currentRow][currentCol] = '';
    }
  }

  void submitWord() {
    if (currentCol < 5 || isGameOver) return;

    String guess = board[currentRow].join('');
     print('guess: $guess');
     print('wordList: $wordList');
     print('correctWord: $correctWord');
    if (!wordList.contains(guess.toLowerCase())) {

      Fluttertoast.showToast(
        msg: "Not a Word",
        backgroundColor: Colors.black,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    for (int i = 0; i < 5; i++) {
      String letter = guess[i];
      if (letter == correctWord[i]) {
        print('dddddddd');
        boardColor[currentRow][i] = 'green';
        // keyStatus[i] = 'green';
        keyStatus[letter] = 'green';
        keyStatus[letter] = 'green';
      } else if (correctWord.contains(letter)) {
        boardColor[currentRow][i] = 'yellow';
        if (keyStatus[letter] != 'green') keyStatus[letter] = 'yellow';
        print('boardColor: $boardColor');
      } else {
        boardColor[currentRow][i] = 'grey';
        if (!keyStatus.containsKey(letter)) keyStatus[letter] = 'grey';
      }
    }

    if (guess == correctWord) {
      score = (6 - currentRow) * 10;
      isGameOver = true;
    } else if (currentRow == 5) {
      isGameOver = true;
    } else {
      currentRow++;
      currentCol = 0;
    }
  }

  void startTimer(void Function() onTick, void Function() onExpire) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timerRemaining--;
      onTick();
      if (timerRemaining <= 0) {
        isGameOver = true;
        score = 0;
        timer.cancel();
        onExpire();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('board', jsonEncode(board));
    prefs.setString('boardColor', jsonEncode(boardColor));
    prefs.setInt('currentRow', currentRow);
    prefs.setInt('currentCol', currentCol);
    prefs.setInt('timerRemaining', timerRemaining);
    prefs.setString('correctWord', correctWord);
    prefs.setString('keyStatus', jsonEncode(keyStatus));
    prefs.setBool('hasGame', true);
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    board = List<List<String>>.from(jsonDecode(prefs.getString('board') ?? '[]').map((e) => List<String>.from(e)));
    boardColor = List<List<String>>.from(jsonDecode(prefs.getString('boardColor') ?? '[]').map((e) => List<String>.from(e)));
    currentRow = prefs.getInt('currentRow') ?? 0;
    currentCol = prefs.getInt('currentCol') ?? 0;
    correctWord = prefs.getString('correctWord') ?? '';
    timerRemaining = prefs.getInt('timerRemaining') ?? 300;
    keyStatus = Map<String, String>.from(jsonDecode(prefs.getString('keyStatus') ?? '{}'));
    print('correctWord: $correctWord');
    print('currentCol: $currentCol');


  }

  Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasGame', false);
  }

  Future<void> saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final previousScore = prefs.getInt('totalScore') ?? 0;
    prefs.setInt('totalScore', previousScore + score);
  }
}

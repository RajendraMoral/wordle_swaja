
import 'dart:io';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final String correctWord;

  ResultScreen({required this.score, required this.correctWord});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Correct Word: $correctWord", style: TextStyle(fontSize: 20)),
            Text("Your Score: $score", style: TextStyle(fontSize: 26)),
            ElevatedButton(
              child: Text("Play Again"),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

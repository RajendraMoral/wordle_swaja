import 'package:flutter/material.dart';

class LetterBox extends StatelessWidget {
  final String letter;
  final String status;

  const LetterBox({required this.letter, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    if (status == 'green') color = Colors.green;
    else if (status == 'yellow') color = Colors.orange;
    else if (status == 'grey') color = Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.all(4),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(letter.toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

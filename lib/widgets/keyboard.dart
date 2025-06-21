import 'package:flutter/material.dart';

class Keyboard extends StatelessWidget {
  final Function(String) onLetterTap;
  final VoidCallback onDelete;
  final VoidCallback? onEnter;
  final Map<String, String> keyStatus;
  final String submitLabel;

  const Keyboard({
    required this.onLetterTap,
    required this.onDelete,
    required this.onEnter,
    required this.keyStatus,
    required this.submitLabel,
  });

  Color getColor(String letter) {
    switch (keyStatus[letter] ?? '') {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

    return Column(
      children: [
        for (var row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              return InkWell(
                onTap: () => onLetterTap(letter),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getColor(letter),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(letter, style: const TextStyle(color: Colors.white)),
                ),
              );
            }).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(onPressed: onDelete, child: const Text("Delete")),

          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onEnter,
              style: ElevatedButton.styleFrom(
                backgroundColor: onEnter == null ? Colors.grey : Colors.blue,
              ),
              child: Text(submitLabel,style: TextStyle(color: onEnter == null ? Colors.grey : Colors.white,),),
            ),

          ],
        )
      ],
    );
  }
}

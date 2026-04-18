import 'package:flutter/material.dart';

class ChordText extends StatelessWidget {
  final String text;
  const ChordText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\[(.*?)\]');

    text.splitMapJoin(
      regExp,
      onMatch: (m) {
        spans.add(
          TextSpan(
            text: m.group(0),
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
        return "";
      },
      onNonMatch: (n) {
        spans.add(
          TextSpan(
            text: n,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              height: 1.5,
            ),
          ),
        );
        return "";
      },
    );

    return RichText(
      textAlign: TextAlign.left, // FIXED: Explicitly align left
      text: TextSpan(children: spans),
    );
  }
}

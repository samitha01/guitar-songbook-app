import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChordText extends StatelessWidget {
  final String text;
  const ChordText({super.key, required this.text});

  static const Color chordColor = Color(0xFF2F6F4F); // strong green
  static const Color lyricColor = Color(0xFF2C3A2F);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\[(.*?)\]');

    text.splitMapJoin(
      regExp,
      onMatch: (m) {
        spans.add(
          TextSpan(
            text: "[${m.group(1)}]", // keep brackets for clarity
            style: GoogleFonts.jetBrainsMono(
              color: chordColor,
              fontWeight: FontWeight.w800,
              fontSize: 20, // bigger than lyrics
              height: 1.6,
            ),
          ),
        );
        return "";
      },
      onNonMatch: (n) {
        spans.add(
          TextSpan(
            text: n,
            style: GoogleFonts.inter(
              color: lyricColor,
              fontSize: 18,
              height: 1.6,
            ),
          ),
        );
        return "";
      },
    );

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(children: spans),
    );
  }
}

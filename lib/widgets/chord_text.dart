import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChordText extends StatelessWidget {
  final String text;
  const ChordText({super.key, required this.text});

  static const Color sageDark = Color(0xFF5A7D63);
  static const Color ink = Color(0xFF2C3A2F);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\[(.*?)\]');

    text.splitMapJoin(
      regExp,
      onMatch: (m) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: GoogleFonts.jetBrainsMono(
              color: sageDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
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
            style: GoogleFonts.inter(color: ink, fontSize: 18, height: 1.6),
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

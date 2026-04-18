class MusicLogic {
  static final List<String> chromaticScale = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
  ];

  static String transposeSong(String text, int semitones) {
    if (semitones == 0) return text;

    // This "Regex" looks for anything inside brackets [ ]
    final RegExp chordRegex = RegExp(r'\[(.*?)\]');

    return text.splitMapJoin(
      chordRegex,
      onMatch: (m) {
        String chord = m.group(1)!;
        return '[${_transposeChord(chord, semitones)}]';
      },
      onNonMatch: (text) => text,
    );
  }

  static String _transposeChord(String chord, int semitones) {
    // 1. Find the base note (handles chords like Am, G7, Dsus4)
    String baseNote = chord;
    String suffix = "";

    if (chord.length > 1 && (chord[1] == '#' || chord[1] == 'b')) {
      baseNote = chord.substring(0, 2);
      suffix = chord.substring(2);
    } else {
      baseNote = chord.substring(0, 1);
      suffix = chord.substring(1);
    }

    // 2. Find index in scale
    int index = chromaticScale.indexOf(baseNote);
    if (index == -1) return chord; // Not a standard chord

    // 3. Shift index
    int newIndex = (index + semitones) % 12;
    if (newIndex < 0) newIndex += 12;

    return chromaticScale[newIndex] + suffix;
  }
}

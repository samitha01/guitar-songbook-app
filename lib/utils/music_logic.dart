class MusicLogic {
  static final List<String> sharpScale = [
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

  static final List<String> flatScale = [
    "C",
    "Db",
    "D",
    "Eb",
    "E",
    "F",
    "Gb",
    "G",
    "Ab",
    "A",
    "Bb",
    "B",
  ];

  static final Map<String, String> flatToSharp = {
    "Db": "C#",
    "Eb": "D#",
    "Gb": "F#",
    "Ab": "G#",
    "Bb": "A#",
  };

  static String transposeSong(
    String text,
    int semitones, {
    bool preferFlats = false,
  }) {
    if (semitones == 0) return text;

    final RegExp chordRegex = RegExp(r'\[(.*?)\]');

    return text.splitMapJoin(
      chordRegex,
      onMatch: (m) {
        String chord = m.group(1)!;
        return '[${_transposeChord(chord, semitones, preferFlats)}]';
      },
      onNonMatch: (text) => text,
    );
  }

  static String _transposeChord(String chord, int semitones, bool preferFlats) {
    String baseNote;
    String suffix;

    if (chord.length > 1 && (chord[1] == '#' || chord[1] == 'b')) {
      baseNote = chord.substring(0, 2);
      suffix = chord.substring(2);
    } else {
      baseNote = chord.substring(0, 1);
      suffix = chord.substring(1);
    }

    baseNote = flatToSharp[baseNote] ?? baseNote;

    int index = sharpScale.indexOf(baseNote);
    if (index == -1) return chord;

    int newIndex = (index + semitones) % 12;
    if (newIndex < 0) newIndex += 12;

    return preferFlats
        ? flatScale[newIndex] + suffix
        : sharpScale[newIndex] + suffix;
  }
}

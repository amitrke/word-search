class Puzzle {
  final String id;
  final String theme;
  final String difficulty;
  final int? level; // Level number (1-30), optional for backward compatibility
  final int gridSize;
  final List<String> grid; // Array of strings from Firestore
  final List<PuzzleWord> words;
  final int popularity;
  final List<String> tags;

  Puzzle({
    required this.id,
    required this.theme,
    required this.difficulty,
    this.level,
    required this.gridSize,
    required this.grid,
    required this.words,
    this.popularity = 0,
    this.tags = const [],
  });

  // Create from Firestore document
  factory Puzzle.fromFirestore(String id, Map<String, dynamic> data) {
    return Puzzle(
      id: id,
      theme: data['theme'] ?? '',
      difficulty: data['difficulty'] ?? '',
      level: data['level'] as int?, // Optional level field
      gridSize: data['gridSize'] ?? 8,
      grid: List<String>.from(data['grid'] ?? []),
      words: (data['words'] as List<dynamic>?)
              ?.map((w) => PuzzleWord.fromMap(w as Map<String, dynamic>))
              .toList() ??
          [],
      popularity: data['popularity'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    final map = {
      'theme': theme,
      'difficulty': difficulty,
      'gridSize': gridSize,
      'grid': grid,
      'words': words.map((w) => w.toMap()).toList(),
      'popularity': popularity,
      'tags': tags,
    };
    if (level != null) {
      map['level'] = level!;
    }
    return map;
  }

  // Convert grid strings to 2D array for display
  List<List<String>> get grid2D {
    return grid.map((row) => row.split('')).toList();
  }

  // Get letter at position
  String getLetter(int row, int col) {
    if (row >= 0 && row < grid.length && col >= 0 && col < grid[row].length) {
      return grid[row][col];
    }
    return '';
  }

  // Get difficulty color
  String get difficultyEmoji {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return '🟢';
      case 'medium':
        return '🟡';
      case 'hard':
        return '🔴';
      default:
        return '⚪';
    }
  }
}

class PuzzleWord {
  final String word;
  final int startRow;
  final int startCol;
  final String direction;
  final String hint;

  PuzzleWord({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
    required this.hint,
  });

  factory PuzzleWord.fromMap(Map<String, dynamic> map) {
    return PuzzleWord(
      word: map['word'] ?? '',
      startRow: map['startRow'] ?? 0,
      startCol: map['startCol'] ?? 0,
      direction: map['direction'] ?? '',
      hint: map['hint'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'startRow': startRow,
      'startCol': startCol,
      'direction': direction,
      'hint': hint,
    };
  }

  // Get end position of word based on direction and length
  Map<String, int> get endPosition {
    int endRow = startRow;
    int endCol = startCol;

    switch (direction) {
      case 'horizontal':
        endCol = startCol + word.length - 1;
        break;
      case 'vertical':
        endRow = startRow + word.length - 1;
        break;
      case 'diagonal-down':
        endRow = startRow + word.length - 1;
        endCol = startCol + word.length - 1;
        break;
      case 'diagonal-up':
        endRow = startRow + word.length - 1;
        endCol = startCol - word.length + 1;
        break;
    }

    return {'row': endRow, 'col': endCol};
  }
}

class LevelConfig {
  final int level;
  final int gridSize;
  final int minWords;
  final int maxWords;
  final List<String> allowedDirections;
  final String description;

  const LevelConfig({
    required this.level,
    required this.gridSize,
    required this.minWords,
    required this.maxWords,
    required this.allowedDirections,
    required this.description,
  });

  // Convert to difficulty string for Firebase queries (backwards compatibility)
  String get difficulty {
    if (level <= 10) return 'simple';
    if (level <= 20) return 'medium';
    return 'hard';
  }

  // Get color for level
  String get emoji {
    if (level <= 5) return '🟢'; // Very Easy
    if (level <= 10) return '🟡'; // Easy
    if (level <= 15) return '🟠'; // Medium
    if (level <= 20) return '🔴'; // Hard
    if (level <= 25) return '🟣'; // Very Hard
    return '⚫'; // Expert
  }

  // Get display name for level
  String get displayName => 'Level $level';

  // Check if level is unlocked based on completed levels
  bool isUnlocked(int highestCompletedLevel) {
    return level <= highestCompletedLevel + 1;
  }
}

class LevelSystem {
  static const int maxLevel = 30;

  // Define all 30 levels with progressive difficulty
  static final List<LevelConfig> levels = [
    // Levels 1-5: Beginner (5x5-7x7, introducing diagonals)
    LevelConfig(
      level: 1,
      gridSize: 5,
      minWords: 3,
      maxWords: 4,
      allowedDirections: ['horizontal', 'vertical'],
      description: 'Tiny grid, few words',
    ),
    LevelConfig(
      level: 2,
      gridSize: 5,
      minWords: 4,
      maxWords: 5,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Diagonals introduced!',
    ),
    LevelConfig(
      level: 3,
      gridSize: 6,
      minWords: 4,
      maxWords: 5,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Getting bigger',
    ),
    LevelConfig(
      level: 4,
      gridSize: 6,
      minWords: 5,
      maxWords: 6,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'More words to find',
    ),
    LevelConfig(
      level: 5,
      gridSize: 7,
      minWords: 5,
      maxWords: 6,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Final beginner level',
    ),

    // Levels 6-10: Easy (8x8, add diagonals)
    LevelConfig(
      level: 6,
      gridSize: 8,
      minWords: 6,
      maxWords: 7,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Diagonals unlocked!',
    ),
    LevelConfig(
      level: 7,
      gridSize: 8,
      minWords: 6,
      maxWords: 8,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'More diagonal words',
    ),
    LevelConfig(
      level: 8,
      gridSize: 8,
      minWords: 7,
      maxWords: 8,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Standard grid',
    ),
    LevelConfig(
      level: 9,
      gridSize: 8,
      minWords: 7,
      maxWords: 9,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Challenging searches',
    ),
    LevelConfig(
      level: 10,
      gridSize: 8,
      minWords: 8,
      maxWords: 10,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Easy mastery',
    ),

    // Levels 11-15: Medium (10x10)
    LevelConfig(
      level: 11,
      gridSize: 10,
      minWords: 8,
      maxWords: 10,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Bigger challenge',
    ),
    LevelConfig(
      level: 12,
      gridSize: 10,
      minWords: 9,
      maxWords: 11,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Medium difficulty',
    ),
    LevelConfig(
      level: 13,
      gridSize: 10,
      minWords: 10,
      maxWords: 12,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Getting harder',
    ),
    LevelConfig(
      level: 14,
      gridSize: 10,
      minWords: 10,
      maxWords: 12,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Tricky puzzles',
    ),
    LevelConfig(
      level: 15,
      gridSize: 10,
      minWords: 11,
      maxWords: 13,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Medium mastery',
    ),

    // Levels 16-20: Hard (12x12)
    LevelConfig(
      level: 16,
      gridSize: 12,
      minWords: 10,
      maxWords: 12,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Large grid',
    ),
    LevelConfig(
      level: 17,
      gridSize: 12,
      minWords: 11,
      maxWords: 13,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Hard difficulty',
    ),
    LevelConfig(
      level: 18,
      gridSize: 12,
      minWords: 12,
      maxWords: 14,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Many words',
    ),
    LevelConfig(
      level: 19,
      gridSize: 12,
      minWords: 13,
      maxWords: 15,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Expert level',
    ),
    LevelConfig(
      level: 20,
      gridSize: 12,
      minWords: 14,
      maxWords: 16,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Hard mastery',
    ),

    // Levels 21-25: Very Hard (15x15)
    LevelConfig(
      level: 21,
      gridSize: 15,
      minWords: 12,
      maxWords: 15,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Massive grid',
    ),
    LevelConfig(
      level: 22,
      gridSize: 15,
      minWords: 13,
      maxWords: 16,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Very challenging',
    ),
    LevelConfig(
      level: 23,
      gridSize: 15,
      minWords: 14,
      maxWords: 17,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Intense search',
    ),
    LevelConfig(
      level: 24,
      gridSize: 15,
      minWords: 15,
      maxWords: 18,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Very hard',
    ),
    LevelConfig(
      level: 25,
      gridSize: 15,
      minWords: 16,
      maxWords: 19,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Almost expert',
    ),

    // Levels 26-30: Expert (15x15, maximum difficulty)
    LevelConfig(
      level: 26,
      gridSize: 15,
      minWords: 16,
      maxWords: 19,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Expert difficulty',
    ),
    LevelConfig(
      level: 27,
      gridSize: 15,
      minWords: 17,
      maxWords: 20,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Master level',
    ),
    LevelConfig(
      level: 28,
      gridSize: 15,
      minWords: 18,
      maxWords: 21,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Ultimate challenge',
    ),
    LevelConfig(
      level: 29,
      gridSize: 15,
      minWords: 19,
      maxWords: 22,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'Near impossible',
    ),
    LevelConfig(
      level: 30,
      gridSize: 15,
      minWords: 20,
      maxWords: 23,
      allowedDirections: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'],
      description: 'LEGENDARY',
    ),
  ];

  // Get configuration for a specific level (uses intermediate track by default)
  static LevelConfig getLevel(int level) {
    if (level < 1 || level > maxLevel) {
      return levels[0]; // Default to level 1
    }
    return levels[level - 1];
  }

  // NEW: Get configuration for a specific level based on skill level
  static LevelConfig getLevelForSkill(int level, dynamic skillLevel) {
    // Import difficulty_tracks dynamically to avoid circular dependency
    // This will be called from the UI with the appropriate skill level

    if (level < 1 || level > maxLevel) {
      return levels[0]; // Default to level 1
    }

    // For now, return the default config
    // The actual skill-based config is retrieved from difficulty_tracks.dart
    return levels[level - 1];
  }

  // Get all unlocked levels based on highest completed
  static List<LevelConfig> getUnlockedLevels(int highestCompletedLevel) {
    return levels.where((level) => level.isUnlocked(highestCompletedLevel)).toList();
  }

  // Get next level to unlock
  static LevelConfig? getNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) return null;
    return levels[currentLevel];
  }

  // Calculate level from old difficulty system (for migration)
  static int levelFromDifficulty(String difficulty, int completedCount) {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return (completedCount % 10) + 1;
      case 'medium':
        return (completedCount % 10) + 11;
      case 'hard':
        return (completedCount % 10) + 21;
      default:
        return 1;
    }
  }
}

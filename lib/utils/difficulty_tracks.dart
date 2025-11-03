// Difficulty tracks for different skill levels
// Users choose their track when they first start the app

enum SkillLevel {
  beginner,      // For kids (ages 5-10) or casual players
  intermediate,  // For teens/adults with some experience
  expert,        // For puzzle enthusiasts
}

class DifficultyTrack {
  final SkillLevel skillLevel;
  final String displayName;
  final String description;
  final List<LevelConfigOverride> levelConfigs;

  const DifficultyTrack({
    required this.skillLevel,
    required this.displayName,
    required this.description,
    required this.levelConfigs,
  });
}

class LevelConfigOverride {
  final int level;
  final int gridSize;
  final int minWords;
  final int maxWords;
  final List<String> directions;
  final String emoji;
  final String displayName;

  const LevelConfigOverride({
    required this.level,
    required this.gridSize,
    required this.minWords,
    required this.maxWords,
    required this.directions,
    required this.emoji,
    required this.displayName,
  });
}

/// BEGINNER TRACK - Slower progression, smaller grids
/// Perfect for kids ages 5-10 or casual players
const beginnerTrack = DifficultyTrack(
  skillLevel: SkillLevel.beginner,
  displayName: '🌟 Beginner',
  description: 'Perfect for kids and beginners. Easier puzzles with slower progression.',
  levelConfigs: [
    // Levels 1-10: Stay at 5x5 (building confidence)
    LevelConfigOverride(level: 1, gridSize: 5, minWords: 3, maxWords: 3, directions: ['horizontal', 'vertical'], emoji: '🌱', displayName: 'Starting Out'),
    LevelConfigOverride(level: 2, gridSize: 5, minWords: 3, maxWords: 4, directions: ['horizontal', 'vertical'], emoji: '🌿', displayName: 'Growing'),
    LevelConfigOverride(level: 3, gridSize: 5, minWords: 4, maxWords: 4, directions: ['horizontal', 'vertical'], emoji: '🍀', displayName: 'Getting Better'),
    LevelConfigOverride(level: 4, gridSize: 5, minWords: 4, maxWords: 5, directions: ['horizontal', 'vertical'], emoji: '🌻', displayName: 'Doing Great'),
    LevelConfigOverride(level: 5, gridSize: 5, minWords: 5, maxWords: 5, directions: ['horizontal', 'vertical'], emoji: '🌺', displayName: 'Awesome'),
    LevelConfigOverride(level: 6, gridSize: 5, minWords: 5, maxWords: 6, directions: ['horizontal', 'vertical'], emoji: '🌸', displayName: 'Super Star'),
    LevelConfigOverride(level: 7, gridSize: 5, minWords: 6, maxWords: 6, directions: ['horizontal', 'vertical'], emoji: '🌼', displayName: 'Amazing'),
    LevelConfigOverride(level: 8, gridSize: 5, minWords: 6, maxWords: 7, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '🌷', displayName: 'Champion'),
    LevelConfigOverride(level: 9, gridSize: 5, minWords: 6, maxWords: 7, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '🏵️', displayName: 'Expert Beginner'),
    LevelConfigOverride(level: 10, gridSize: 5, minWords: 7, maxWords: 7, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '🎖️', displayName: 'Beginner Master'),

    // Levels 11-20: Slowly move to 6x6
    LevelConfigOverride(level: 11, gridSize: 6, minWords: 5, maxWords: 6, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '🚀', displayName: 'Leveling Up'),
    LevelConfigOverride(level: 12, gridSize: 6, minWords: 5, maxWords: 7, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '✈️', displayName: 'Flying High'),
    LevelConfigOverride(level: 13, gridSize: 6, minWords: 6, maxWords: 7, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '🎯', displayName: 'On Target'),
    LevelConfigOverride(level: 14, gridSize: 6, minWords: 6, maxWords: 8, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '🎪', displayName: 'Having Fun'),
    LevelConfigOverride(level: 15, gridSize: 6, minWords: 7, maxWords: 8, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎨', displayName: 'Creative Mind'),
    LevelConfigOverride(level: 16, gridSize: 6, minWords: 7, maxWords: 9, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎭', displayName: 'Word Artist'),
    LevelConfigOverride(level: 17, gridSize: 6, minWords: 8, maxWords: 9, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎬', displayName: 'Superstar'),
    LevelConfigOverride(level: 18, gridSize: 6, minWords: 8, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎪', displayName: 'Showtime'),
    LevelConfigOverride(level: 19, gridSize: 6, minWords: 9, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏆', displayName: 'Trophy Winner'),
    LevelConfigOverride(level: 20, gridSize: 6, minWords: 9, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '👑', displayName: 'Word Royalty'),

    // Levels 21-30: Move to 7x7 (cap for beginners)
    LevelConfigOverride(level: 21, gridSize: 7, minWords: 7, maxWords: 9, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌟', displayName: 'Shining Bright'),
    LevelConfigOverride(level: 22, gridSize: 7, minWords: 8, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '💫', displayName: 'Sparkling'),
    LevelConfigOverride(level: 23, gridSize: 7, minWords: 8, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '✨', displayName: 'Brilliant'),
    LevelConfigOverride(level: 24, gridSize: 7, minWords: 9, maxWords: 11, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌠', displayName: 'Shooting Star'),
    LevelConfigOverride(level: 25, gridSize: 7, minWords: 9, maxWords: 11, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎆', displayName: 'Fireworks'),
    LevelConfigOverride(level: 26, gridSize: 7, minWords: 10, maxWords: 12, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎇', displayName: 'Spectacular'),
    LevelConfigOverride(level: 27, gridSize: 7, minWords: 10, maxWords: 12, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎉', displayName: 'Celebration'),
    LevelConfigOverride(level: 28, gridSize: 7, minWords: 11, maxWords: 13, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🥳', displayName: 'Party Time'),
    LevelConfigOverride(level: 29, gridSize: 7, minWords: 11, maxWords: 13, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏅', displayName: 'Gold Medal'),
    LevelConfigOverride(level: 30, gridSize: 7, minWords: 12, maxWords: 14, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎖️', displayName: 'Ultimate Champion'),
  ],
);

/// INTERMEDIATE TRACK - Balanced progression
/// Perfect for teens and adults with some puzzle experience
const intermediateTrack = DifficultyTrack(
  skillLevel: SkillLevel.intermediate,
  displayName: '⭐ Intermediate',
  description: 'Balanced difficulty for most players. Steady progression.',
  levelConfigs: [
    // Levels 1-5: 5x5 warmup
    LevelConfigOverride(level: 1, gridSize: 5, minWords: 3, maxWords: 4, directions: ['horizontal', 'vertical'], emoji: '🌱', displayName: 'Level 1'),
    LevelConfigOverride(level: 2, gridSize: 5, minWords: 4, maxWords: 5, directions: ['horizontal', 'vertical', 'diagonal-down'], emoji: '🌿', displayName: 'Level 2'),
    LevelConfigOverride(level: 3, gridSize: 5, minWords: 5, maxWords: 6, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🍀', displayName: 'Level 3'),
    LevelConfigOverride(level: 4, gridSize: 6, minWords: 5, maxWords: 6, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌻', displayName: 'Level 4'),
    LevelConfigOverride(level: 5, gridSize: 6, minWords: 5, maxWords: 7, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌺', displayName: 'Level 5'),

    // Levels 6-15: 6x6 to 8x8
    LevelConfigOverride(level: 6, gridSize: 6, minWords: 6, maxWords: 7, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🚀', displayName: 'Level 6'),
    LevelConfigOverride(level: 7, gridSize: 7, minWords: 6, maxWords: 8, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '✈️', displayName: 'Level 7'),
    LevelConfigOverride(level: 8, gridSize: 7, minWords: 7, maxWords: 8, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎯', displayName: 'Level 8'),
    LevelConfigOverride(level: 9, gridSize: 7, minWords: 7, maxWords: 9, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎪', displayName: 'Level 9'),
    LevelConfigOverride(level: 10, gridSize: 8, minWords: 8, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎨', displayName: 'Level 10'),
    LevelConfigOverride(level: 11, gridSize: 8, minWords: 8, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎭', displayName: 'Level 11'),
    LevelConfigOverride(level: 12, gridSize: 8, minWords: 9, maxWords: 11, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎬', displayName: 'Level 12'),
    LevelConfigOverride(level: 13, gridSize: 8, minWords: 9, maxWords: 11, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎪', displayName: 'Level 13'),
    LevelConfigOverride(level: 14, gridSize: 8, minWords: 10, maxWords: 12, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏆', displayName: 'Level 14'),
    LevelConfigOverride(level: 15, gridSize: 8, minWords: 10, maxWords: 12, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '👑', displayName: 'Level 15'),

    // Levels 16-25: 10x10
    LevelConfigOverride(level: 16, gridSize: 10, minWords: 10, maxWords: 12, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌟', displayName: 'Level 16'),
    LevelConfigOverride(level: 17, gridSize: 10, minWords: 11, maxWords: 13, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '💫', displayName: 'Level 17'),
    LevelConfigOverride(level: 18, gridSize: 10, minWords: 11, maxWords: 13, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '✨', displayName: 'Level 18'),
    LevelConfigOverride(level: 19, gridSize: 10, minWords: 12, maxWords: 14, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌠', displayName: 'Level 19'),
    LevelConfigOverride(level: 20, gridSize: 10, minWords: 12, maxWords: 15, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎆', displayName: 'Level 20'),
    LevelConfigOverride(level: 21, gridSize: 10, minWords: 13, maxWords: 15, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎇', displayName: 'Level 21'),
    LevelConfigOverride(level: 22, gridSize: 10, minWords: 13, maxWords: 16, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎉', displayName: 'Level 22'),
    LevelConfigOverride(level: 23, gridSize: 10, minWords: 14, maxWords: 16, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🥳', displayName: 'Level 23'),
    LevelConfigOverride(level: 24, gridSize: 10, minWords: 14, maxWords: 17, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏅', displayName: 'Level 24'),
    LevelConfigOverride(level: 25, gridSize: 10, minWords: 15, maxWords: 17, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎖️', displayName: 'Level 25'),

    // Levels 26-30: 12x12
    LevelConfigOverride(level: 26, gridSize: 12, minWords: 14, maxWords: 17, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '💎', displayName: 'Level 26'),
    LevelConfigOverride(level: 27, gridSize: 12, minWords: 15, maxWords: 18, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '👑', displayName: 'Level 27'),
    LevelConfigOverride(level: 28, gridSize: 12, minWords: 16, maxWords: 19, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏆', displayName: 'Level 28'),
    LevelConfigOverride(level: 29, gridSize: 12, minWords: 17, maxWords: 20, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🥇', displayName: 'Level 29'),
    LevelConfigOverride(level: 30, gridSize: 12, minWords: 18, maxWords: 21, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌟', displayName: 'Level 30'),
  ],
);

/// EXPERT TRACK - Fast progression, challenging puzzles
/// Perfect for puzzle enthusiasts and experienced players
const expertTrack = DifficultyTrack(
  skillLevel: SkillLevel.expert,
  displayName: '🔥 Expert',
  description: 'For puzzle masters. Challenging from the start.',
  levelConfigs: [
    // Levels 1-5: Quick ramp up to 8x8
    LevelConfigOverride(level: 1, gridSize: 6, minWords: 5, maxWords: 6, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🔥', displayName: 'Level 1'),
    LevelConfigOverride(level: 2, gridSize: 7, minWords: 6, maxWords: 8, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '⚡', displayName: 'Level 2'),
    LevelConfigOverride(level: 3, gridSize: 8, minWords: 7, maxWords: 9, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '💪', displayName: 'Level 3'),
    LevelConfigOverride(level: 4, gridSize: 8, minWords: 8, maxWords: 10, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🚀', displayName: 'Level 4'),
    LevelConfigOverride(level: 5, gridSize: 8, minWords: 9, maxWords: 11, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎯', displayName: 'Level 5'),

    // Levels 6-15: 10x10 with many words
    LevelConfigOverride(level: 6, gridSize: 10, minWords: 10, maxWords: 12, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🧠', displayName: 'Level 6'),
    LevelConfigOverride(level: 7, gridSize: 10, minWords: 11, maxWords: 13, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎮', displayName: 'Level 7'),
    LevelConfigOverride(level: 8, gridSize: 10, minWords: 12, maxWords: 14, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏹', displayName: 'Level 8'),
    LevelConfigOverride(level: 9, gridSize: 10, minWords: 13, maxWords: 15, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '⚔️', displayName: 'Level 9'),
    LevelConfigOverride(level: 10, gridSize: 10, minWords: 14, maxWords: 16, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🛡️', displayName: 'Level 10'),
    LevelConfigOverride(level: 11, gridSize: 12, minWords: 13, maxWords: 15, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🗡️', displayName: 'Level 11'),
    LevelConfigOverride(level: 12, gridSize: 12, minWords: 14, maxWords: 16, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏹', displayName: 'Level 12'),
    LevelConfigOverride(level: 13, gridSize: 12, minWords: 15, maxWords: 17, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎖️', displayName: 'Level 13'),
    LevelConfigOverride(level: 14, gridSize: 12, minWords: 16, maxWords: 18, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏆', displayName: 'Level 14'),
    LevelConfigOverride(level: 15, gridSize: 12, minWords: 17, maxWords: 19, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '👑', displayName: 'Level 15'),

    // Levels 16-30: 15x15 maximum challenge
    LevelConfigOverride(level: 16, gridSize: 15, minWords: 15, maxWords: 18, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '💎', displayName: 'Level 16'),
    LevelConfigOverride(level: 17, gridSize: 15, minWords: 16, maxWords: 19, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🔮', displayName: 'Level 17'),
    LevelConfigOverride(level: 18, gridSize: 15, minWords: 17, maxWords: 20, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌟', displayName: 'Level 18'),
    LevelConfigOverride(level: 19, gridSize: 15, minWords: 18, maxWords: 21, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '💫', displayName: 'Level 19'),
    LevelConfigOverride(level: 20, gridSize: 15, minWords: 19, maxWords: 22, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '✨', displayName: 'Level 20'),
    LevelConfigOverride(level: 21, gridSize: 15, minWords: 19, maxWords: 23, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🌠', displayName: 'Level 21'),
    LevelConfigOverride(level: 22, gridSize: 15, minWords: 20, maxWords: 24, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎆', displayName: 'Level 22'),
    LevelConfigOverride(level: 23, gridSize: 15, minWords: 21, maxWords: 25, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎇', displayName: 'Level 23'),
    LevelConfigOverride(level: 24, gridSize: 15, minWords: 22, maxWords: 26, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🎉', displayName: 'Level 24'),
    LevelConfigOverride(level: 25, gridSize: 15, minWords: 23, maxWords: 27, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🥳', displayName: 'Level 25'),
    LevelConfigOverride(level: 26, gridSize: 15, minWords: 24, maxWords: 28, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏅', displayName: 'Level 26'),
    LevelConfigOverride(level: 27, gridSize: 15, minWords: 25, maxWords: 29, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🥇', displayName: 'Level 27'),
    LevelConfigOverride(level: 28, gridSize: 15, minWords: 26, maxWords: 30, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🥈', displayName: 'Level 28'),
    LevelConfigOverride(level: 29, gridSize: 15, minWords: 27, maxWords: 31, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🥉', displayName: 'Level 29'),
    LevelConfigOverride(level: 30, gridSize: 15, minWords: 28, maxWords: 32, directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'], emoji: '🏆', displayName: 'Level 30'),
  ],
);

/// Get all available tracks
List<DifficultyTrack> getAllTracks() {
  return [beginnerTrack, intermediateTrack, expertTrack];
}

/// Get a specific track
DifficultyTrack getTrack(SkillLevel level) {
  switch (level) {
    case SkillLevel.beginner:
      return beginnerTrack;
    case SkillLevel.intermediate:
      return intermediateTrack;
    case SkillLevel.expert:
      return expertTrack;
  }
}

/// Get level config for a specific track and level number
LevelConfigOverride? getLevelConfig(SkillLevel skillLevel, int levelNumber) {
  final track = getTrack(skillLevel);

  try {
    return track.levelConfigs.firstWhere((config) => config.level == levelNumber);
  } catch (e) {
    return null;
  }
}

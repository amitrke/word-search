class UserProfile {
  final String? userId; // null for guest users
  final String displayName;
  final bool isGuest;
  final int currentLevel; // Current level the user is on
  final int highestCompletedLevel; // Highest level completed
  final int totalPuzzlesCompleted; // Total puzzles completed
  final DateTime createdAt;
  final DateTime lastPlayedAt;

  UserProfile({
    this.userId,
    this.displayName = 'Guest',
    this.isGuest = true,
    this.currentLevel = 1,
    this.highestCompletedLevel = 0, // 0 means only level 1 is unlocked
    this.totalPuzzlesCompleted = 0,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastPlayedAt = lastPlayedAt ?? DateTime.now();

  // Create from Firestore document
  factory UserProfile.fromFirestore(String userId, Map<String, dynamic> data) {
    return UserProfile(
      userId: userId,
      displayName: data['displayName'] ?? 'User',
      isGuest: false, // Firestore users are not guests
      currentLevel: data['currentLevel'] ?? 1,
      highestCompletedLevel: data['highestCompletedLevel'] ?? 0,
      totalPuzzlesCompleted: data['totalPuzzlesCompleted'] ?? 0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastPlayedAt: data['lastPlayedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'currentLevel': currentLevel,
      'highestCompletedLevel': highestCompletedLevel,
      'totalPuzzlesCompleted': totalPuzzlesCompleted,
      'createdAt': createdAt,
      'lastPlayedAt': lastPlayedAt,
    };
  }

  // Create a guest profile
  factory UserProfile.guest() {
    return UserProfile(
      userId: null,
      displayName: 'Guest',
      isGuest: true,
    );
  }

  // Copy with method for updates
  UserProfile copyWith({
    String? userId,
    String? displayName,
    bool? isGuest,
    int? currentLevel,
    int? highestCompletedLevel,
    int? totalPuzzlesCompleted,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      currentLevel: currentLevel ?? this.currentLevel,
      highestCompletedLevel: highestCompletedLevel ?? this.highestCompletedLevel,
      totalPuzzlesCompleted: totalPuzzlesCompleted ?? this.totalPuzzlesCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  // Check if a level is unlocked
  bool isLevelUnlocked(int level) {
    return level <= highestCompletedLevel + 1;
  }

  // Get progress message
  String getProgressMessage() {
    if (highestCompletedLevel >= 30) {
      return 'All levels completed! You are a LEGEND! 🏆';
    } else if (highestCompletedLevel == 0) {
      return 'Complete Level 1 to unlock Level 2!';
    } else {
      return 'Level ${highestCompletedLevel + 1} unlocked! Keep going!';
    }
  }

  // Get completion percentage
  double get completionPercentage {
    return (highestCompletedLevel / 30.0) * 100;
  }
}

class UserPuzzleProgress {
  final String puzzleId;
  final String userId;
  final List<String> foundWords;
  final bool completed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int timeSpentSeconds;

  UserPuzzleProgress({
    required this.puzzleId,
    required this.userId,
    this.foundWords = const [],
    this.completed = false,
    DateTime? startedAt,
    this.completedAt,
    this.timeSpentSeconds = 0,
  }) : startedAt = startedAt ?? DateTime.now();

  // Create from Firestore document
  factory UserPuzzleProgress.fromFirestore(Map<String, dynamic> data) {
    return UserPuzzleProgress(
      puzzleId: data['puzzleId'] ?? '',
      userId: data['userId'] ?? '',
      foundWords: List<String>.from(data['foundWords'] ?? []),
      completed: data['completed'] ?? false,
      startedAt: data['startedAt']?.toDate() ?? DateTime.now(),
      completedAt: data['completedAt']?.toDate(),
      timeSpentSeconds: data['timeSpentSeconds'] ?? 0,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'puzzleId': puzzleId,
      'userId': userId,
      'foundWords': foundWords,
      'completed': completed,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  // Copy with method for updates
  UserPuzzleProgress copyWith({
    String? puzzleId,
    String? userId,
    List<String>? foundWords,
    bool? completed,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeSpentSeconds,
  }) {
    return UserPuzzleProgress(
      puzzleId: puzzleId ?? this.puzzleId,
      userId: userId ?? this.userId,
      foundWords: foundWords ?? this.foundWords,
      completed: completed ?? this.completed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
    );
  }
}

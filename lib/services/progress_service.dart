import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _localProgressBoxName = 'userProgress';
  static const String _localProfileKey = 'guestProfile';

  // Initialize Hive for local storage
  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_localProgressBoxName);
  }

  // Get local progress box
  Box get _progressBox => Hive.box(_localProgressBoxName);

  // Save guest profile locally
  Future<void> saveGuestProfileLocally(UserProfile profile) async {
    final data = profile.toFirestore();
    // Convert DateTime to ISO8601 strings for Hive storage
    data['createdAt'] = profile.createdAt.toIso8601String();
    data['lastPlayedAt'] = profile.lastPlayedAt.toIso8601String();
    await _progressBox.put(_localProfileKey, data);
  }

  // Load guest profile from local storage
  UserProfile loadGuestProfileLocally() {
    final data = _progressBox.get(_localProfileKey);
    if (data != null) {
      return UserProfile(
        userId: null,
        displayName: data['displayName'] ?? 'Guest',
        isGuest: true,
        currentLevel: data['currentLevel'] ?? 1,
        highestCompletedLevel: data['highestCompletedLevel'] ?? 0,
        totalPuzzlesCompleted: data['totalPuzzlesCompleted'] ?? 0,
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : DateTime.now(),
        lastPlayedAt: data['lastPlayedAt'] != null
            ? DateTime.parse(data['lastPlayedAt'])
            : DateTime.now(),
      );
    }
    return UserProfile.guest();
  }

  // Clear local guest data
  Future<void> clearGuestData() async {
    await _progressBox.clear();
  }

  // Mark level as completed
  Future<UserProfile> completeLevel(
    UserProfile currentProfile,
    int completedLevel,
  ) async {
    // Update highest completed level if this is a new record
    final newHighestCompleted = completedLevel > currentProfile.highestCompletedLevel
        ? completedLevel
        : currentProfile.highestCompletedLevel;

    // Move to next level if current level was completed
    final newCurrentLevel = completedLevel == currentProfile.currentLevel
        ? (completedLevel < 30 ? completedLevel + 1 : completedLevel)
        : currentProfile.currentLevel;

    final updatedProfile = currentProfile.copyWith(
      currentLevel: newCurrentLevel,
      highestCompletedLevel: newHighestCompleted,
      totalPuzzlesCompleted: currentProfile.totalPuzzlesCompleted + 1,
      lastPlayedAt: DateTime.now(),
    );

    // Save based on user type
    if (currentProfile.isGuest) {
      // Save to local storage
      await saveGuestProfileLocally(updatedProfile);
    } else if (currentProfile.userId != null) {
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(currentProfile.userId)
          .set(updatedProfile.toFirestore(), SetOptions(merge: true));
    }

    return updatedProfile;
  }

  // Save puzzle progress (found words)
  Future<void> savePuzzleProgress(
    String userId,
    UserPuzzleProgress progress,
  ) async {
    if (userId.isEmpty || userId == 'guest') {
      // Save to local storage for guest
      await _progressBox.put('puzzle_${progress.puzzleId}', {
        'puzzleId': progress.puzzleId,
        'foundWords': progress.foundWords,
        'completed': progress.completed,
        'startedAt': progress.startedAt.toIso8601String(),
        'completedAt': progress.completedAt?.toIso8601String(),
        'timeSpentSeconds': progress.timeSpentSeconds,
      });
    } else {
      // Save to Firestore for signed-in users
      await _firestore
          .collection('userPuzzles')
          .doc('${userId}_${progress.puzzleId}')
          .set(progress.toFirestore(), SetOptions(merge: true));
    }
  }

  // Load puzzle progress
  Future<UserPuzzleProgress?> loadPuzzleProgress(
    String userId,
    String puzzleId,
  ) async {
    if (userId.isEmpty || userId == 'guest') {
      // Load from local storage for guest
      final data = _progressBox.get('puzzle_$puzzleId');
      if (data != null) {
        return UserPuzzleProgress(
          puzzleId: data['puzzleId'] ?? puzzleId,
          userId: 'guest',
          foundWords: List<String>.from(data['foundWords'] ?? []),
          completed: data['completed'] ?? false,
          startedAt: data['startedAt'] != null
              ? DateTime.parse(data['startedAt'])
              : DateTime.now(),
          completedAt: data['completedAt'] != null
              ? DateTime.parse(data['completedAt'])
              : null,
          timeSpentSeconds: data['timeSpentSeconds'] ?? 0,
        );
      }
    } else {
      // Load from Firestore for signed-in users
      try {
        final doc = await _firestore
            .collection('userPuzzles')
            .doc('${userId}_$puzzleId')
            .get();

        if (doc.exists) {
          return UserPuzzleProgress.fromFirestore(doc.data()!);
        }
      } catch (e) {
        // Return null if error
        return null;
      }
    }

    return null;
  }

  // Check if level is unlocked
  bool isLevelUnlocked(UserProfile profile, int level) {
    return profile.isLevelUnlocked(level);
  }

  // Get progress message
  String getProgressMessage(UserProfile profile) {
    return profile.getProgressMessage();
  }

  // Check if new level was just unlocked
  bool checkForNewUnlock(
    UserProfile oldProfile,
    UserProfile newProfile,
  ) {
    return newProfile.highestCompletedLevel > oldProfile.highestCompletedLevel;
  }

  // Get newly unlocked level number
  int? getNewlyUnlockedLevel(
    UserProfile oldProfile,
    UserProfile newProfile,
  ) {
    if (newProfile.highestCompletedLevel > oldProfile.highestCompletedLevel) {
      return newProfile.highestCompletedLevel + 1; // Next level unlocked
    }
    return null;
  }
}

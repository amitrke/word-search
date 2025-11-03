import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/progress_service.dart';
import '../utils/difficulty_tracks.dart';

class UserProgressProvider with ChangeNotifier {
  final ProgressService _progressService = ProgressService();
  Function(UserProfile)? _onProfileUpdate;

  UserProfile? _currentProfile;
  Map<String, UserPuzzleProgress> _puzzleProgressMap = {};
  bool _isLoading = false;
  String? _error;

  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with user profile
  void setUserProfile(UserProfile profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  // Set the callback for profile updates (called by AuthProvider)
  void setOnProfileUpdate(Function(UserProfile) callback) {
    _onProfileUpdate = callback;
  }

  // Complete a level
  Future<bool> completeLevel(int levelNumber) async {
    if (_currentProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final oldProfile = _currentProfile!;
      _currentProfile = await _progressService.completeLevel(
        _currentProfile!,
        levelNumber,
      );

      // Update AuthProvider with the new profile
      if (_onProfileUpdate != null) {
        _onProfileUpdate!(_currentProfile!);
      }

      // Check if a new level was unlocked
      final newLevel = _progressService.getNewlyUnlockedLevel(
        oldProfile,
        _currentProfile!,
      );

      _error = null;
      notifyListeners();

      // Return true if new level was unlocked
      return newLevel != null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save puzzle progress (found words)
  Future<void> savePuzzleProgress(UserPuzzleProgress progress) async {
    if (_currentProfile == null) return;

    try {
      final userId = _currentProfile!.userId ?? 'guest';
      await _progressService.savePuzzleProgress(userId, progress);

      // Update local cache
      _puzzleProgressMap[progress.puzzleId] = progress;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load puzzle progress
  Future<UserPuzzleProgress?> loadPuzzleProgress(String puzzleId) async {
    if (_currentProfile == null) return null;

    // Check cache first
    if (_puzzleProgressMap.containsKey(puzzleId)) {
      return _puzzleProgressMap[puzzleId];
    }

    try {
      final userId = _currentProfile!.userId ?? 'guest';
      final progress = await _progressService.loadPuzzleProgress(
        userId,
        puzzleId,
      );

      if (progress != null) {
        _puzzleProgressMap[puzzleId] = progress;
      }

      return progress;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Check if level is unlocked
  bool isLevelUnlocked(int level) {
    if (_currentProfile == null) return level == 1;
    return _progressService.isLevelUnlocked(_currentProfile!, level);
  }

  // Get progress message
  String getProgressMessage() {
    if (_currentProfile == null) return '';
    return _progressService.getProgressMessage(_currentProfile!);
  }

  // Get unlocked levels
  List<int> getUnlockedLevels() {
    if (_currentProfile == null) return [1];
    final highestCompleted = _currentProfile!.highestCompletedLevel;
    return List.generate(
      (highestCompleted + 1).clamp(1, 30),
      (index) => index + 1,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // NEW: Get current skill level
  SkillLevel get skillLevel => _currentProfile?.skillLevel ?? SkillLevel.intermediate;

  // NEW: Set skill level
  Future<void> setSkillLevel(SkillLevel level) async {
    if (_currentProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = _currentProfile!.copyWith(
        skillLevel: level,
      );

      _currentProfile = updatedProfile;

      // Save to Firebase
      await _progressService.updateUserProfile(updatedProfile);

      // Update AuthProvider with the new profile
      if (_onProfileUpdate != null) {
        _onProfileUpdate!(updatedProfile);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Get level config based on current skill level
  LevelConfigOverride getCurrentLevelConfig() {
    final level = _currentProfile?.currentLevel ?? 1;
    final skill = skillLevel;
    return getLevelConfig(skill, level) ?? _getDefaultConfig(level);
  }

  // NEW: Get level config for a specific level
  LevelConfigOverride getLevelConfigForLevel(int level) {
    final skill = skillLevel;
    return getLevelConfig(skill, level) ?? _getDefaultConfig(level);
  }

  // Fallback to intermediate track if config not found
  LevelConfigOverride _getDefaultConfig(int level) {
    return getLevelConfig(SkillLevel.intermediate, level) ??
        const LevelConfigOverride(
          level: 1,
          gridSize: 5,
          minWords: 3,
          maxWords: 4,
          directions: ['horizontal', 'vertical'],
          emoji: '🌱',
          displayName: 'Level 1',
        );
  }
}

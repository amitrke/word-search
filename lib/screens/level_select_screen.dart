import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/puzzle.dart';
import '../providers/user_progress_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/level_config.dart';
import 'puzzle_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final progressProvider = Provider.of<UserProgressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search Levels'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Show user status
          IconButton(
            icon: Icon(authProvider.isGuest ? Icons.person_outline : Icons.person),
            onPressed: () {
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress banner
            if (progressProvider.currentProfile != null)
              _buildProgressBanner(progressProvider),

            // Level grid
            Expanded(
              child: _buildLevelGrid(progressProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBanner(UserProgressProvider progressProvider) {
    final profile = progressProvider.currentProfile!;
    final message = progressProvider.getProgressMessage();
    final completionPercent = profile.completionPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Level ${profile.currentLevel} • ${profile.totalPuzzlesCompleted} Completed',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: completionPercent / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(UserProgressProvider progressProvider) {
    final highestCompletedLevel = progressProvider.currentProfile?.highestCompletedLevel ?? 0;

    // Current level is the next unplayed level (highest completed + 1)
    final currentLevel = highestCompletedLevel + 1;

    // NEW: Get skill-based level configs
    final currentLevelConfigOverride = progressProvider.getLevelConfigForLevel(currentLevel);
    final currentLevelConfig = LevelConfig(
      level: currentLevel,
      gridSize: currentLevelConfigOverride.gridSize,
      minWords: currentLevelConfigOverride.minWords,
      maxWords: currentLevelConfigOverride.maxWords,
      allowedDirections: currentLevelConfigOverride.directions,
      description: currentLevelConfigOverride.displayName,
    );

    LevelConfig? nextLevelConfig;
    if (currentLevel < LevelSystem.maxLevel) {
      final nextLevelConfigOverride = progressProvider.getLevelConfigForLevel(currentLevel + 1);
      nextLevelConfig = LevelConfig(
        level: currentLevel + 1,
        gridSize: nextLevelConfigOverride.gridSize,
        minWords: nextLevelConfigOverride.minWords,
        maxWords: nextLevelConfigOverride.maxWords,
        allowedDirections: nextLevelConfigOverride.directions,
        description: nextLevelConfigOverride.displayName,
      );
    }

    final currentIsCompleted = currentLevel <= highestCompletedLevel;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isWideScreen && nextLevelConfig != null)
            // Side-by-side layout for wide screens
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Current Level',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildLevelCard(
                        currentLevelConfig,
                        true,
                        currentIsCompleted,
                        true,
                        isLarge: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Next Level',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildLevelCard(
                        nextLevelConfig,
                        currentIsCompleted,
                        false,
                        false,
                        isLarge: false,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            // Vertical layout for mobile or when at max level
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Current Level',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _buildLevelCard(
                    currentLevelConfig,
                    true,
                    currentIsCompleted,
                    true,
                    isLarge: true,
                  ),
                ),
                if (nextLevelConfig != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Next Level',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _buildLevelCard(
                      nextLevelConfig,
                      currentIsCompleted,
                      false,
                      false,
                      isLarge: true,
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 16),
          // Status message
          if (nextLevelConfig != null && !currentIsCompleted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete Level $currentLevel to unlock the next level',
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (nextLevelConfig == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ve mastered all levels! 🎉',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    LevelConfig levelConfig,
    bool isUnlocked,
    bool isCompleted,
    bool isCurrent, {
    bool isLarge = false,
  }) {
    return InkWell(
      onTap: isUnlocked
          ? () => _selectLevel(levelConfig)
          : () => _showLockedMessage(levelConfig.level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: isLarge ? const EdgeInsets.all(16) : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? Theme.of(context).colorScheme.primary
                : isCompleted
                    ? Colors.green
                    : isUnlocked
                        ? Colors.grey[300]!
                        : Colors.grey[400]!,
            width: isCurrent ? 3 : 2,
          ),
          color: isCompleted
              ? Colors.green[50]
              : isUnlocked
                  ? Colors.white
                  : Colors.grey[200],
        ),
        child: isLarge
            ? Column(
                children: [
                  // Emoji or lock icon
                  if (!isUnlocked)
                    const Icon(Icons.lock, size: 36, color: Colors.grey)
                  else if (isCompleted)
                    const Icon(Icons.check_circle, size: 36, color: Colors.green)
                  else
                    Text(levelConfig.emoji, style: const TextStyle(fontSize: 36)),

                  const SizedBox(height: 10),

                  // Level number and title
                  Text(
                    '${levelConfig.level}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    levelConfig.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Grid size and word count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Grid: ${levelConfig.gridSize}×${levelConfig.gridSize}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Words: ${levelConfig.minWords}-${levelConfig.maxWords}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isCompleted) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji or lock icon
                  if (!isUnlocked)
                    const Icon(Icons.lock, size: 24, color: Colors.grey)
                  else if (isCompleted)
                    const Icon(Icons.check_circle, size: 24, color: Colors.green)
                  else
                    Text(levelConfig.emoji, style: const TextStyle(fontSize: 24)),

                  const SizedBox(height: 4),

                  // Level number
                  Text(
                    '${levelConfig.level}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black87 : Colors.grey[600],
                    ),
                  ),

                  // Grid size
                  if (isUnlocked)
                    Text(
                      '${levelConfig.gridSize}×${levelConfig.gridSize}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _selectLevel(LevelConfig levelConfig) async {
    // Query for a puzzle matching this level
    try {
      // NEW: First try to find a puzzle with the exact level AND grid size
      // This ensures we get puzzles appropriate for the user's skill level
      var querySnapshot = await FirebaseFirestore.instance
          .collection('puzzles')
          .where('level', isEqualTo: levelConfig.level)
          .where('gridSize', isEqualTo: levelConfig.gridSize)
          .limit(10)
          .get();

      // If no puzzle found for specific level + gridSize, try just level
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('puzzles')
            .where('level', isEqualTo: levelConfig.level)
            .limit(10)
            .get();
      }

      // If still no puzzle found, fall back to difficulty + gridSize
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('puzzles')
            .where('difficulty', isEqualTo: levelConfig.difficulty)
            .where('gridSize', isEqualTo: levelConfig.gridSize)
            .limit(10)
            .get();
      }

      // Final fallback: just difficulty
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('puzzles')
            .where('difficulty', isEqualTo: levelConfig.difficulty)
            .limit(10)
            .get();
      }

      if (querySnapshot.docs.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No puzzles available for Level ${levelConfig.level} (${levelConfig.gridSize}×${levelConfig.gridSize}). Please generate puzzles first.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Pick a random puzzle from the results
      final randomIndex = (querySnapshot.docs.length > 1)
          ? DateTime.now().millisecond % querySnapshot.docs.length
          : 0;
      final puzzleDoc = querySnapshot.docs[randomIndex];
      final puzzle = Puzzle.fromFirestore(puzzleDoc.id, puzzleDoc.data());

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleScreen(
              puzzle: puzzle,
              levelNumber: levelConfig.level,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading puzzle: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showLockedMessage(int level) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complete Level ${level - 1} to unlock this level!'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider =
        Provider.of<UserProgressProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authProvider.isGuest ? 'Guest Profile' : 'Profile',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (progressProvider.currentProfile != null) ...[
              _buildStatRow('Current Level',
                  'Level ${progressProvider.currentProfile!.currentLevel}'),
              _buildStatRow('Highest Completed',
                  'Level ${progressProvider.currentProfile!.highestCompletedLevel}'),
              _buildStatRow('Total Puzzles',
                  '${progressProvider.currentProfile!.totalPuzzlesCompleted}'),
              _buildStatRow('Completion',
                  '${progressProvider.currentProfile!.completionPercentage.toStringAsFixed(1)}%'),
            ],
            const SizedBox(height: 24),
            if (authProvider.isGuest) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showLoginDialog(context);
                  },
                  child: const Text('Sign In to Save Progress'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    authProvider.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    bool isSignUp = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isSignUp ? 'Sign Up' : 'Sign In'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Social sign-in buttons
                if (!isSignUp) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        final success = await authProvider.signInWithGoogle();

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Signed in with Google successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.error ?? 'Google sign-in failed'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continue with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        final success = await authProvider.signInWithApple();

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Signed in with Apple successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.error ?? 'Apple sign-in failed'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.apple, size: 24),
                      label: const Text('Continue with Apple'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey[600])),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                // Email/Password fields
                if (isSignUp)
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (isSignUp) const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  isSignUp = !isSignUp;
                });
              },
              child: Text(isSignUp
                  ? 'Already have an account? Sign In'
                  : 'Need an account? Sign Up'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);

                bool success;
                if (isSignUp) {
                  success = await authProvider.signUpWithEmailPassword(
                    emailController.text,
                    passwordController.text,
                    nameController.text,
                  );
                } else {
                  success = await authProvider.signInWithEmailPassword(
                    emailController.text,
                    passwordController.text,
                  );
                }

                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSignUp
                          ? 'Account created successfully!'
                          : 'Signed in successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.error ?? 'Authentication failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(isSignUp ? 'Sign Up' : 'Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

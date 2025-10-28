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
      body: Column(
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
    );
  }

  Widget _buildProgressBanner(UserProgressProvider progressProvider) {
    final profile = progressProvider.currentProfile!;
    final message = progressProvider.getProgressMessage();
    final completionPercent = profile.completionPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
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
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Level ${profile.currentLevel} • ${profile.totalPuzzlesCompleted} Completed',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionPercent / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(UserProgressProvider progressProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 levels per row
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: LevelSystem.maxLevel,
      itemBuilder: (context, index) {
        final level = index + 1;
        final levelConfig = LevelSystem.getLevel(level);
        final isUnlocked = progressProvider.isLevelUnlocked(level);
        final isCompleted = level <= (progressProvider.currentProfile?.highestCompletedLevel ?? 0);
        final isCurrent = level == (progressProvider.currentProfile?.currentLevel ?? 1);

        return _buildLevelCard(levelConfig, isUnlocked, isCompleted, isCurrent);
      },
    );
  }

  Widget _buildLevelCard(LevelConfig levelConfig, bool isUnlocked, bool isCompleted, bool isCurrent) {
    return InkWell(
      onTap: isUnlocked
          ? () => _selectLevel(levelConfig)
          : () => _showLockedMessage(levelConfig.level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Column(
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
    // Query for a puzzle matching this level's difficulty
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('puzzles')
          .where('difficulty', isEqualTo: levelConfig.difficulty)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No puzzles available for Level ${levelConfig.level}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final puzzleDoc = querySnapshot.docs.first;
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

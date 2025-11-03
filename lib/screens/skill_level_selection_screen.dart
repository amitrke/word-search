import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_progress_provider.dart';
import '../utils/difficulty_tracks.dart';
import 'level_select_screen.dart';

class SkillLevelSelectionScreen extends StatefulWidget {
  const SkillLevelSelectionScreen({super.key});

  @override
  State<SkillLevelSelectionScreen> createState() =>
      _SkillLevelSelectionScreenState();
}

class _SkillLevelSelectionScreenState extends State<SkillLevelSelectionScreen> {
  SkillLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Header
              Text(
                'Welcome to',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Word Search!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 32),

              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Question
              Text(
                'Choose Your Challenge Level',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Pick the difficulty that feels right for you.\nYou can always change this later!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Skill level cards
              _buildSkillCard(
                skillLevel: SkillLevel.beginner,
                icon: '🌟',
                title: 'Beginner',
                subtitle: 'Perfect for kids (ages 5-10)',
                description:
                    'Smaller grids (5x5 to 7x7), fewer words, slower progression. Build confidence at your own pace!',
                color: Colors.green,
                features: [
                  '• Starts with 5×5 grids',
                  '• 3-7 words per puzzle',
                  '• Stays easy for 10 levels',
                  '• Great for ages 5-10',
                ],
              ),

              const SizedBox(height: 16),

              _buildSkillCard(
                skillLevel: SkillLevel.intermediate,
                icon: '⭐',
                title: 'Intermediate',
                subtitle: 'Best for most players',
                description:
                    'Balanced progression (5x5 to 12x12), moderate challenge. Perfect for teens and adults!',
                color: Colors.blue,
                features: [
                  '• Starts with 5×5 grids',
                  '• 5-12 words per puzzle',
                  '• Balanced progression',
                  '• Great for ages 10+',
                ],
              ),

              const SizedBox(height: 16),

              _buildSkillCard(
                skillLevel: SkillLevel.expert,
                icon: '🔥',
                title: 'Expert',
                subtitle: 'For puzzle masters',
                description:
                    'Challenging from the start! Larger grids (6x6 to 15x15), many words. Are you up for it?',
                color: Colors.deepOrange,
                features: [
                  '• Starts with 6×6 grids',
                  '• 8-20 words per puzzle',
                  '• Fast progression',
                  '• For experienced players',
                ],
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedLevel != null
                      ? () => _confirmSelection()
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Playing!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Help text
              Text(
                'Don\'t worry, you can change this anytime in settings',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCard({
    required SkillLevel skillLevel,
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required List<String> features,
  }) {
    final isSelected = _selectedLevel == skillLevel;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = skillLevel;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: color,
                              size: 24,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Features
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _confirmSelection() async {
    if (_selectedLevel == null) return;

    final progressProvider =
        Provider.of<UserProgressProvider>(context, listen: false);

    // Save the skill level preference
    await progressProvider.setSkillLevel(_selectedLevel!);

    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (!mounted) return;

    // Navigate to main game screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LevelSelectScreen(),
      ),
    );
  }
}

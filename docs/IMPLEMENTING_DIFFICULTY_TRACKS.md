# Implementation Guide: Difficulty Tracks

## Step-by-Step Implementation

### Phase 1: Data Model Updates (Backend)

#### 1.1 Update User Profile Model

```dart
// lib/models/user_profile.dart

class UserProfile {
  final String userId;
  final String username;
  final String? email;
  final SkillLevel skillLevel; // NEW FIELD
  final int currentLevel;
  final int highestCompletedLevel;
  // ... rest of fields

  UserProfile({
    required this.userId,
    required this.username,
    this.email,
    this.skillLevel = SkillLevel.intermediate, // DEFAULT
    required this.currentLevel,
    required this.highestCompletedLevel,
    // ... rest
  });

  // Update toJson()
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'skillLevel': skillLevel.name, // NEW
      'currentLevel': currentLevel,
      'highestCompletedLevel': highestCompletedLevel,
      // ... rest
    };
  }

  // Update fromJson()
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      skillLevel: _parseSkillLevel(json['skillLevel']), // NEW
      currentLevel: json['currentLevel'] as int? ?? 1,
      highestCompletedLevel: json['highestCompletedLevel'] as int? ?? 0,
      // ... rest
    );
  }

  // Helper to parse skill level
  static SkillLevel _parseSkillLevel(dynamic value) {
    if (value == null) return SkillLevel.intermediate;
    if (value is String) {
      return SkillLevel.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SkillLevel.intermediate,
      );
    }
    return SkillLevel.intermediate;
  }
}
```

#### 1.2 Update UserProgressProvider

```dart
// lib/providers/user_progress_provider.dart

class UserProgressProvider extends ChangeNotifier {
  // ... existing fields

  SkillLevel get skillLevel => _currentProfile?.skillLevel ?? SkillLevel.intermediate;

  // NEW: Set skill level
  Future<void> setSkillLevel(SkillLevel level) async {
    if (_currentProfile == null) return;

    final updatedProfile = UserProfile(
      userId: _currentProfile!.userId,
      username: _currentProfile!.username,
      email: _currentProfile!.email,
      skillLevel: level, // UPDATE
      currentLevel: _currentProfile!.currentLevel,
      highestCompletedLevel: _currentProfile!.highestCompletedLevel,
      // ... copy other fields
    );

    _currentProfile = updatedProfile;
    notifyListeners();

    // Save to Firebase
    await _firestoreService.updateUserProfile(updatedProfile);
  }

  // NEW: Get level config based on skill level
  LevelConfigOverride getCurrentLevelConfig() {
    final level = _currentProfile?.currentLevel ?? 1;
    final skill = skillLevel;
    return getLevelConfig(skill, level) ?? _getDefaultConfig(level);
  }

  LevelConfigOverride _getDefaultConfig(int level) {
    // Fallback to intermediate track
    return getLevelConfig(SkillLevel.intermediate, level)!;
  }
}
```

### Phase 2: UI Implementation (Frontend)

#### 2.1 Update Main App Flow

```dart
// lib/main.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProgressProvider>(
          create: (_) => UserProgressProvider(),
          update: (_, authProvider, progressProvider) {
            final provider = progressProvider ?? UserProgressProvider();

            if (authProvider.currentProfile != null) {
              provider.setUserProfile(authProvider.currentProfile!);
            }

            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Word Search',
        theme: ThemeData(/* ... */),
        home: const _AppNavigator(), // NEW
      ),
    );
  }
}

// NEW: Smart navigator
class _AppNavigator extends StatelessWidget {
  const _AppNavigator();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final progressProvider = Provider.of<UserProgressProvider>(context);

    // Check if user needs to select skill level
    if (authProvider.currentProfile != null) {
      final profile = authProvider.currentProfile!;

      // New users without skill level → Show selection screen
      if (profile.skillLevel == null ||
          !profile.hasCompletedOnboarding) {
        return const SkillLevelSelectionScreen();
      }
    }

    // Existing users → Go to level select
    return const LevelSelectScreen();
  }
}
```

#### 2.2 Add Setting to Change Difficulty

```dart
// lib/screens/settings_screen.dart (or add to profile menu)

ListTile(
  leading: const Icon(Icons.tune),
  title: const Text('Change Difficulty'),
  subtitle: Text('Current: ${_getSkillLevelName(progressProvider.skillLevel)}'),
  onTap: () => _showDifficultyChangeDialog(context),
),

void _showDifficultyChangeDialog(BuildContext context) {
  final progressProvider = Provider.of<UserProgressProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change Difficulty'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDifficultyOption(
            context,
            SkillLevel.beginner,
            '🌟 Beginner',
            'Easier puzzles',
            progressProvider,
          ),
          const SizedBox(height: 12),
          _buildDifficultyOption(
            context,
            SkillLevel.intermediate,
            '⭐ Intermediate',
            'Balanced difficulty',
            progressProvider,
          ),
          const SizedBox(height: 12),
          _buildDifficultyOption(
            context,
            SkillLevel.expert,
            '🔥 Expert',
            'Maximum challenge',
            progressProvider,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

Widget _buildDifficultyOption(
  BuildContext context,
  SkillLevel level,
  String title,
  String subtitle,
  UserProgressProvider provider,
) {
  final isSelected = provider.skillLevel == level;

  return InkWell(
    onTap: () async {
      await provider.setSkillLevel(level);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Difficulty changed to $title')),
        );
      }
    },
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          if (isSelected) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Phase 3: Puzzle Selection Logic

#### 3.1 Update Level System to Use Skill Level

```dart
// lib/utils/level_system.dart

class LevelSystem {
  static LevelConfig getLevel(int level, SkillLevel skillLevel) {
    // Get config from difficulty track
    final trackConfig = getLevelConfig(skillLevel, level);

    if (trackConfig != null) {
      return LevelConfig(
        level: level,
        gridSize: trackConfig.gridSize,
        minWords: trackConfig.minWords,
        maxWords: trackConfig.maxWords,
        directions: trackConfig.directions,
        emoji: trackConfig.emoji,
        displayName: trackConfig.displayName,
      );
    }

    // Fallback to default (shouldn't happen)
    return _getDefaultLevel(level);
  }
}
```

#### 3.2 Update Puzzle Selection Query

```dart
// lib/services/firestore_service.dart

Future<Puzzle?> getRandomPuzzleForLevel(int level, SkillLevel skillLevel) async {
  // Get the level config for this skill level
  final levelConfig = getLevelConfig(skillLevel, level);

  if (levelConfig == null) return null;

  // Query Firestore for puzzles matching this config
  final query = _firestore
      .collection('puzzles')
      .where('level', isEqualTo: level)
      .where('gridSize', isEqualTo: levelConfig.gridSize)
      .limit(10);

  final snapshot = await query.get();

  if (snapshot.docs.isEmpty) {
    print('⚠️ No puzzles found for level $level, gridSize ${levelConfig.gridSize}');
    return null;
  }

  // Pick a random puzzle
  final randomIndex = Random().nextInt(snapshot.docs.length);
  final doc = snapshot.docs[randomIndex];

  return Puzzle.fromJson(doc.data());
}
```

### Phase 4: Puzzle Generation Updates

#### 4.1 Update Smart Generator to Consider Skill Levels

```javascript
// scripts/puzzle-generator/generate-puzzles.js

async function analyzeUserProgress(db) {
  console.log('👥 Analyzing user progress...\n');

  try {
    const usersSnapshot = await db.collection('users').get();
    const userProfiles = usersSnapshot.docs.map(doc => doc.data());

    // Count users at each level AND skill level
    const usersAtLevel = {};
    const usersBySkillLevel = {
      beginner: 0,
      intermediate: 0,
      expert: 0
    };

    for (const profile of userProfiles) {
      const currentLevel = profile.currentLevel || 1;
      const skillLevel = profile.skillLevel || 'intermediate';

      const key = `${skillLevel}_${currentLevel}`;
      usersAtLevel[key] = (usersAtLevel[key] || 0) + 1;
      usersBySkillLevel[skillLevel]++;
    }

    console.log('  Users by Skill Level:');
    console.log(`    Beginner: ${usersBySkillLevel.beginner}`);
    console.log(`    Intermediate: ${usersBySkillLevel.intermediate}`);
    console.log(`    Expert: ${usersBySkillLevel.expert}\n`);

    return {
      totalUsers: userProfiles.length,
      usersAtLevel,
      usersBySkillLevel
    };

  } catch (error) {
    console.error('  ⚠ Error analyzing user progress:', error.message);
    return {
      totalUsers: 0,
      usersAtLevel: {},
      usersBySkillLevel: {}
    };
  }
}

// Update priority calculation
function prioritizeLevelsForGeneration(inventory, userProgress, config) {
  // ... existing code ...

  // NEW: Weight by skill level distribution
  const skillWeights = {
    beginner: 2.0,    // Higher priority for kids
    intermediate: 1.5,
    expert: 1.0
  };

  for (const skillLevel of ['beginner', 'intermediate', 'expert']) {
    const track = getTrack(skillLevel);

    for (const levelConfig of track.levelConfigs) {
      const level = levelConfig.level;
      const key = `${skillLevel}_${level}`;
      const usersHere = usersAtLevel[key] || 0;

      // Calculate priority with skill weight
      let priority = 0;
      if (usersHere > 0) {
        priority += 50 + (usersHere * skillWeights[skillLevel] * 5);
      }

      // ... rest of priority calculation
    }
  }
}
```

### Phase 5: Database Migration

#### 5.1 Migration Script

```dart
// scripts/migrate_users_skill_level.dart

Future<void> migrateUsersToSkillLevel() async {
  final firestore = FirebaseFirestore.instance;
  final usersRef = firestore.collection('users');

  final snapshot = await usersRef.get();

  print('Migrating ${snapshot.docs.length} users...');

  int updated = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();

    // Skip if already has skillLevel
    if (data['skillLevel'] != null) continue;

    // Assign based on current progress
    String skillLevel = 'intermediate'; // Default

    final currentLevel = data['currentLevel'] as int? ?? 1;
    final avgCompletionTime = data['averageCompletionTime'] as int? ?? 300;

    // Auto-assign based on heuristics
    if (currentLevel <= 3) {
      // New users → intermediate (let them choose later)
      skillLevel = 'intermediate';
    } else if (avgCompletionTime < 120) {
      // Fast players → expert
      skillLevel = 'expert';
    } else if (avgCompletionTime > 300) {
      // Slow players → beginner
      skillLevel = 'beginner';
    } else {
      // Average → intermediate
      skillLevel = 'intermediate';
    }

    await doc.reference.update({'skillLevel': skillLevel});
    updated++;
  }

  print('✓ Updated $updated users');
}
```

## Testing Checklist

- [ ] New users see skill level selection screen
- [ ] Users can select beginner/intermediate/expert
- [ ] Selection is saved to Firebase
- [ ] Puzzles load with correct difficulty
- [ ] Level select shows appropriate grid sizes
- [ ] Users can change difficulty in settings
- [ ] Progress is preserved when changing difficulty
- [ ] Puzzle generation creates puzzles for all tracks
- [ ] Analytics track skill level distribution

## Rollout Strategy

### Week 1: Soft Launch
- Deploy to 10% of users
- Monitor analytics
- Check for errors

### Week 2: Expand
- Deploy to 50% of users
- Collect feedback
- Adjust if needed

### Week 3: Full Launch
- Deploy to 100% of users
- Announce feature
- Monitor engagement

## Success Metrics

Track these KPIs:

| Metric | Target |
|--------|--------|
| **User Distribution** | 20% beginner, 60% intermediate, 20% expert |
| **Completion Rate** | +15% for beginners |
| **Retention (Day 7)** | +20% for beginners |
| **Time per Puzzle** | Balanced across tracks |
| **Track Switches** | < 10% per month (indicates good initial selection) |

## Conclusion

This implementation adds significant value:
- ✅ Makes app accessible to kids
- ✅ Provides appropriate challenge for all
- ✅ Increases retention
- ✅ Minimal code changes
- ✅ Easy to maintain

Total implementation time: **2-3 days** for a single developer.

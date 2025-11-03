import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/level_select_screen.dart';
import 'screens/skill_level_selection_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_progress_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
    print('Make sure you ran: flutterfire configure');
  }

  runApp(const MyApp());
}

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

            // Set up callback to update AuthProvider when progress changes
            provider.setOnProfileUpdate((updatedProfile) {
              authProvider.updateProfile(updatedProfile);
            });

            // Update provider with current profile from AuthProvider
            if (authProvider.currentProfile != null) {
              provider.setUserProfile(authProvider.currentProfile!);
            }

            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Word Search',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),
        home: const _AppNavigator(),
      ),
    );
  }
}

// Smart navigator that checks if user needs to select skill level
class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  bool _isChecking = true;
  bool _needsSkillSelection = false;

  @override
  void initState() {
    super.initState();
    _checkSkillLevelSelection();
  }

  Future<void> _checkSkillLevelSelection() async {
    // Check if this is the first time user is opening the app
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

    // If onboarding is completed, go to level select
    if (hasCompletedOnboarding) {
      setState(() {
        _isChecking = false;
        _needsSkillSelection = false;
      });
      return;
    }

    // New user - show skill selection
    setState(() {
      _isChecking = false;
      _needsSkillSelection = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show loading while checking
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_needsSkillSelection) {
      return const SkillLevelSelectionScreen();
    }

    return const LevelSelectScreen();
  }
}

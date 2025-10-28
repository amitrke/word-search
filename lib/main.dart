import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/level_select_screen.dart';
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
            if (authProvider.currentProfile != null) {
              progressProvider?.setUserProfile(authProvider.currentProfile!);
            }
            return progressProvider ?? UserProgressProvider();
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
        home: const LevelSelectScreen(),
      ),
    );
  }
}

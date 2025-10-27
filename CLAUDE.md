# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered word search puzzle application built with Flutter and Firebase. The app generates themed word search puzzles using ChatGPT (or similar AI), stores them in Firebase Firestore, and provides puzzles at three difficulty levels (Simple, Medium, Hard).

**Key Architecture**:
- **Frontend**: Flutter mobile app with Provider state management
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **AI Integration**: Server-side puzzle generation using ChatGPT API via Cloud Functions
- **Storage**: Firestore for puzzles and user data, Hive for local caching

## Common Commands

### Development
- `flutter run` - Run the app (supports hot reload with 'r' key, hot restart with 'R' key)
- `flutter run -d <device>` - Run on specific device (chrome, windows, etc.)
- `flutter devices` - List available devices

### Testing
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run a specific test file

### Code Quality
- `flutter analyze` - Run static analysis using flutter_lints rules
- `flutter pub outdated` - Check for outdated dependencies

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Building
- `flutter build apk` - Build Android APK
- `flutter build appbundle` - Build Android App Bundle
- `flutter build ios` - Build iOS app (requires macOS)
- `flutter build windows` - Build Windows app
- `flutter build web` - Build web app

### Firebase
- `flutterfire configure` - Configure Firebase for Flutter
- `firebase deploy --only functions` - Deploy Cloud Functions
- `firebase emulators:start` - Run Firebase emulators locally
- `firebase functions:config:set openai.key="key"` - Set environment variables
- `cd functions && npm run serve` - Test Cloud Functions locally

## Architecture

### Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── firebase_options.dart     # Generated Firebase configuration
├── models/                   # Data models
│   ├── puzzle.dart          # Puzzle model (grid, words, difficulty)
│   ├── user_profile.dart    # User profile and statistics
│   ├── word.dart            # Word model (position, direction)
│   └── user_puzzle.dart     # User's puzzle progress
├── services/                 # Business logic and API interactions
│   ├── auth_service.dart    # Firebase Authentication
│   ├── firestore_service.dart  # Firestore CRUD operations
│   ├── puzzle_service.dart  # Puzzle generation requests
│   └── local_storage_service.dart  # Hive cache management
├── providers/                # State management (Provider pattern)
│   ├── auth_provider.dart   # Authentication state
│   ├── puzzle_provider.dart # Current puzzle state
│   └── user_stats_provider.dart  # User statistics
├── screens/                  # UI screens
│   ├── home_screen.dart     # Main puzzle browser
│   ├── puzzle_screen.dart   # Puzzle playing interface
│   ├── profile_screen.dart  # User profile and stats
│   ├── daily_challenge_screen.dart
│   └── auth/                # Authentication screens
├── widgets/                  # Reusable widgets
│   ├── puzzle_grid.dart     # Interactive puzzle grid
│   ├── word_list.dart       # Word list with found/remaining
│   └── puzzle_card.dart     # Puzzle preview card
└── utils/
    ├── constants.dart        # App constants (difficulty levels, etc.)
    └── theme.dart           # App theme configuration

functions/                    # Firebase Cloud Functions (Node.js/TypeScript)
├── src/
│   ├── index.ts             # Main function exports
│   ├── puzzleGenerator.ts   # Puzzle generation logic
│   ├── aiService.ts         # ChatGPT API integration
│   └── wordPlacement.ts     # Word placement algorithm
```

### Data Flow

1. **Puzzle Creation**: Cloud Function calls ChatGPT API → generates word list → places words in grid → stores in Firestore
2. **Puzzle Retrieval**: Flutter app queries Firestore → caches locally in Hive → displays to user
3. **User Progress**: User plays puzzle → updates saved to Firestore → statistics recalculated → achievements checked

### State Management

Uses **Provider** pattern:
- `AuthProvider`: Manages user authentication state
- `PuzzleProvider`: Manages current puzzle, word selection, completion
- `UserStatsProvider`: Manages user statistics and achievements

## Key Dependencies

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - NoSQL database
- `cloud_functions` - Call backend functions
- `firebase_analytics` - Usage analytics
- `firebase_crashlytics` - Crash reporting

### State Management & Storage
- `provider` - State management pattern
- `hive` & `hive_flutter` - Local caching
- `shared_preferences` - Settings storage

### UI & Utilities
- `cupertino_icons` - iOS-style icons
- `google_fonts` - Custom fonts
- `flutter_animate` - Animations
- `intl` - Internationalization
- `uuid` - Unique ID generation

### Development
- `flutter_lints` - Code quality rules

## Firestore Schema

### Collections
- **puzzles**: Pre-generated puzzles (theme, difficulty, grid, words)
- **users**: User profiles and statistics
- **userPuzzles**: Individual puzzle progress and completion data
- **dailyChallenges**: Daily challenge puzzles
- **themes**: Puzzle theme categories

See `docs/REQUIREMENTS.md` for detailed schema.

## Difficulty Levels

| Level  | Grid Size | Words  | Directions          |
|--------|-----------|--------|---------------------|
| Simple | 8x8       | 5-8    | Horizontal, Vertical|
| Medium | 12x12     | 10-15  | H, V, Diagonal      |
| Hard   | 15x15     | 15-20  | All + Backwards     |

## Important Notes

- **Puzzle Generation**: Server-side via GitHub Actions (recommended) or Cloud Functions
  - **GitHub Actions** (Recommended): Stays on FREE Spark plan, generates puzzles in batches
  - **Cloud Functions**: Requires paid Blaze plan, generates on-demand
- **AI Integration**: ChatGPT API called from GitHub Actions workflow
- **Security Rules**: Puzzles are read-only to clients; only server can write
- **Offline Support**: Puzzles cached locally using Hive for offline play
- **State Management**: Use Provider pattern; avoid direct Firestore calls in UI
- **See**: `docs/GITHUB_ACTIONS_SETUP.md` for detailed GitHub Actions implementation

## Platform Support

This project is configured for multiple platforms:
- Android (via android/)
- iOS (via ios/)
- Windows (via windows/)
- Web (via web/)
- macOS (via macos/)
- Linux (via linux/)

## Documentation

- `docs/REQUIREMENTS.md` - Full feature requirements and Firebase schema
- `docs/TECHNICAL_SETUP.md` - Step-by-step setup instructions
- `README.md` - Project overview

# Word Search - AI-Powered Puzzle App

[Play store test link](https://play.google.com/apps/internaltest/4701732917199276346)

An intelligent word search puzzle application built with Flutter and Firebase, featuring AI-generated themed puzzles with multiple difficulty levels.

## 🎯 Project Overview

This app generates word search puzzles using ChatGPT, stores them in Firebase Firestore, and provides an engaging puzzle-solving experience with achievements, daily challenges, and social features.

**Key Features**:
- 🤖 AI-generated themed puzzles (Animals, Countries, Technology, Food, Sports, etc.)
- 🎚️ Three difficulty levels (Simple, Medium, Hard)
- 📅 Daily challenges
- 🏆 Achievement system
- 📊 Statistics tracking
- 💡 Hint system
- 📱 Offline mode
- 👥 Social features (leaderboards, friend challenges)

## 📚 Documentation

### For Developers

| Document | Purpose |
|----------|---------|
| **[GETTING_STARTED.md](docs/GETTING_STARTED.md)** | **START HERE** - Quick start guide and workflow |
| **[PROGRESS.md](docs/PROGRESS.md)** | Detailed implementation checklist with checkboxes |
| **[REQUIREMENTS.md](docs/REQUIREMENTS.md)** | Complete feature requirements and Firebase schema |
| **[TECHNICAL_SETUP.md](docs/TECHNICAL_SETUP.md)** | Step-by-step setup instructions |
| **[CLAUDE.md](CLAUDE.md)** | Architecture guide for Claude Code |

### Quick Links
- 🚀 [Get Started in 30 Minutes](docs/GETTING_STARTED.md#-quick-start-30-minutes)
- 📋 [Track Your Progress](docs/PROGRESS.md)
- 🔧 [Setup Firebase](docs/TECHNICAL_SETUP.md#step-1-firebase-project-setup)
- 📊 [View Firebase Schema](docs/REQUIREMENTS.md#33-firebase-schema)

## 🛠️ Tech Stack

**Frontend**:
- Flutter 3.9.2+
- Dart 3.0+
- Provider (state management)
- Hive (local caching)

**Backend**:
- Firebase Authentication
- Cloud Firestore
- Cloud Functions (Node.js/TypeScript)
- Firebase Analytics & Crashlytics

**AI Integration**:
- OpenAI ChatGPT API (or Claude, Gemini)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.9.2+
- Firebase account
- OpenAI API key
- Node.js 18+ (for Cloud Functions)

### Installation

1. **Clone and setup**
```bash
git clone <your-repo>
cd word-search
flutter pub get
```

2. **Configure Firebase**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

3. **Run the app**
```bash
flutter run -d chrome
# or
flutter run -d windows
```

4. **Next Steps**
- Follow [GETTING_STARTED.md](docs/GETTING_STARTED.md) for detailed setup
- Start checking off tasks in [PROGRESS.md](docs/PROGRESS.md)

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🗂️ Project Structure

```
word-search/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── services/              # Business logic
│   ├── providers/             # State management
│   ├── screens/               # UI screens
│   ├── widgets/               # Reusable widgets
│   └── utils/                 # Utilities
├── functions/                 # Firebase Cloud Functions
│   └── src/
│       ├── index.ts
│       ├── puzzleGenerator.ts
│       └── aiService.ts
├── docs/                      # Documentation
│   ├── GETTING_STARTED.md
│   ├── PROGRESS.md
│   ├── REQUIREMENTS.md
│   └── TECHNICAL_SETUP.md
└── test/                      # Tests

```

## 🎮 How It Works

### Architecture: GitHub Actions (Recommended - FREE!)

1. **Puzzle Generation** (GitHub Actions - Scheduled)
   - GitHub Action runs daily (or on-demand)
   - **Smart inventory management** - only generates when needed
   - Checks puzzle inventory and user consumption rate
   - Calls ChatGPT API with theme and difficulty
   - AI generates themed word list
   - Algorithm places words in grid
   - Batch upload to Firestore
   - **Cost**: $0.25-0.35/month (saves 30-50% vs. always generating)

2. **Puzzle Playing** (Client-side)
   - App fetches pre-generated puzzles from Firestore
   - User selects letters to find words
   - Progress tracked and synced to Firebase
   - Statistics and achievements updated

3. **Daily Challenge** (Scheduled)
   - GitHub Action selects/generates puzzle of the day
   - Updates Firestore daily challenge collection
   - Users compete on leaderboard

**See**: [GitHub Actions Setup Guide](docs/GITHUB_ACTIONS_SETUP.md) for implementation

### Alternative: Cloud Functions (Requires Firebase Blaze Plan)
- Real-time on-demand puzzle generation
- User-triggered puzzle creation
- Requires Firebase Blaze plan (~$15-45/month)

## 📈 Development Phases

### ✅ Phase 1: MVP (Weeks 1-6)
- Core puzzle generation and playing
- Firebase integration
- User authentication
- Daily challenges
- **Status**: Not started - See [PROGRESS.md](docs/PROGRESS.md)

### ⏳ Phase 2: Enhancement (Weeks 7-10)
- Achievement system
- Statistics dashboard
- Hint system
- Offline mode
- UI polish

### ⏳ Phase 3: Social (Weeks 11-14)
- Leaderboards
- Friend system
- Share functionality
- Push notifications

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models/puzzle_test.dart

# Run with coverage
flutter test --coverage
```

## 🚢 Deployment

### Cloud Functions
```bash
firebase deploy --only functions
```

### Android
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
firebase deploy --only hosting
```

## 📊 Current Progress

**Phase**: Setup & Configuration
**Overall Progress**: 0%
**Last Updated**: 2025-10-27

See [PROGRESS.md](docs/PROGRESS.md) for detailed tracking.

## 🤝 Contributing

1. Check [PROGRESS.md](docs/PROGRESS.md) for available tasks
2. Pick an unchecked task
3. Implement and test
4. Check off the task
5. Commit with conventional commit message
6. Create pull request

## 📄 License

This project is private. See LICENSE file for details.

## 🆘 Support

- **Documentation**: Check [docs/](docs/) folder
- **Setup Issues**: See [TECHNICAL_SETUP.md](docs/TECHNICAL_SETUP.md#troubleshooting)
- **Feature Questions**: See [REQUIREMENTS.md](docs/REQUIREMENTS.md)

## 🎉 Acknowledgments

- Flutter team for amazing framework
- Firebase for backend infrastructure
- OpenAI for ChatGPT API
- Community for inspiration and support

---

**Ready to start building?** 👉 [Get Started Now](docs/GETTING_STARTED.md)

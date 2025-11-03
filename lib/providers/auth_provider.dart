import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProgressService _progressService = ProgressService();

  UserProfile? _currentProfile;
  bool _isLoading = true;
  String? _error;

  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSignedIn => _currentProfile != null && !_currentProfile!.isGuest;
  bool get isGuest => _currentProfile != null && _currentProfile!.isGuest;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize progress service
      await _progressService.initialize();

      // Check if user is signed in
      final user = _authService.currentUser;

      if (user != null) {
        // Load signed-in user profile
        _currentProfile = await _authService.getUserProfile(user.uid);
      } else {
        // Load guest profile from local storage
        _currentProfile = _progressService.loadGuestProfileLocally();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentProfile = UserProfile.guest(); // Fallback to guest
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        // User signed out
        _currentProfile = UserProfile.guest();
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      _currentProfile = await _authService.getUserProfile(userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInAsGuest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _authService.signInAsGuest();
      await _progressService.saveGuestProfileLocally(_currentProfile!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final oldProfile = _currentProfile;
      _currentProfile =
          await _authService.signInWithEmailPassword(email, password);

      // Migrate guest progress if user was a guest
      if (oldProfile != null &&
          oldProfile.isGuest &&
          _currentProfile!.userId != null) {
        await _authService.migrateGuestProgress(
          oldProfile,
          _currentProfile!.userId!,
        );
        // Clear local guest data
        await _progressService.clearGuestData();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final oldProfile = _currentProfile;
      _currentProfile = await _authService.signUpWithEmailPassword(
        email,
        password,
        displayName,
      );

      // Migrate guest progress if user was a guest
      if (oldProfile != null &&
          oldProfile.isGuest &&
          _currentProfile!.userId != null) {
        await _authService.migrateGuestProgress(
          oldProfile,
          _currentProfile!.userId!,
        );
        // Clear local guest data
        await _progressService.clearGuestData();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final oldProfile = _currentProfile;
      _currentProfile = await _authService.signInWithGoogle();

      // Migrate guest progress if user was a guest
      if (oldProfile != null &&
          oldProfile.isGuest &&
          _currentProfile!.userId != null) {
        await _authService.migrateGuestProgress(
          oldProfile,
          _currentProfile!.userId!,
        );
        // Clear local guest data
        await _progressService.clearGuestData();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final oldProfile = _currentProfile;
      _currentProfile = await _authService.signInWithApple();

      // Migrate guest progress if user was a guest
      if (oldProfile != null &&
          oldProfile.isGuest &&
          _currentProfile!.userId != null) {
        await _authService.migrateGuestProgress(
          oldProfile,
          _currentProfile!.userId!,
        );
        // Clear local guest data
        await _progressService.clearGuestData();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentProfile = UserProfile.guest();
      await _progressService.saveGuestProfileLocally(_currentProfile!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      if (profile.isGuest) {
        await _progressService.saveGuestProfileLocally(profile);
      } else if (profile.userId != null) {
        await _authService.updateUserProfile(profile);
      }

      _currentProfile = profile;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

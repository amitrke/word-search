import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Sign in anonymously (guest mode)
  Future<UserProfile> signInAsGuest() async {
    try {
      // For guest mode, we don't actually sign in to Firebase
      // We just return a guest profile
      return UserProfile.guest();
    } catch (e) {
      throw Exception('Failed to start as guest: $e');
    }
  }

  // Sign in with email and password
  Future<UserProfile> signInWithEmailPassword(
      String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Get user profile from Firestore
        final userProfile = await getUserProfile(result.user!.uid);
        return userProfile;
      } else {
        throw Exception('Sign in failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<UserProfile> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(displayName);

        // Create user profile in Firestore
        final userProfile = UserProfile(
          userId: result.user!.uid,
          displayName: displayName,
          isGuest: false,
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userProfile.toFirestore());

        return userProfile;
      } else {
        throw Exception('Sign up failed');
      }
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in with Google
  Future<UserProfile> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result =
          await _auth.signInWithCredential(credential);

      if (result.user != null) {
        // Check if user profile exists, create if not
        final userProfile = await getUserProfile(result.user!.uid);
        return userProfile;
      } else {
        throw Exception('Google sign in failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Sign in with Apple
  Future<UserProfile> signInWithApple() async {
    try {
      // Request credential for Apple ID
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential result =
          await _auth.signInWithCredential(oauthCredential);

      if (result.user != null) {
        // For Apple sign-in, we might need to update the display name from the credential
        if (appleCredential.givenName != null &&
            appleCredential.familyName != null) {
          final displayName =
              '${appleCredential.givenName} ${appleCredential.familyName}';
          await result.user!.updateDisplayName(displayName);
        }

        // Check if user profile exists, create if not
        final userProfile = await getUserProfile(result.user!.uid);
        return userProfile;
      } else {
        throw Exception('Apple sign in failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in with Apple: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get user profile from Firestore
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserProfile.fromFirestore(userId, doc.data()!);
      } else {
        // Create new profile if it doesn't exist
        final newProfile = UserProfile(
          userId: userId,
          displayName: currentUser?.displayName ?? 'User',
          isGuest: false,
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .set(newProfile.toFirestore());

        return newProfile;
      }
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(UserProfile profile) async {
    if (profile.userId == null) {
      throw Exception('Cannot update guest profile');
    }

    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Migrate guest progress to signed-in account
  Future<void> migrateGuestProgress(
    UserProfile guestProfile,
    String newUserId,
  ) async {
    try {
      // Create or update user profile with guest's progress
      final userProfile = UserProfile(
        userId: newUserId,
        displayName: currentUser?.displayName ?? 'User',
        isGuest: false,
        currentLevel: guestProfile.currentLevel,
        highestCompletedLevel: guestProfile.highestCompletedLevel,
        totalPuzzlesCompleted: guestProfile.totalPuzzlesCompleted,
      );

      await updateUserProfile(userProfile);
    } catch (e) {
      throw Exception('Failed to migrate guest progress: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
}

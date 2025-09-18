import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser?.authType == AuthType.guest;

  AuthProvider() {
    _loadUserFromStorage();
  }

  // Load user from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        // In a real app, you would parse JSON and create User object
        _currentUser = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  // Save user to local storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', user.toJson());
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  // Clear user from storage
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      debugPrint('Error clearing user from storage: $e');
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would make an API call to your backend
      // For demo purposes, we'll simulate successful login
      if (email.isNotEmpty && password.length >= 6) {
        _currentUser = User(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: email.split('@')[0],
          authType: AuthType.email,
          createdAt: DateTime.now(),
          isFirstTime: false, // Returning user
        );
        
        await _saveUserToStorage(_currentUser!);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would make an API call to your backend
      // For demo purposes, we'll simulate successful signup
      if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
        _currentUser = User(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          authType: AuthType.email,
          createdAt: DateTime.now(),
          isFirstTime: true, // New user needs onboarding
        );
        
        await _saveUserToStorage(_currentUser!);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        throw Exception('Please fill all fields correctly');
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would integrate with Firebase Auth or Google Sign-In
      // For demo purposes, we'll simulate successful Google login
      _currentUser = User(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        name: 'Google User',
        authType: AuthType.google,
        photoUrl: 'https://lh3.googleusercontent.com/a/default-user=s96-c',
        createdAt: DateTime.now(),
        isFirstTime: true, // Assume first time for demo
      );
      
      await _saveUserToStorage(_currentUser!);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Google sign-in failed');
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would integrate with Firebase Auth or Apple Sign-In
      // For demo purposes, we'll simulate successful Apple login
      _currentUser = User(
        id: 'apple_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@icloud.com',
        name: 'Apple User',
        authType: AuthType.apple,
        createdAt: DateTime.now(),
        isFirstTime: true, // Assume first time for demo
      );
      
      await _saveUserToStorage(_currentUser!);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Apple sign-in failed');
      _setLoading(false);
      return false;
    }
  }

  // Sign in as guest
  Future<void> signInAsGuest() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: '',
        name: 'Guest User',
        authType: AuthType.guest,
        createdAt: DateTime.now(),
        isFirstTime: true, // Guest needs onboarding
      );
      
      await _saveUserToStorage(_currentUser!);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to continue as guest');
      _setLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would call your backend to send reset email
      // For demo purposes, we'll just simulate success
      if (email.contains('@')) {
        _setLoading(false);
        // Success - email sent
      } else {
        throw Exception('Invalid email address');
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _clearUserFromStorage();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      // In a real app, you would call your backend to delete the account
      await Future.delayed(const Duration(seconds: 2));
      
      await _clearUserFromStorage();
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete account');
      _setLoading(false);
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      // In a real app, you would call your backend to update profile
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
      );
      
      await _saveUserToStorage(_currentUser!);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile');
      _setLoading(false);
      rethrow;
    }
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(isFirstTime: false);
    await _saveUserToStorage(_currentUser!);
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user session is valid
  bool isSessionValid() {
    if (_currentUser == null) return false;
    
    // In a real app, you might check token expiration
    // For demo purposes, we'll assume session is always valid
    return true;
  }

  // Refresh user session
  Future<void> refreshSession() async {
    if (_currentUser == null) return;

    try {
      // In a real app, you would refresh the auth token
      // For demo purposes, we'll just reload from storage
      await _loadUserFromStorage();
    } catch (e) {
      debugPrint('Error refreshing session: $e');
    }
  }
}
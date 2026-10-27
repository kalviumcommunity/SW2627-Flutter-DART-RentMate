import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'web_auth_adapter.dart';

/// User profile model representing an authenticated Google operator.
class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? accessToken;
  final User? firebaseUser;
  final String role;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.accessToken,
    this.firebaseUser,
    this.role = 'warehouse',
  });

  /// Creates an [AuthUser] instance from a Firebase [User].
  factory AuthUser.fromFirebaseUser(User user, {String? accessToken, String role = 'warehouse'}) {
    String name = user.displayName ?? '';
    if (name.isEmpty && user.email != null && user.email!.contains('@')) {
      final part = user.email!.split('@').first;
      name = part.isNotEmpty
          ? part[0].toUpperCase() + part.substring(1)
          : 'Google User';
    }

    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: name.isNotEmpty ? name : 'Google User',
      photoUrl: user.photoURL,
      accessToken: accessToken,
      firebaseUser: user,
      role: role,
    );
  }

  /// Legacy mapper from raw Google userinfo JSON (fallback).
  factory AuthUser.fromGoogleUserInfo(Map<String, dynamic> json, String accessToken, {String role = 'coordinator'}) {
    final rawName = json['name']?.toString();
    final name = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (json['email'] != null && json['email'].toString().contains('@')
            ? json['email'].toString().split('@').first
            : 'Google User');

    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: name,
      photoUrl: json['picture']?.toString(),
      accessToken: accessToken,
      role: role,
    );
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? accessToken,
    User? firebaseUser,
    String? role,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      accessToken: accessToken ?? this.accessToken,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      role: role ?? this.role,
    );
  }
}

/// Production Authentication Service for RentFlow handling Google OAuth via Firebase.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Google Web Client ID injected securely at build/run time via --dart-define=GOOGLE_WEB_CLIENT_ID=...
  static const String activeClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  AuthUser? _currentUser;

  /// Sets the active current user in-memory and caches the normalized role.
  void setCurrentUser(AuthUser? user) {
    _currentUser = user;
    if (user != null && user.role.isNotEmpty) {
      _roleMemoryCache[user.id.toLowerCase().trim()] = normalizeRole(user.role);
    }
  }

  /// Returns true if Firebase has been initialized in the current runtime.
  bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  /// Returns the current authenticated [AuthUser], syncing with Firebase when available.
  AuthUser? get currentUser {
    if (_currentUser != null) return _currentUser;
    if (isFirebaseInitialized && FirebaseAuth.instance.currentUser != null) {
      _currentUser = AuthUser.fromFirebaseUser(FirebaseAuth.instance.currentUser!);
    }
    return _currentUser;
  }

  /// Direct access to underlying Firebase User if signed in.
  User? get currentFirebaseUser =>
      isFirebaseInitialized ? FirebaseAuth.instance.currentUser : null;

  /// Returns true if an active authenticated session exists.
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes from Firebase Auth.
  Stream<AuthUser?> get authStateChanges {
    if (!isFirebaseInitialized) return const Stream.empty();
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user != null) {
        _currentUser = AuthUser.fromFirebaseUser(user);
        return _currentUser;
      }
      _currentUser = null;
      return null;
    });
  }

  static final Map<String, String> _roleMemoryCache = {
    'mayank@rentflow.ops': 'coordinator',
  };

  /// Retrieves cached role synchronously without awaiting SharedPreferences/Firestore.
  /// Fails closed to 'warehouse' if missing.
  String getCachedUserRole(String? uid) {
    if (uid != null && uid.isNotEmpty) {
      final key = uid.toLowerCase().trim();
      if (_roleMemoryCache.containsKey(key)) {
        return _roleMemoryCache[key]!;
      }
    }
    return 'warehouse';
  }

  /// Normalizes a role string into one of standard roles: 'coordinator', 'warehouse', 'admin'.
  /// Fails closed to 'warehouse' for any unapproved or unknown roles.
  static String normalizeRole(String rawRole) {
    final lower = rawRole.toLowerCase().trim();
    if (lower == 'admin' || lower.contains('administrator')) {
      return 'admin';
    } else if (lower.contains('coordinator')) {
      return 'coordinator';
    } else if (lower == 'warehouse' || lower.contains('dispatcher') || lower == 'operator' || lower.contains('crew')) {
      return 'warehouse';
    }
    return 'warehouse';
  }

  /// Reads the authenticated user's role from Firestore with fallback to local cache.
  /// Fails closed to 'warehouse' for unknown or missing user profiles.
  Future<String> getUserRole([String? uid]) async {
    final targetUid = uid ?? currentFirebaseUser?.uid ?? _currentUser?.id;
    if (targetUid != null && targetUid.isNotEmpty) {
      final key = targetUid.toLowerCase().trim();
      if (_roleMemoryCache.containsKey(key)) {
        return _roleMemoryCache[key]!;
      }
      if (isFirebaseInitialized) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(targetUid).get();
          if (doc.exists && doc.data() != null) {
            final role = doc.data()!['role']?.toString();
            if (role != null && role.isNotEmpty) {
              final normalized = normalizeRole(role);
              await _cacheUserRole(targetUid, normalized);
              return normalized;
            }
          }
        } catch (e) {
          debugPrint('Firestore getUserRole error: $e');
        }
      }

      // Check SharedPreferences cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('rentflow_user_role_$targetUid');
        if (cached != null && cached.isNotEmpty) {
          final normalized = normalizeRole(cached);
          _roleMemoryCache[key] = normalized;
          return normalized;
        }
      } catch (_) {}
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getString('rentflow_current_role');
      if (current != null && current.isNotEmpty) {
        return normalizeRole(current);
      }
    } catch (_) {}

    return 'warehouse';
  }

  /// Writes the user's role to Firestore and updates local cache.
  Future<void> setUserRole(String uid, String role) async {
    final normalized = normalizeRole(role);
    final targetUid = currentFirebaseUser?.uid ?? uid;
    _roleMemoryCache[targetUid.toLowerCase().trim()] = normalized;
    _roleMemoryCache[uid.toLowerCase().trim()] = normalized;

    if (isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(targetUid).set({
          'role': normalized,
          'email': currentUser?.email ?? uid,
          'displayName': currentUser?.displayName ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore setUserRole error: $e');
      }
    }
    await _cacheUserRole(targetUid, normalized);
    if (targetUid != uid) {
      await _cacheUserRole(uid, normalized);
    }
  }

  Future<void> _cacheUserRole(String uid, String role) async {
    _roleMemoryCache[uid.toLowerCase().trim()] = role;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rentflow_user_role_$uid', role);
      await prefs.setString('rentflow_current_role', role);
    } catch (_) {}
  }

  /// Initiates Google OAuth sign-in using Firebase Authentication across Web and Mobile.
  ///
  /// - On Web: Uses [FirebaseAuth.signInWithPopup] with [GoogleAuthProvider].
  /// - On Mobile (Android/iOS): Uses [GoogleSignIn] to retrieve credentials and signs into [FirebaseAuth].
  Future<AuthUser?> signInWithGoogle() async {
    if (!isFirebaseInitialized) {
      debugPrint('AuthService: Firebase not initialized.');
      return null;
    }

    try {
      if (kIsWeb) {
        // Web Google Sign-In with Firebase Popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);

        if (userCredential.user != null) {
          _currentUser = AuthUser.fromFirebaseUser(
            userCredential.user!,
            accessToken: userCredential.credential?.accessToken,
          );
          debugPrint('Firebase Google Auth Web success: ${_currentUser?.email}');
          return _currentUser;
        }
      } else {
        if (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.windows) {
          throw UnsupportedError('Google Workspace sign-in on desktop requires browser redirect or web build.');
        }

        // Native Android / iOS Google Sign-In
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          debugPrint('Google Sign-In aborted by user.');
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          _currentUser = AuthUser.fromFirebaseUser(
            userCredential.user!,
            accessToken: googleAuth.accessToken,
          );
          debugPrint('Firebase Google Auth Mobile success: ${_currentUser?.email}');
          return _currentUser;
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error [${e.code}]: ${e.message}');
      if (e.code == 'popup-closed-by-user' || e.code == 'canceled') {
        return null;
      }
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In generic error: $e');
      rethrow;
    }

    return null;
  }

  /// Detects and processes Google OAuth redirect callback on page load.
  ///
  /// Checks Firebase redirect results first, then handles legacy token fragments.
  Future<AuthUser?> checkOAuthRedirect() async {
    if (!kIsWeb) return null;

    try {
      // 1. Check Firebase Auth redirect result
      if (isFirebaseInitialized) {
        try {
          final redirectResult = await FirebaseAuth.instance.getRedirectResult();
          if (redirectResult.user != null) {
            _currentUser = AuthUser.fromFirebaseUser(redirectResult.user!);
            debugPrint('Firebase redirect user recovered: ${_currentUser?.email}');
            return _currentUser;
          }
        } catch (e) {
          debugPrint('Firebase getRedirectResult error: $e');
        }
      }

      // 2. Fallback check for URL fragment token (e.g. #access_token=...)
      final currentUrl = getWebCurrentUrl();
      if (currentUrl.isNotEmpty) {
        final uri = Uri.parse(currentUrl);
        String? token;

        if (uri.hasFragment && uri.fragment.contains('access_token=')) {
          final params = Uri.splitQueryString(uri.fragment);
          token = params['access_token'];
        } else if (uri.queryParameters.containsKey('access_token')) {
          token = uri.queryParameters['access_token'];
        }

        if (token != null && token.isNotEmpty) {
          debugPrint('Processing legacy OAuth callback token...');
          final response = await http.get(
            Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            _currentUser = AuthUser.fromGoogleUserInfo(data, token);
            replaceWebHistoryState(uri.path);
            return _currentUser;
          }
        }
      }
    } catch (e) {
      debugPrint('OAuth redirect error: $e');
    }

    return null;
  }

  /// Direct browser redirection to Google's official Sign In page (Web Fallback)
  void redirectToGoogleSignIn() {
    if (!kIsWeb) return;

    if (isFirebaseInitialized) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      FirebaseAuth.instance.signInWithRedirect(googleProvider);
      return;
    }

    if (activeClientId.isEmpty) {
      debugPrint('Google OAuth Client ID is not configured. Provide via --dart-define=GOOGLE_WEB_CLIENT_ID=...');
      return;
    }

    final redirectUri = getWebRedirectUri();
    final googleAuthUrl = Uri.https(
      'accounts.google.com',
      '/o/oauth2/v2/auth',
      {
        'client_id': activeClientId,
        'redirect_uri': redirectUri,
        'response_type': 'token',
        'scope': 'openid email profile https://www.googleapis.com/auth/userinfo.profile',
        'prompt': 'select_account',
        'include_granted_scopes': 'true',
      },
    ).toString();

    navigateWebTo(googleAuthUrl);
  }

  /// Signs out the current user from Firebase and Google Sign-In.
  Future<void> signOut() async {
    try {
      if (isFirebaseInitialized) {
        await FirebaseAuth.instance.signOut();
      }
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    } catch (e) {
      debugPrint('SignOut error: $e');
    } finally {
      _currentUser = null;
    }
  }
}

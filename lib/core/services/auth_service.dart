import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// User profile model representing an authenticated Google operator.
class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? accessToken;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.accessToken,
  });

  factory AuthUser.fromGoogleUserInfo(Map<String, dynamic> json, String accessToken) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['name']?.toString() ??
          (json['email'] != null ? json['email'].toString().split('@').first : 'Google User'),
      photoUrl: json['picture']?.toString(),
      accessToken: accessToken,
    );
  }
}

/// Production Authentication Service for RentFlow handling direct Google OAuth 2.0.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Google Web Client ID
  static const String activeClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '656620374032-2eq1mrnteosmb4gukgl90cp4pmpq73vu.apps.googleusercontent.com',
  );

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Detects and processes Google OAuth redirect callback on page load (e.g. #access_token=...)
  Future<AuthUser?> checkOAuthRedirect() async {
    if (!kIsWeb) return null;

    try {
      final currentUrl = html.window.location.href;
      final uri = Uri.parse(currentUrl);

      String? token;

      // Extract access_token from URL fragment
      if (uri.hasFragment && uri.fragment.contains('access_token=')) {
        final params = Uri.splitQueryString(uri.fragment);
        token = params['access_token'];
      } else if (uri.queryParameters.containsKey('access_token')) {
        token = uri.queryParameters['access_token'];
      }

      if (token != null && token.isNotEmpty) {
        debugPrint('Processing Google OAuth callback token...');
        
        final response = await http.get(
          Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          _currentUser = AuthUser.fromGoogleUserInfo(data, token);
          debugPrint('Authenticated Google User: ${_currentUser?.email}');

          // Clean URL fragment
          html.window.history.replaceState({}, '', uri.path);

          return _currentUser;
        }
      }
    } catch (e) {
      debugPrint('OAuth redirect error: $e');
    }

    return null;
  }

  /// Direct browser redirection to Google's official Sign In page
  void redirectToGoogleSignIn() {
    if (!kIsWeb) return;

    final redirectUri = '${html.window.location.protocol}//${html.window.location.host}';

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

    // Browser navigation to Google Accounts
    html.window.location.href = googleAuthUrl;
  }

  /// Sign out
  void signOut() {
    _currentUser = null;
  }
}

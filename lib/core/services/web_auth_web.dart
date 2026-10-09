// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Browser-specific implementation for Web OAuth redirection.
String getWebCurrentUrl() => html.window.location.href;

String getWebRedirectUri() =>
    '${html.window.location.protocol}//${html.window.location.host}';

void replaceWebHistoryState(String path) {
  html.window.history.replaceState({}, '', path);
}

void navigateWebTo(String url) {
  html.window.location.href = url;
}

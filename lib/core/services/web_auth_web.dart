import 'package:web/web.dart' as web;

/// Browser-specific implementation for Web OAuth redirection using modern package:web.
String getWebCurrentUrl() => web.window.location.href;

String getWebRedirectUri() =>
    '${web.window.location.protocol}//${web.window.location.host}';

void replaceWebHistoryState(String path) {
  web.window.history.replaceState(null, '', path);
}

void navigateWebTo(String url) {
  web.window.location.href = url;
}

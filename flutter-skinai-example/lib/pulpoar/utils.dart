import 'events.dart';

/// JavaScript channel name registered on the Flutter WebView.
const pulpoArChannelName = 'PulpoAR';

/// Builds the script that loads `@pulpoar/plugin-sdk` and forwards events
/// to Flutter via [pulpoArChannelName].postMessage.
///
/// Mirrors the React Native / Kotlin examples:
/// CDN SDK load → subscribe to events → post `{ event, payload }` to native.
String getInitialSdkScript({
  List<String> events = skinAiEvents,
}) {
  final subscriptions = events.map(_makeSdkEvent).join('\n');

  return '''
(function () {
  if (window.__pulpoarSdkInjected) return;
  window.__pulpoarSdkInjected = true;

  const script = document.createElement('script');
  script.src = 'https://cdn.jsdelivr.net/npm/@pulpoar/plugin-sdk@latest/dist/index.iife.js';
  script.onload = function () {
$subscriptions
  };
  document.body.appendChild(script);
})();
''';
}

String _makeSdkEvent(String eventName) {
  return '''
    pulpoar['$eventName']((payload) => {
      $pulpoArChannelName.postMessage(JSON.stringify({
        event: '$eventName',
        payload: payload === undefined ? null : payload
      }));
    });''';
}

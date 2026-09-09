# SkinAI v3 Plugin SDK - Flutter Example

Flutter integration example demonstrating SkinAI v3 plugin integration with WebView, JavaScript ↔ Dart event bridging, and native camera permissions.

> **SDK Documentation**: For complete event documentation, type definitions, and integration guides, see the [main README](../README.md).

## Features

- **Full SkinAI v3 integration**: Complete skin analysis experience in a Flutter app
- **Event logging**: Real-time monitoring of 17+ SDK events via debug console + in-app log sheet
- **Camera permissions**: Native camera permission handling for Android and iOS
- **WebView bridge**: JavaScript-to-Dart communication via `JavaScriptChannel` (`PulpoAR`)

## Prerequisites

- **Flutter**: 3.22+ (stable)
- **Dart**: 3.4+
- **For iOS**: macOS with Xcode 15+
- **For Android**: Android Studio and SDK (API 24+)
- **Device**: Camera support required for full functionality (prefer a physical device)

## Quick Start

### 1. Install Dependencies

```bash
cd flutter-skinai-example
flutter pub get
```

### 2. Configure Plugin URL

Edit `lib/main.dart` and set your project slug:

```dart
static const projectSlug = 'YOUR_PROJECT_SLUG';
```

The WebView loads:

```text
https://plugin.pulpoar.com/skinai/{slug}
```

### 3. Run the App

```bash
flutter run
```

## Project Structure

```
flutter-skinai-example/
├── lib/
│   ├── main.dart                 # Sample app + event handlers
│   └── pulpoar/
│       ├── pulpoar.dart          # Exports
│       ├── pulpoar_view.dart     # WebView widget + bridge
│       ├── events.dart           # Event names + handler typedef
│       └── utils.dart            # SDK injection script
├── android/                      # Android permissions + WebView config
├── ios/                          # iOS Info.plist camera usage
├── pubspec.yaml
└── README.md
```

## How the Bridge Works

1. Flutter opens `https://plugin.pulpoar.com/skinai/{slug}` in a WebView
2. On page load, it injects `@pulpoar/plugin-sdk` from CDN
3. Each SDK event is subscribed and forwarded with:

```js
PulpoAR.postMessage(JSON.stringify({ event: 'onAddToCart', payload }));
```

4. Dart receives the message on the `PulpoAR` JavaScript channel and calls `onEvent`

This mirrors the React Native (`ReactNativeWebView.postMessage`) and Kotlin (`AndroidInterface`) examples.

## Viewing Events

- Debug console: lines prefixed with `[SkinAI]`
- In-app: tap the receipt icon in the app bar to open the event log sheet

## SDK Integration Reference

```dart
PulpoARView(
  plugin: 'skinai',
  slug: 'demo',
  onEvent: (event, payload) {
    switch (event) {
      case 'onAddToCart':
        // payload?['products'] → add to your cart
        break;
      case 'onRecommendationsReceive':
        // payload?['products'], payload?['routines']
        break;
      case 'onProductVisit':
        // Navigate to your PDP — required in WebView embeds
        break;
      case 'onSkinScoreCalculate':
        // Associate analysis with the logged-in user
        break;
    }
  },
);
```

For complete SDK documentation, see:

- **[SDK Events Reference](../README.md#sdk-events-18-total)**
- **[Type Definitions](../README.md#type-definitions)**
- **[Integration Guide](../README.md#integration-guide)**

## Permissions

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS (`Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>This app requires camera access for skin analysis.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to upload photos for skin analysis.</string>
```

## Customization

### Subscribe to fewer events

```dart
PulpoARView(
  plugin: 'skinai',
  slug: 'demo',
  events: const [
    'onReady',
    'onAddToCart',
    'onRecommendationsReceive',
    'onProductVisit',
  ],
  onEvent: _handleEvent,
);
```

### Associate events with a logged-in user

Handle identity in Dart when the callback arrives — SkinAI does not know your auth session:

```dart
onEvent: (event, payload) {
  final userId = authService.currentUserId;
  analytics.track(event, {
    ...?payload,
    'userId': userId,
  });
},
```

## Troubleshooting

### Events not firing
- Confirm the slug is correct and the device has network access
- Check debug logs for WebView / bridge parse errors
- Ensure JavaScript mode is unrestricted (already configured in `PulpoARView`)

### Camera not working
- Grant camera permission when prompted
- Prefer a physical device (simulator camera support is limited)
- On iOS, verify `NSCameraUsageDescription` is present

### Blank WebView
- Verify internet connectivity
- Confirm `https://plugin.pulpoar.com/skinai/{slug}` loads in a mobile browser

## Platform Notes

### iOS
- Uses WKWebView via `webview_flutter_wkwebview`
- Inline media playback enabled for camera streams

### Android
- Uses Android WebView via `webview_flutter_android`
- Grants WebView camera permission requests after native permission approval

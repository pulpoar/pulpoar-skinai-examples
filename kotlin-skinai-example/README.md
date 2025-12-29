# SkinAI v3 Plugin SDK - Kotlin/Android Example

Kotlin/Android integration example demonstrating SkinAI v3 plugin integration with WebView, event monitoring, and native camera permissions.

> **SDK Documentation**: For complete event documentation, type definitions, and integration guides, see the [main README](../README.md).

## Features

- **Full SkinAI v3 integration**: Complete skin analysis experience in a native Android app
- **Event logging**: Real-time monitoring of 17+ SDK events via Logcat
- **Camera permissions**: Automatic native camera permission handling
- **Photo upload support**: File chooser integration for gallery photo uploads
- **WebView bridge**: JavaScript-to-Kotlin communication via `JavascriptInterface`

## Prerequisites

- **Android Studio**: Arctic Fox (2020.3.1) or newer
- **Android SDK**: API 24 (Android 7.0) or higher
- **JDK**: Version 11 or higher
- **Device/Emulator**: Camera support required for full functionality

## Quick Start

### 1. Open the Project

```bash
cd kotlin-skinai-example
```

Open in Android Studio:
- **File** > **Open** > Select `kotlin-skinai-example` folder
- Wait for Gradle sync to complete

### 2. Configure Plugin URL

Edit `PulpoARFragment.kt` (line 141) to use your plugin URL:

```kotlin
webView.loadUrl("https://plugin.pulpoar.com/skinai/YOUR_PROJECT_SLUG")
```

### 3. Build and Run

1. Connect an Android device or start an emulator
2. Click **Run** button (▶️) in Android Studio
3. The app will install and launch automatically

## Project Structure

```
kotlin-skinai-example/
├── app/
│   ├── src/main/java/com/pulpolabs/kotlin_example/
│   │   ├── MainActivity.kt              # Main activity host
│   │   ├── PulpoARFragment.kt           # WebView fragment with SDK integration
│   │   ├── SDKInterface.kt              # JavaScript-to-Kotlin event bridge
│   │   ├── Utils.kt                     # JSON parsing utilities
│   │   └── data/
│   │       └── Events.kt                # Event enum definitions
│   ├── src/main/res/
│   │   └── layout/
│   │       ├── main_activity.xml        # Main activity layout
│   │       └── fragment_web_view.xml    # WebView fragment layout
│   └── build.gradle.kts                 # App-level Gradle config
├── build.gradle.kts                     # Project-level Gradle config
└── README.md                            
```

## Viewing Event Logs

### Using Android Studio Logcat

1. Open **Logcat** panel: **View** > **Tool Windows** > **Logcat**
2. Filter by tag: `PulpoAR SkinAI`
3. Interact with the app to see events in real-time

Example output:
```
D/PulpoAR SkinAI: SDK is ready: {"projectKey":"demo","themeType":"light"}
D/PulpoAR SkinAI: Path changed: {"referer":"root","path":"onboarding"}
D/PulpoAR SkinAI: Skin score calculated: {"skinHealthScore":85,"isSelfie":true,...}
```

## SDK Integration Reference

All 17 SDK events are automatically logged to Logcat via the `SDKInterface` class.

For complete SDK documentation, see:
- **[SDK Events Reference](../README.md#sdk-events-17-total)** - All 17 events with detailed payloads and JavaScript examples
- **[Type Definitions](../README.md#type-definitions)** - ProductWithoutRoutines, RoutineWithoutProducts, SkinIssue, etc.
- **[Integration Guide](../README.md#integration-guide)** - General integration steps

### Kotlin-Specific: Parsing JSON Payloads

In Kotlin, event payloads are received as JSON strings. Parse them using `JSONObject`:

```kotlin
@JavascriptInterface
fun onSkinScoreCalculate(payload: String) {
    val json = JSONObject(payload)
    val score = json.getInt("skinHealthScore")
    val isSelfie = json.getBoolean("isSelfie")
    val issues = json.getJSONArray("issues")

    Log.d("PulpoAR SkinAI", "Skin score: $score, Selfie: $isSelfie")
}

@JavascriptInterface
fun onAddToCart(payload: String) {
    val json = JSONObject(payload)
    val products = json.getJSONArray("products")
    val source = json.getString("source")
    val experience = json.getString("experience")

    // Add your custom cart logic
    for (i in 0 until products.length()) {
        val product = products.getJSONObject(i)
        val productId = product.getString("id")
        val productName = product.getString("name")
        // Add to cart...
    }
}
```

## Customization

### Custom Event Handling

Modify event handlers in `SDKInterface.kt` to add your custom logic:

```kotlin
@JavascriptInterface
fun onAddToCart(payload: String) {
    Log.d("PulpoAR SkinAI", "Add to cart: $payload")

    // Parse the payload
    val json = JSONObject(payload)
    val products = json.getJSONArray("products")
    val source = json.getString("source")

    // Add your custom cart logic here
    activity?.runOnUiThread {
        // Update UI or call your cart API
        addProductsToNativeCart(products)
    }
}
```

### Change Plugin URL

Edit `PulpoARFragment.kt`:
```kotlin
webView.loadUrl("https://plugin.pulpoar.com/skinai/YOUR_SLUG_HERE")
```

### Customize WebView Settings

Modify `initializeWebView()` in `PulpoARFragment.kt`:
```kotlin
webView.settings.apply {
    javaScriptEnabled = true
    domStorageEnabled = true
    // Add more settings as needed
}
```

## Permissions

Required permissions in `AndroidManifest.xml`:

```xml
<!-- Required for plugin to work -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Required for camera functionality -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

## Troubleshooting

### Camera Permission Issues
- **Issue**: Camera not working in WebView
- **Solution**: Grant camera permissions in device Settings > Apps > Your App > Permissions

### Events Not Firing
- **Issue**: No logs appearing in Logcat
- **Solution**:
  1. Check Logcat filter is set to `PulpoAR SkinAI`
  2. Verify JavaScript is enabled in WebView settings
  3. Ensure SDK script is loaded (check `onPageFinished` callback)

### Blank WebView Screen
- **Issue**: WebView shows blank/white screen
- **Solution**:
  1. Check internet connection
  2. Verify plugin URL is correct
  3. Check Logcat for network errors
  4. Ensure `javaScriptEnabled = true`

### File Chooser Not Working
- **Issue**: Can't select photos from gallery
- **Solution**: Verify `onShowFileChooser` is implemented in WebChromeClient

### Build Errors
- **Issue**: Gradle sync or build failures
- **Solution**:
  1. Clean project: **Build** > **Clean Project**
  2. Rebuild: **Build** > **Rebuild Project**
  3. Invalidate caches: **File** > **Invalidate Caches / Restart**

## Browser Compatibility

- **Minimum Android Version**: 7.0 (API 24)
- **WebView Version**: Chromium-based WebView (bundled with Android)
- **Camera Requirements**: Device must have rear or front camera

## Integration Notes

1. **SDK Loading**: The SDK is loaded dynamically via CDN when WebView page finishes loading
   ```kotlin
   // In PulpoARFragment.kt
   override fun onPageFinished(view: WebView?, url: String?) {
       webView.evaluateJavascript(sdk.getInitialSDKScript(...))
   }
   ```

2. **Event Subscription**: Events are subscribed automatically using `JavascriptInterface`
   ```kotlin
   webView.addJavascriptInterface(SDKInterface(), "AndroidInterface")
   ```

3. **Permission Flow**:
   - WebView requests camera → Native permission dialog → Result passed back to WebView
   - All handled automatically in `PulpoARFragment.kt`

4. **Photo Upload**: File chooser integration allows users to select photos from gallery using native Android file picker

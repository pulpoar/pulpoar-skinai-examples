import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'events.dart';
import 'utils.dart';

/// Full-screen SkinAI experience hosted in a WebView with a JS ↔ Dart bridge.
class PulpoARView extends StatefulWidget {
  const PulpoARView({
    super.key,
    this.plugin = 'skinai',
    this.slug = 'demo',
    this.onEvent,
    this.events = skinAiEvents,
  });

  /// Plugin path segment, e.g. `skinai`.
  final String plugin;

  /// Project slug from the PulpoAR console.
  final String slug;

  /// Called for every subscribed SDK event.
  final SkinAiEventHandler? onEvent;

  /// Event names to subscribe to after the plugin SDK loads.
  final List<String> events;

  String get pluginUrl => 'https://plugin.pulpoar.com/$plugin/$slug';

  @override
  State<PulpoARView> createState() => _PulpoARViewState();
}

class _PulpoARViewState extends State<PulpoARView> {
  late final WebViewController _controller;
  var _loading = true;
  var _sdkInjected = false;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _prepareAndLoad();
  }

  WebViewController _createController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        pulpoArChannelName,
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _sdkInjected = false;
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) async {
            await _injectSdk();
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            debugPrint('[SkinAI] WebView error: ${error.description}');
          },
        ),
      );

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      platform.setMediaPlaybackRequiresUserGesture(false);
      platform.setOnPlatformPermissionRequest((request) async {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus.isGranted) {
          request.grant();
        } else {
          request.deny();
          widget.onEvent?.call('onCameraPermissionDeny', null);
        }
      });
    } else if (platform is WebKitWebViewController) {
      platform.setAllowsBackForwardNavigationGestures(true);
    }

    return controller;
  }

  Future<void> _prepareAndLoad() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint('[SkinAI] Camera permission not granted yet');
    }
    await _controller.loadRequest(Uri.parse(widget.pluginUrl));
  }

  Future<void> _injectSdk() async {
    if (_sdkInjected) return;
    _sdkInjected = true;
    await _controller.runJavaScript(
      getInitialSdkScript(events: widget.events),
    );
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[SkinAI] Unexpected bridge payload: ${message.message}');
        return;
      }

      final rawEvent = decoded['event'];
      if (rawEvent is! String || rawEvent.isEmpty) {
        debugPrint('[SkinAI] Bridge message missing string event field: '
            '${message.message}');
        return;
      }
      final event = rawEvent;

      if (!widget.events.contains(event)) {
        debugPrint('[SkinAI] Unhandled/unknown SDK event: $event');
      }

      final rawPayload = decoded['payload'];
      final payload = rawPayload is Map<String, dynamic>
          ? rawPayload
          : rawPayload == null
              ? null
              : <String, dynamic>{'value': rawPayload};

      debugPrint('[SkinAI] $event: ${message.message}');
      widget.onEvent?.call(event, payload);
    } catch (error) {
      debugPrint('[SkinAI] Failed to parse bridge message: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const ColoredBox(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

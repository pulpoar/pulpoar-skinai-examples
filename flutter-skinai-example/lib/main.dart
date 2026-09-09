import 'dart:convert';

import 'package:flutter/material.dart';

import 'pulpoar/pulpoar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkinAiExampleApp());
}

class SkinAiExampleApp extends StatelessWidget {
  const SkinAiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinAI Flutter Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const SkinAiHomePage(),
    );
  }
}

class SkinAiHomePage extends StatefulWidget {
  const SkinAiHomePage({super.key});

  @override
  State<SkinAiHomePage> createState() => _SkinAiHomePageState();
}

class _SkinAiHomePageState extends State<SkinAiHomePage> {
  /// Change this to your PulpoAR console project slug.
  static const projectSlug = 'demo';

  final _eventLog = <String>[];

  void _handleEvent(String event, Map<String, dynamic>? payload) {
    final pretty = payload == null ? 'null' : jsonEncode(payload);
    final line = '[$event] $pretty';

    debugPrint('[SkinAI] $line');
    if (!mounted) return;
    setState(() {
      _eventLog.insert(0, line);
      if (_eventLog.length > 50) {
        _eventLog.removeLast();
      }
    });

    // Associate journey events with the logged-in user in your app:
    // final userId = authService.currentUserId;
    // analytics.track(event, {...payload, 'userId': userId});

    switch (event) {
      case 'onAddToCart':
        // Add payload['products'] to your native cart.
        break;
      case 'onRecommendationsReceive':
        // Persist/show payload['products'] and payload['routines'].
        break;
      case 'onProductVisit':
        // Navigate to your PDP — SkinAI will not open product pages in WebView.
        break;
      case 'onSkinScoreCalculate':
        // Store analysis results for the logged-in user.
        break;
      case 'onExternalProductView':
        // payload['skinAnalysisResult'] + payload['questionsAndAnswers']
        // for a product viewed outside the WebView (e.g. deep link out).
        break;
    }
  }

  void _showEventLog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'SkinAI event log (${_eventLog.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _eventLog.isEmpty
                      ? const Center(child: Text('No events yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _eventLog.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return SelectableText(
                              _eventLog[index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkinAI Flutter Example'),
        actions: [
          IconButton(
            tooltip: 'Event log',
            onPressed: _showEventLog,
            icon: Badge(
              isLabelVisible: _eventLog.isNotEmpty,
              label: Text('${_eventLog.length}'),
              child: const Icon(Icons.receipt_long),
            ),
          ),
        ],
      ),
      body: PulpoARView(
        plugin: 'skinai',
        slug: projectSlug,
        onEvent: _handleEvent,
      ),
    );
  }
}

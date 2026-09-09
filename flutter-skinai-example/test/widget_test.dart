import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_skinai_example/pulpoar/events.dart';
import 'package:flutter_skinai_example/pulpoar/utils.dart';

void main() {
  test('SDK injection script subscribes to SkinAI events', () {
    final script = getInitialSdkScript();

    expect(script, contains("@pulpoar/plugin-sdk@latest"));
    expect(script, contains('$pulpoArChannelName.postMessage'));
    expect(script, contains("pulpoar['onAddToCart']"));
    expect(script, contains("pulpoar['onRecommendationsReceive']"));
    expect(skinAiEvents, contains('onProductVisit'));
    expect(skinAiEvents, contains('onExternalProductView'));
  });
}

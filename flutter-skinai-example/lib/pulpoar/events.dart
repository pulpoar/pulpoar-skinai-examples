/// SkinAI v3 SDK event names that can be bridged from the WebView to Flutter.
const skinAiEvents = <String>[
  'onReady',
  'onError',
  'onPathChange',
  'onOnboardingCarouselChange',
  'onQuestionAnswer',
  'onQuestionnaireComplete',
  'onPhotoUse',
  'onPhotoRetake',
  'onSkinScoreCalculate',
  'onExperienceChange',
  'onRecommendationsReceive',
  'onProductTryClick',
  'onAISimulatorAdjust',
  'onAddToCart',
  'onProductVisit',
  'onEmailButtonClick',
  'onEmailSend',
  'onCameraPermissionDeny',
  'onProblemChipClick',
  'onExternalProductView',
];

/// Callback invoked when a SkinAI event is received from the WebView.
typedef SkinAiEventHandler = void Function(
  String event,
  Map<String, dynamic>? payload,
);

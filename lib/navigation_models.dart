// Navigation models for intent-based routing system
class NavigationResult {
  final String intent;
  final double confidence;
  final String deeplinkPrimary;
  final String deeplinkFallback;
  final String analyticsName;
  final String? displayText;
  final List<QuickReply>? quickReplies;

  const NavigationResult({
    required this.intent,
    required this.confidence,
    required this.deeplinkPrimary,
    required this.deeplinkFallback,
    required this.analyticsName,
    this.displayText,
    this.quickReplies,
  });

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.5;
  bool get hasAmbiguity => quickReplies != null && quickReplies!.isNotEmpty;
}

class QuickReply {
  final String text;
  final String intent;
  final Map<String, dynamic>? params;

  const QuickReply({
    required this.text,
    required this.intent,
    this.params,
  });
}

class IntentPattern {
  final String intent;
  final List<String> keywords;
  final List<String> phrases;
  final double baseConfidence;
  final Map<String, dynamic>? params;

  const IntentPattern({
    required this.intent,
    required this.keywords,
    required this.phrases,
    this.baseConfidence = 0.7,
    this.params,
  });
}

class NavigationRoute {
  final String intent;
  final String primaryDeepLink;
  final String fallbackUrl;
  final String displayName;
  final String analyticsName;
  final String? description;

  const NavigationRoute({
    required this.intent,
    required this.primaryDeepLink,
    required this.fallbackUrl,
    required this.displayName,
    required this.analyticsName,
    this.description,
  });
}

enum LaunchResult {
  success,
  fallbackUsed,
  failed,
}

class DeepLinkResult {
  final LaunchResult result;
  final String? error;
  final String? usedUrl;

  const DeepLinkResult({
    required this.result,
    this.error,
    this.usedUrl,
  });

  bool get isSuccess => result == LaunchResult.success;
  bool get isFallback => result == LaunchResult.fallbackUsed;
  bool get isFailed => result == LaunchResult.failed;
}
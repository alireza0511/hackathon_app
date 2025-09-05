import 'dart:math' as math;
import 'navigation_models.dart';
import 'navigation_map.dart';

class IntentResolver {
  static const double _highConfidenceThreshold = 0.8;
  static const double _mediumConfidenceThreshold = 0.5;
  static const double _ambiguityThreshold = 0.15; // If top 2 scores are within this range, show disambiguation

  /// Main entry point - resolve user message to navigation intent
  static NavigationResult routeFor({required String message}) {
    final normalizedMessage = _normalizeMessage(message);
    final scores = _calculateIntentScores(normalizedMessage);
    
    if (scores.isEmpty) {
      return _createNoRouteResult(message);
    }
    
    final topIntent = scores.first;
    final hasAmbiguity = _hasAmbiguity(scores);
    
    if (hasAmbiguity) {
      return _createAmbiguousResult(scores, message);
    }
    
    return _createNavigationResult(topIntent.intent, topIntent.score, message);
  }

  /// Calculate confidence scores for all intents
  static List<IntentScore> _calculateIntentScores(String normalizedMessage) {
    final scores = <IntentScore>[];
    
    for (final pattern in NavigationMap.patterns) {
      final score = _calculatePatternScore(normalizedMessage, pattern);
      if (score > 0.1) { // Only include non-trivial matches
        scores.add(IntentScore(intent: pattern.intent, score: score));
      }
    }
    
    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  /// Calculate score for a specific pattern
  static double _calculatePatternScore(String message, IntentPattern pattern) {
    double score = 0.0;
    int matchCount = 0;
    
    // Check keyword matches
    for (final keyword in pattern.keywords) {
      if (message.contains(keyword.toLowerCase())) {
        score += 0.3;
        matchCount++;
      }
    }
    
    // Check phrase matches (higher weight)
    for (final phrase in pattern.phrases) {
      if (message.contains(phrase.toLowerCase())) {
        score += 0.5;
        matchCount++;
      }
    }
    
    // Apply base confidence and normalize
    if (matchCount > 0) {
      score = (score * pattern.baseConfidence) / pattern.keywords.length.clamp(1, 5);
      score = math.min(score, 1.0);
    }
    
    // Boost for multiple matches
    if (matchCount > 1) {
      score *= 1.2;
    }
    
    return math.min(score, 1.0);
  }

  /// Check if top intents have ambiguous scoring
  static bool _hasAmbiguity(List<IntentScore> scores) {
    if (scores.length < 2) return false;
    
    final topScore = scores[0].score;
    final secondScore = scores[1].score;
    
    return (topScore - secondScore) <= _ambiguityThreshold && 
           topScore < _highConfidenceThreshold;
  }

  /// Create result for ambiguous cases
  static NavigationResult _createAmbiguousResult(List<IntentScore> scores, String message) {
    final topIntents = scores.take(3).map((s) => s.intent).toList();
    final quickReplies = _generateQuickReplies(topIntents);
    
    return NavigationResult(
      intent: 'ambiguous',
      confidence: scores[0].score,
      deeplinkPrimary: '',
      deeplinkFallback: '',
      analyticsName: 'disambiguation_shown',
      displayText: _generateDisambiguationText(topIntents),
      quickReplies: quickReplies,
    );
  }

  /// Create result when no route found
  static NavigationResult _createNoRouteResult(String message) {
    final suggestedActions = _getSuggestedActions();
    
    return NavigationResult(
      intent: 'no_route',
      confidence: 0.0,
      deeplinkPrimary: '',
      deeplinkFallback: 'https://bank.example.com/help',
      analyticsName: 'no_route_found',
      displayText: "I can help you with banking tasks like transfers, payments, and account management. What would you like to do?",
      quickReplies: suggestedActions,
    );
  }

  /// Create successful navigation result
  static NavigationResult _createNavigationResult(String intent, double confidence, String message) {
    final route = NavigationMap.getRoute(intent);
    if (route == null) {
      return _createNoRouteResult(message);
    }
    
    return NavigationResult(
      intent: intent,
      confidence: confidence,
      deeplinkPrimary: route.primaryDeepLink,
      deeplinkFallback: route.fallbackUrl,
      analyticsName: route.analyticsName,
      displayText: _generateSuccessText(route, confidence),
    );
  }

  /// Generate quick replies for disambiguation
  static List<QuickReply> _generateQuickReplies(List<String> intents) {
    final quickReplies = <QuickReply>[];
    
    for (final intent in intents) {
      final route = NavigationMap.getRoute(intent);
      if (route != null) {
        quickReplies.add(QuickReply(
          text: route.displayName,
          intent: intent,
        ));
      }
    }
    
    return quickReplies;
  }

  /// Get default suggested actions for no route cases
  static List<QuickReply> _getSuggestedActions() {
    return [
      const QuickReply(text: 'Send Money', intent: 'zelle_payment'),
      const QuickReply(text: 'Check Balance', intent: 'account_balance'),
      const QuickReply(text: 'Transfer Funds', intent: 'transfer_funds'),
      const QuickReply(text: 'Pay Bills', intent: 'bill_payment'),
      const QuickReply(text: 'Get Help', intent: 'customer_support'),
    ];
  }

  /// Generate disambiguation text
  static String _generateDisambiguationText(List<String> intents) {
    if (intents.length == 2) {
      final routes = intents.map((i) => NavigationMap.getRoute(i)?.displayName ?? i).toList();
      return "I can help you ${routes[0]} or ${routes[1]}. Which would you prefer?";
    }
    
    return "I found a few things I can help you with. What would you like to do?";
  }

  /// Generate success text based on confidence
  static String _generateSuccessText(NavigationRoute route, double confidence) {
    if (confidence >= _highConfidenceThreshold) {
      return "I can help you ${route.description?.toLowerCase() ?? route.displayName.toLowerCase()}.";
    } else if (confidence >= _mediumConfidenceThreshold) {
      return "It looks like you want to ${route.description?.toLowerCase() ?? route.displayName.toLowerCase()}. Is this correct?";
    } else {
      return "I think you might want to ${route.description?.toLowerCase() ?? route.displayName.toLowerCase()}. Let me know if this helps!";
    }
  }

  /// Normalize message for processing
  static String _normalizeMessage(String message) {
    return message
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Resolve specific intent (for quick replies)
  static NavigationResult resolveIntent({
    required String intent, 
    Map<String, dynamic>? params
  }) {
    final route = NavigationMap.getRoute(intent);
    if (route == null) {
      return _createNoRouteResult('');
    }
    
    return NavigationResult(
      intent: intent,
      confidence: 1.0, // Direct intent resolution is always high confidence
      deeplinkPrimary: route.primaryDeepLink,
      deeplinkFallback: route.fallbackUrl,
      analyticsName: route.analyticsName,
      displayText: "Perfect! ${route.description ?? route.displayName}",
    );
  }

  /// Get all available intents for debugging/testing
  static List<String> getAllIntents() {
    return NavigationMap.patterns.map((p) => p.intent).toSet().toList();
  }
}

/// Internal class for scoring intents
class IntentScore {
  final String intent;
  final double score;
  
  IntentScore({required this.intent, required this.score});
  
  @override
  String toString() => '$intent: ${score.toStringAsFixed(3)}';
}
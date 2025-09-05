import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'navigation_models.dart';

class DeepLinkLauncher {
  static const String _channelName = 'banking_app/deep_links';
  static const MethodChannel _methodChannel = MethodChannel(_channelName);

  // Analytics callback for tracking link launches
  static Function(String analyticsName, LaunchResult result, String? error)? onAnalytics;
  
  // Error callback for non-blocking error handling
  static Function(String error, String? fallbackUrl)? onError;

  /// Launch a deep link with automatic fallback to web URL
  static Future<DeepLinkResult> launch({
    required String primaryUrl,
    required String fallbackUrl,
    required String analyticsName,
  }) async {
    try {
      // First attempt: try custom scheme deep link
      final primaryResult = await _launchUrl(primaryUrl);
      
      if (primaryResult) {
        developer.log('Deep link launched successfully: $primaryUrl');
        onAnalytics?.call(analyticsName, LaunchResult.success, null);
        return DeepLinkResult(
          result: LaunchResult.success,
          usedUrl: primaryUrl,
        );
      }
      
      // Fallback: try HTTPS URL
      final fallbackResult = await _launchUrl(fallbackUrl);
      
      if (fallbackResult) {
        developer.log('Fallback URL launched: $fallbackUrl');
        onAnalytics?.call(analyticsName, LaunchResult.fallbackUsed, null);
        return DeepLinkResult(
          result: LaunchResult.fallbackUsed,
          usedUrl: fallbackUrl,
        );
      }
      
      // Both failed
      const error = 'Both primary and fallback URLs failed to launch';
      developer.log('Launch failed: $error');
      onAnalytics?.call(analyticsName, LaunchResult.failed, error);
      onError?.call(error, fallbackUrl);
      
      return DeepLinkResult(
        result: LaunchResult.failed,
        error: error,
      );
      
    } catch (e) {
      final error = 'Deep link launch exception: ${e.toString()}';
      developer.log(error);
      onAnalytics?.call(analyticsName, LaunchResult.failed, error);
      onError?.call(error, fallbackUrl);
      
      return DeepLinkResult(
        result: LaunchResult.failed,
        error: error,
      );
    }
  }

  /// Launch from NavigationRoute
  static Future<DeepLinkResult> launchRoute(NavigationRoute route) async {
    return launch(
      primaryUrl: route.primaryDeepLink,
      fallbackUrl: route.fallbackUrl,
      analyticsName: route.analyticsName,
    );
  }

  /// Internal method to launch URL via platform channel
  static Future<bool> _launchUrl(String url) async {
    try {
      // For now, we'll simulate the platform channel call
      // In a real implementation, this would call native iOS/Android code
      // to handle URL schemes and fallbacks
      
      // Simulate different success rates for demo purposes
      if (url.startsWith('app://')) {
        // Custom scheme - 70% success rate (simulating app availability)
        return await _simulateAppLaunch(url);
      } else {
        // HTTPS URL - 95% success rate (simulating network/browser availability)
        return await _simulateWebLaunch(url);
      }
      
    } on PlatformException catch (e) {
      developer.log('Platform exception launching URL $url: ${e.message}');
      return false;
    } catch (e) {
      developer.log('Error launching URL $url: ${e.toString()}');
      return false;
    }
  }

  // Simulation methods for demo purposes
  // In production, replace with actual platform channel calls
  static Future<bool> _simulateAppLaunch(String url) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Simulate that some app schemes work, others don't
    return !url.contains('support') && !url.contains('loans');
  }

  static Future<bool> _simulateWebLaunch(String url) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulate high success rate for web URLs
    return true;
  }

  /// Check if a URL can be handled (useful for pre-flight checks)
  static Future<bool> canLaunch(String url) async {
    try {
      return await _methodChannel.invokeMethod('canLaunch', {'url': url}) ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Get suggested alternatives when launch fails
  static List<String> getSuggestedAlternatives(String intent) {
    const alternatives = {
      'zelle_payment': ['Try the mobile app', 'Visit our website', 'Call customer service'],
      'transfer_funds': ['Use mobile banking', 'Visit a branch', 'Call 1-800-BANKING'],
      'customer_support': ['Call 1-800-SUPPORT', 'Visit our help center', 'Chat with us online'],
    };
    
    return alternatives[intent] ?? ['Visit our website', 'Contact customer support'];
  }
}

// Extension for easier NavigationResult launching
extension NavigationResultLauncher on NavigationResult {
  Future<DeepLinkResult> launch() async {
    return DeepLinkLauncher.launch(
      primaryUrl: deeplinkPrimary,
      fallbackUrl: deeplinkFallback,
      analyticsName: analyticsName,
    );
  }
}
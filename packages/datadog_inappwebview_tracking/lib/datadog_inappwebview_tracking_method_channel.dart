import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'datadog_inappwebview_tracking_platform_interface.dart';

/// An implementation of [DatadogInAppWebviewTrackingPlatform] that uses method channels.
class MethodChannelDatadogInappwebviewTracking
    extends DatadogInAppWebviewTrackingPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('datadog_inappwebview_tracking');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

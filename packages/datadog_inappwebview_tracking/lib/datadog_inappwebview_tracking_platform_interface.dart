import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'datadog_inappwebview_tracking_method_channel.dart';

abstract class DatadogInAppWebviewTrackingPlatform extends PlatformInterface {
  /// Constructs a DatadogInappwebviewTrackingPlatform.
  DatadogInAppWebviewTrackingPlatform() : super(token: _token);

  static final Object _token = Object();

  static DatadogInAppWebviewTrackingPlatform _instance =
      MethodChannelDatadogInappwebviewTracking();

  /// The default instance of [DatadogInAppWebviewTrackingPlatform] to use.
  ///
  /// Defaults to [MethodChannelDatadogInappwebviewTracking].
  static DatadogInAppWebviewTrackingPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DatadogInAppWebviewTrackingPlatform] when
  /// they register themselves.
  static set instance(DatadogInAppWebviewTrackingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

import 'package:datadog_inappwebview_tracking/datadog_inappwebview_tracking.dart';
import 'package:datadog_inappwebview_tracking/datadog_inappwebview_tracking_method_channel.dart';
import 'package:datadog_inappwebview_tracking/datadog_inappwebview_tracking_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDatadogInAppWebviewTrackingPlatform
    with MockPlatformInterfaceMixin
    implements DatadogInAppWebviewTrackingPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DatadogInAppWebviewTrackingPlatform initialPlatform =
      DatadogInAppWebviewTrackingPlatform.instance;

  test('$MethodChannelDatadogInappwebviewTracking is the default instance', () {
    expect(initialPlatform,
        isInstanceOf<MethodChannelDatadogInappwebviewTracking>());
  });

  test('getPlatformVersion', () async {
    DatadogInappwebviewTracking datadogInappwebviewTrackingPlugin =
        DatadogInappwebviewTracking();
    final fakePlatform = MockDatadogInAppWebviewTrackingPlatform();
    DatadogInAppWebviewTrackingPlatform.instance = fakePlatform;

    expect(await datadogInappwebviewTrackingPlugin.getPlatformVersion(), '42');
  });
}

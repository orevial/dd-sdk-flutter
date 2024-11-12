import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:datadog_inappwebview_tracking/datadog_inappwebview_tracking_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDatadogInappwebviewTracking platform = MethodChannelDatadogInappwebviewTracking();
  const MethodChannel channel = MethodChannel('datadog_inappwebview_tracking');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

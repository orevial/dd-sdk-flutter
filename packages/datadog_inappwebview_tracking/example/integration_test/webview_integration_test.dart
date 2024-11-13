// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:async';
import 'dart:convert';

import 'package:datadog_common_test/datadog_common_test.dart';
import 'package:datadog_inappwebview_tracking_example/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

RecordingHttpServer? _mockHttpServer;

Future<RecordingServerClient> startMockServer() async {
  if (kIsWeb) {
    final client = RemoteRecordingServerClient();
    await client.startNewSession();
    return client;
  } else {
    if (_mockHttpServer == null) {
      _mockHttpServer = RecordingHttpServer();
      unawaited(_mockHttpServer!.start());
    }

    final client = LocalRecordingServerClient(_mockHttpServer!);
    await client.startNewSession();

    return client;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('test inappwebview integration', (WidgetTester tester) async {
    var serverRecorder = await startMockServer();
    app.customEndpoint = serverRecorder.sessionEndpoint;

    await app.main();

    await tester.pumpAndSettle();
    var button = find.byWidgetPredicate((widget) =>
        widget is Text &&
        (widget.data?.startsWith('WebView Example') ?? false));
    await tester.tap(button);
    await tester.pumpAndSettle();

    final requestLog = <RequestLog>[];
    final rumLog = <RumEventDecoder>[];
    await serverRecorder.pollSessionRequests(
      const Duration(seconds: 50),
      (requests) {
        requestLog.addAll(requests);
        for (var request in requests) {
          request.data.split('\n').forEach((e) {
            dynamic jsonValue = json.decode(e);
            if (jsonValue is Map<String, dynamic>) {
              rumLog.add(RumEventDecoder(jsonValue));
            }
          });
        }
        final session = RumSessionDecoder.fromEvents(rumLog,
            shouldDiscardApplicationLaunch: false);
        return session.visits.length >= 3;
      },
    );

    final session = RumSessionDecoder.fromEvents(rumLog);
    expect(session.visits.length, 3);

    // First view is home screen, second view is the Flutter view, third is the loaded webview
    final startView = session.visits[0];
    String expectedApplicationId =
        startView.viewEvents.first.rumEvent['application']['id'];
    String expectedSessionId =
        startView.viewEvents.first.rumEvent['session']['id'];

    final browserView = session.visits[2];
    for (var event in browserView.viewEvents) {
      expect(event.rumEvent['application']['id'], expectedApplicationId);
      expect(event.rumEvent['session']['id'], expectedSessionId);
      expect(event.service, 'shopist-web-ui');
      expect(event.rumEvent['source'], 'browser');
    }
    expect(browserView.resourceEvents.length, greaterThan(0));
    for (var resource in browserView.resourceEvents) {
      expect(resource.rumEvent['application']['id'], expectedApplicationId);
      expect(resource.rumEvent['session']['id'], expectedSessionId);
      expect(resource.service, 'shopist-web-ui');
      expect(resource.rumEvent['source'], 'browser');
    }
  });
}

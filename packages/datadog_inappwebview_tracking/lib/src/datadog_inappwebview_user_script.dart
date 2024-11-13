// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2024-Present Datadog, Inc.

import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:datadog_flutter_plugin/datadog_internal.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'datadog_inappwebview_tracking_platform_interface.dart';

const handlerName = 'datadog_inappwebivew_handler';

String _createBridgeSource(
    DatadogSdk datadog, String bridgeName, Set<String> hosts) {
  final sanitizedHosts = hosts
      // ignore: invalid_use_of_internal_member
      .map((e) => sanitizeHost(e, datadog.internalLogger))
      .whereType<String>();
  final allowedWebViewHostsString = sanitizedHosts.map((e) => '"$e"').join(',');

  String bridgeSource = '''
/* DatadogEventBridge */
window.DatadogEventBridge = {
  send(msg) {
    window.$bridgeName.callHandler('$handlerName', msg)
  },
  getAllowedWebViewHosts() {
      return '[$allowedWebViewHostsString]'
  },
  getCapabilities() {
      return '[]'
  },
  getPrivacyLevel() {
      return 'mask'
  }
}
''';

  return bridgeSource;
}

class DatadogInAppWebViewUserScript extends UserScript {
  DatadogInAppWebViewUserScript({
    required DatadogSdk datadog,
    required Set<String> allowedHosts,
    String bridgeName = 'flutter_inappwebview',
  }) : super(
          source: _createBridgeSource(datadog, bridgeName, allowedHosts),
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        );
}

extension DatadogInAppWebViewControllerExtension on InAppWebViewController {
  void trackDatadogEvents(DatadogSdk datadog, {double logSampleRate = 100.0}) {
    addJavaScriptHandler(
      handlerName: handlerName,
      callback: (data) {
        if (data.isNotEmpty) {
          final message = data[0];
          if (message is String) {
            // ignore: invalid_use_of_internal_member
            wrap('handleWebMessage', datadog.internalLogger, {}, () {
              DatadogInAppWebViewTrackingPlatform.instance
                  .sendWebViewMessage(message, logSampleRate);
            });
          }
        }
      },
    );
  }
}

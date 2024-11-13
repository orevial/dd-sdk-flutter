## Overview

This package is an extension to the [`datadog_flutter_plugin`][1]. It allows
Real User Monitoring to monitor web views created by the [`flutter_inappwebview`][2] package and eliminate blind spots in your hybrid Flutter applications.

> [!WARNING]
> This plugin does not currently support Flutter Web

## Instrumenting your web views

The RUM Flutter SDK provides APIs for you to control web view tracking when using the [`flutter_inappwebview`][2] package.

Add both the `datadog_webview_tracking` package and the `flutter_inappwebview` package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_inapp_webview: ^6.1.5
  datadog_flutter_plugin: ^2.8.0
  datadog_webview_tracking: ^1.0.0
```

[1]: https://pub.dev/packages/datadog_flutter_plugin
[2]: https://pub.dev/packages/flutter_inappwebview

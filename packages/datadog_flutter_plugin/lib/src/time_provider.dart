// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-Present Datadog, Inc.

/// Internal function to provide the current timestamp for events. Should
/// return number of milliseconds since unix epoch.
typedef DatadogTimeProvider = int Function();

/// Default time provider which uses `DateTime` to provide the current timestamp.
int defaultTimeProvider() {
  return DateTime.now().millisecondsSinceEpoch;
}

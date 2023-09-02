import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// A widget test that runs a variant for every desktop platform, e.g.,
/// Mac, Windows, Linux.
@isTestGroup
void testWidgetsOnDesktop(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgetsOnMac("$description (on MAC)", test, skip: skip, variant: variant);
  testWidgetsOnWindows("$description (on Windows)", test, skip: skip, variant: variant);
  testWidgetsOnLinux("$description (on Linux)", test, skip: skip, variant: variant);
}

/// A widget test that runs a variant for every desktop platform as native and web, e.g.,
/// Mac, Windows, Linux.
@isTestGroup
void testWidgetsOnDesktopAndWeb(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgetsOnDesktop(description, test, skip: skip, variant: variant);
  testWidgetsOnWebDesktop(description, test, skip: skip, variant: variant);
}

/// A widget test that runs a variant for every desktop platform on web, e.g.,
/// Mac, Windows, Linux.
@isTestGroup
void testWidgetsOnWebDesktop(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgetsOnMacWeb("$description (on MAC Web)", test, skip: skip, variant: variant);
  testWidgetsOnWindowsWeb("$description (on Windows Web)", test, skip: skip, variant: variant);
  testWidgetsOnLinuxWeb("$description (on Linux Web)", test, skip: skip, variant: variant);
}

// A widget test that runs for macOS web.
@isTestGroup
void testWidgetsOnMacWeb(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    debugIsWebOverride = WebPlatformOverride.web;

    tester.view
      ..devicePixelRatio = 1.0
      ..platformDispatcher.textScaleFactorTestValue = 1.0;

    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugIsWebOverride = null;
    }
  }, variant: variant, skip: skip);
}

// A widget test that runs for Windows web.
@isTestGroup
void testWidgetsOnWindowsWeb(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    debugIsWebOverride = WebPlatformOverride.web;

    tester.view
      ..devicePixelRatio = 1.0
      ..platformDispatcher.textScaleFactorTestValue = 1.0;

    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugIsWebOverride = null;
    }
  }, variant: variant, skip: skip);
}

// A widget test that runs for Linux web.
@isTestGroup
void testWidgetsOnLinuxWeb(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    debugIsWebOverride = WebPlatformOverride.web;

    tester.view
      ..devicePixelRatio = 1.0
      ..platformDispatcher.textScaleFactorTestValue = 1.0;

    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugIsWebOverride = null;
    }
  }, variant: variant, skip: skip);
}

/// A widget test that runs a variant for every mobile platform, e.g.,
/// Android and iOS
@isTestGroup
void testWidgetsOnMobile(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgetsOnAndroid("$description (on Android)", test, variant: variant, skip: skip);
  testWidgetsOnIos("$description (on iOS)", test, variant: variant, skip: skip);
}

/// A widget test that runs a variant for every platform, e.g.,
/// Mac, Windows, Linux, Android and iOS.
@isTestGroup
void testWidgetsOnAllPlatforms(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgetsOnMac("$description (on MAC)", test, skip: skip, variant: variant);
  testWidgetsOnWindows("$description (on Windows)", test, skip: skip, variant: variant);
  testWidgetsOnLinux("$description (on Linux)", test, skip: skip, variant: variant);
  testWidgetsOnAndroid("$description (on Android)", test, skip: skip, variant: variant);
  testWidgetsOnIos("$description (on iOS)", test, skip: skip, variant: variant);
}

/// A widget test that runs a variant for Windows and Linux.
///
/// This test method exists because many keyboard shortcuts are identical
/// between Windows and Linux. It would be superfluous to replicate so
/// many shortcut tests. Instead, this test method runs the given [test]
/// with a simulated Windows and Linux platform.
@isTestGroup
void testWidgetsOnWindowsAndLinux(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgetsOnWindows("$description (on Windows)", test, skip: skip, variant: variant);
  testWidgetsOnLinux("$description (on Linux)", test, skip: skip, variant: variant);
}

/// A widget test that configures itself for an arbitrary desktop environment.
///
/// There's no guarantee which desktop environment is used. The purpose of this
/// test method is to cause all relevant configurations to setup for desktop,
/// without concern for any features that change between desktop platforms.
@isTest
void testWidgetsOnArbitraryDesktop(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
}) {
  testWidgetsOnMac(description, test, skip: skip);
}

/// A widget test that configures itself as a Mac platform before executing the
/// given [test], and nullifies the Mac configuration when the test is done.
@isTest
void testWidgetsOnMac(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    tester.view
      ..devicePixelRatio = 1.0
      ..platformDispatcher.textScaleFactorTestValue = 1.0;

    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip, variant: variant);
}

/// A Dart test that configures the [Platform] to think its a [MacPlatform],
/// then runs the [realTest], and then sets the [Platform] back to null.
///
/// [testOnMac] should only be used for unit tests and component tests that
/// care about the platform. In general, platform-specific behavior comes from
/// the widget tree, which should be tested with [testWidgetsOnMac]. In the
/// rare cases where a specific object, handler, or subsystem needs to be tested
/// in isolation, and it cares about the platform, you can use this test method.
@isTest
void testOnMac(
  String description,
  VoidCallback realTest, {
  bool skip = false,
}) {
  test(description, () {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      realTest();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip);
}

/// A widget test that configures itself as a Windows platform before executing the
/// given [test], and nullifies the Windows configuration when the test is done.
@isTest
void testWidgetsOnWindows(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    tester.view
      ..devicePixelRatio = 1.0
      ..platformDispatcher.textScaleFactorTestValue = 1.0;

    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip, variant: variant);
}

/// A Dart test that configures the [Platform] to think its a [WindowsPlatform],
/// then runs the [realTest], and then sets the [Platform] back to null.
///
/// [testOnWindows] should only be used for unit tests and component tests that
/// care about the platform. In general, platform-specific behavior comes from
/// the widget tree, which should be tested with [testWidgetsOnWindows]. In the
/// rare cases where a specific object, handler, or subsystem needs to be tested
/// in isolation, and it cares about the platform, you can use this test method.
@isTest
void testOnWindows(
  String description,
  VoidCallback realTest, {
  bool skip = false,
}) {
  test(description, () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      realTest();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip);
}

/// A widget test that configures itself as a Linux platform before executing the
/// given [test], and nullifies the Linux configuration when the test is done.
@isTest
void testWidgetsOnLinux(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    tester.view
      ..devicePixelRatio = 1.0
      ..platformDispatcher.textScaleFactorTestValue = 1.0;

    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip, variant: variant);
}

/// A Dart test that configures the [Platform] to think its a [LinuxPlatform],
/// then runs the [realTest], and then sets the [Platform] back to null.
///
/// [testOnLinux] should only be used for unit tests and component tests that
/// care about the platform. In general, platform-specific behavior comes from
/// the widget tree, which should be tested with [testWidgetsOnLinux]. In the
/// rare cases where a specific object, handler, or subsystem needs to be tested
/// in isolation, and it cares about the platform, you can use this test method.
@isTest
void testOnLinux(
  String description,
  VoidCallback realTest, {
  bool skip = false,
}) {
  test(description, () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      realTest();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip);
}

/// A widget test that configures itself as a Android platform before executing the
/// given [test], and nullifies the Android configuration when the test is done.
@isTest
void testWidgetsOnAndroid(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip, variant: variant);
}

/// A widget test that configures itself as a iOS platform before executing the
/// given [test], and nullifies the iOS configuration when the test is done.
@isTest
void testWidgetsOnIos(
  String description,
  WidgetTesterCallback test, {
  bool skip = false,
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip, variant: variant);
}

/// Whether or not we are running on web.
///
/// By default this is the same as [kIsWeb].
///
/// [debugIsWebOverride] may be used to override the natural value of [isWeb].
bool get isWeb => debugIsWebOverride == null //
    ? kIsWeb
    : debugIsWebOverride == WebPlatformOverride.web;

/// Overrides the value of [isWeb].
///
/// This is intended to be used in tests.
///
/// Set it to `null` to use the default value of [isWeb].
///
/// Set it to [WebPlatformOverride.web] to configure to run as if we are on web.
///
/// Set it to [WebPlatformOverride.native] to configure to run as if we are NOT on web.
@visibleForTesting
WebPlatformOverride? debugIsWebOverride;

@visibleForTesting
enum WebPlatformOverride {
  /// Configuration to run the app as if we are a native app.
  native,

  /// Configuration to run the app as if we are on web.
  web,
}

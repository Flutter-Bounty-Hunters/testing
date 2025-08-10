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
  testWidgetsOnMac(description, test, skip: skip, variant: variant);
  testWidgetsOnWindows(description, test, skip: skip, variant: variant);
  testWidgetsOnLinux(description, test, skip: skip, variant: variant);
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
  testWidgetsOnAndroid(description, test, variant: variant, skip: skip);
  testWidgetsOnIos(description, test, variant: variant, skip: skip);
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
  testWidgetsOnMac(description, test, skip: skip, variant: variant);
  testWidgetsOnWindows(description, test, skip: skip, variant: variant);
  testWidgetsOnLinux(description, test, skip: skip, variant: variant);
  testWidgetsOnAndroid(description, test, skip: skip, variant: variant);
  testWidgetsOnIos(description, test, skip: skip, variant: variant);
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
  testWidgetsOnWindows(description, test, skip: skip, variant: variant);
  testWidgetsOnLinux(description, test, skip: skip, variant: variant);
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
  testWidgets("$description (on MAC)", (tester) async {
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
  test("$description (on MAC)", () {
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
  testWidgets("$description (on Windows)", (tester) async {
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
  test("$description (on Windows)", () {
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
  testWidgets("$description (on Linux)", (tester) async {
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
  test("$description (on Linux)", () {
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
  testWidgets("$description (on Android)", (tester) async {
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
  testWidgets("$description (on iOS)", (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await test(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }, skip: skip, variant: variant);
}

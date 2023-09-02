import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_runners/src/platform_runners.dart';
import 'package:meta/meta.dart';

/// A widget test that runs a variant for every desktop platform, e.g.,
/// Mac, Windows, Linux, and for all [TextInputSource]s.
@isTestGroup
void testAllInputsOnDesktop(
  String description,
  InputModeTesterCallback test, {
  bool skip = false,
}) {
  testWidgetsOnDesktop("$description (keyboard)", (WidgetTester tester) async {
    await test(tester, inputSource: TextInputSource.keyboard);
  }, skip: skip);

  testWidgetsOnDesktop("$description (IME)", (WidgetTester tester) async {
    await test(tester, inputSource: TextInputSource.ime);
  }, skip: skip);
}

/// A widget test that runs as a Mac, and for all [TextInputSource]s.
@isTestGroup
void testAllInputsOnMac(
  String description,
  InputModeTesterCallback test, {
  bool skip = false,
}) {
  testWidgetsOnMac("$description (keyboard)", (WidgetTester tester) async {
    await test(tester, inputSource: TextInputSource.keyboard);
  }, skip: skip);

  testWidgetsOnMac("$description (IME)", (WidgetTester tester) async {
    await test(tester, inputSource: TextInputSource.ime);
  }, skip: skip);
}

/// A widget test that runs a variant for Windows and Linux, and for all [TextInputSource]s.
@isTestGroup
void testAllInputsOnWindowsAndLinux(
  String description,
  InputModeTesterCallback test, {
  bool skip = false,
}) {
  testWidgetsOnWindowsAndLinux("$description (keyboard)", (WidgetTester tester) async {
    await test(tester, inputSource: TextInputSource.keyboard);
  }, skip: skip);

  testWidgetsOnWindowsAndLinux("$description (IME)", (WidgetTester tester) async {
    await test(tester, inputSource: TextInputSource.ime);
  }, skip: skip);
}

typedef InputModeTesterCallback = Future<void> Function(
  WidgetTester widgetTester, {
  required TextInputSource inputSource,
});

/// The mode of user text input.
enum TextInputSource {
  keyboard,
  ime,
}

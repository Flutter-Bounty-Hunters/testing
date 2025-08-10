# Flutter Test Runners
Widget test runners for Flutter apps and packages.

<p align="center">
  <a href="https://flutterbountyhunters.com" target="_blank">
    <img src="https://github.com/Flutter-Bounty-Hunters/flutter_test_robots/assets/7259036/1b19720d-3dad-4ade-ac76-74313b67a898" alt="Built by the Flutter Bounty Hunters">
  </a>
</p>

Write tests that run on a specified platform.

```dart
testWidgetsOnMac("My test", (tester) async {
  // This test runs with a simulated Mac platform.
});

testWidgetsOnIos("My test", (tester) async {
  // This test runs with a simulated iOS platform.
});

testWidgetsOnAndroid("My test", (tester) async {
  // This test runs with a simulated Android platform.
});
```

Write tests that run on multiple simulated platforms.

```dart
testWidgetsOnMobile("My test", (tester) async {
  // This test runs once on iOS and once on Android.
});

testWidgetsOnDesktop("My test", (tester) async {
  // This test runs once on Mac, once on Windows, and once on Linux.
});
```

Platform test runners are especially useful when you want to test a platform-specific 
behavior, such as a platform-specific keyboard shortcut. For example, a desktop
app can test a "copy" shortcut with the help of `flutter_test_robots`.

```dart
testWidgetsOnMac("My shortcut test", (tester) async {
  // Setup the test.

  await tester.pressCmdC();

  // Verify the results of the copy command.
});
```

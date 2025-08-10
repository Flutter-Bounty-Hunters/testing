import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_runners/flutter_test_runners.dart';

void main() {
  group("Runners simulate platforms >", () {
    group("all platforms >", () {
      final expectedPlatforms = [
        TargetPlatform.iOS,
        TargetPlatform.android,
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ];

      testWidgetsOnAllPlatforms("all platforms runner", (tester) async {
        expect(expectedPlatforms, contains(defaultTargetPlatform));
        expectedPlatforms.remove(defaultTargetPlatform);
      });
    });

    group("mobile >", () {
      final expectedPlatforms = [TargetPlatform.iOS, TargetPlatform.android];

      testWidgetsOnMobile("mobile runner", (tester) async {
        expect(expectedPlatforms, contains(defaultTargetPlatform));
        expectedPlatforms.remove(defaultTargetPlatform);
      });
    });

    testWidgetsOnIos("iOS runner", (tester) async {
      expect(defaultTargetPlatform, TargetPlatform.iOS);

      // We leave mobile pixel ratios alone because the default Flutter value
      // approximates real mobile pixel ratios.
      expect(tester.view.devicePixelRatio, 3.0);
    });

    testWidgetsOnAndroid("Android runner", (tester) async {
      expect(defaultTargetPlatform, TargetPlatform.android);

      // We leave mobile pixel ratios alone because the default Flutter value
      // approximates real mobile pixel ratios.
      expect(tester.view.devicePixelRatio, 3.0);
    });

    group("desktop >", () {
      final expectedPlatforms = [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux];

      testWidgetsOnDesktop("desktop runner", (tester) async {
        expect(expectedPlatforms, contains(defaultTargetPlatform));
        expectedPlatforms.remove(defaultTargetPlatform);

        // We configure desktop for a 1:1 pixel density to match real desktops.
        expect(tester.view.devicePixelRatio, 1.0);
      });
    });

    testWidgetsOnMac("Mac runner", (tester) async {
      expect(defaultTargetPlatform, TargetPlatform.macOS);

      // We configure desktop for a 1:1 pixel density to match real desktops.
      expect(tester.view.devicePixelRatio, 1.0);
    });

    testWidgetsOnWindows("Windows runner", (tester) async {
      expect(defaultTargetPlatform, TargetPlatform.windows);

      // We configure desktop for a 1:1 pixel density to match real desktops.
      expect(tester.view.devicePixelRatio, 1.0);
    });

    testWidgetsOnLinux("Linux runner", (tester) async {
      expect(defaultTargetPlatform, TargetPlatform.linux);

      // We configure desktop for a 1:1 pixel density to match real desktops.
      expect(tester.view.devicePixelRatio, 1.0);
    });
  });
}

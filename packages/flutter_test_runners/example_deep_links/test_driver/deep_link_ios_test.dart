import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test_runners/flutter_test_runners.dart';
import 'package:test/test.dart';

void main() {
  const appBundleId = "com.flutterbountyhunters.deeplinks.example";

  // Command you can use to directly check a Universal Link:
  // xcrun simctl openurl booted https://deeplinks.flutterbountyhunters.com

  group("Deep link launches app > iOS >", () {
    testDeepLinkIosAppLaunch(
      "home screen",
      appBundleId: appBundleId,
      deepLink: "https://deeplinks.flutterbountyhunters.com",
      verbose: true,
      (driver) async {
        await driver.waitFor(find.text("Home Screen"));
        await Future.delayed(const Duration(seconds: 3));
      },
    );

    // testDeepLinkIosAppLaunch(
    //   "sign-up screen",
    //   appBundleId: appBundleId,
    //   deepLink: "https://deeplinks.flutterbountyhunters.com/signup",
    //   (driver) async {
    //     await driver.waitFor(find.text("Sign Up"));
    //     await Future.delayed(const Duration(seconds: 3));
    //   },
    // );
    //
    // testDeepLinkIosAppLaunch(
    //   "profile screen",
    //   appBundleId: appBundleId,
    //   deepLink: "https://deeplinks.flutterbountyhunters.com/user/profile",
    //   (driver) async {
    //     await driver.waitFor(find.text("User Profile"));
    //     await Future.delayed(const Duration(seconds: 3));
    //   },
    // );
  });
}

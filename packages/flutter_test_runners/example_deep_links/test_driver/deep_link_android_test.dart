import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test_runners/flutter_test_runners.dart';
import 'package:test/test.dart';

void main() {
  const appPackage = "com.flutterbountyhunters.deeplinks.example";

  // Command you can use to directly check a deep link:
  // adb shell am start -W -a android.intent.action.VIEW -d "app://deeplinks.flutterbountyhunters.com/user/profile" com.flutterbountyhunters.deeplinks.example

  group("Deep link launches app > Android >", () {
    testDeepLinkAndroidAppLaunch(
      "home screen",
      appPackage: appPackage,
      deepLink: "app://deeplinks.flutterbountyhunters.com",
      (driver) async {
        await driver.waitFor(find.text("Home Screen"));
        await Future.delayed(const Duration(seconds: 3));
      },
    );

    testDeepLinkAndroidAppLaunch(
      "sign-up screen",
      appPackage: appPackage,
      deepLink: "app://deeplinks.flutterbountyhunters.com/signup",
      (driver) async {
        await driver.waitFor(find.text("Sign Up"));
        await Future.delayed(const Duration(seconds: 3));
      },
    );

    testDeepLinkAndroidAppLaunch(
      "profile screen",
      appPackage: appPackage,
      deepLink: "app://deeplinks.flutterbountyhunters.com/user/profile",
      (driver) async {
        await driver.waitFor(find.text("User Profile"));
        await Future.delayed(const Duration(seconds: 3));
      },
    );
  });
}

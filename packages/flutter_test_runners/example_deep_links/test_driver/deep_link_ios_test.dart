import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test_runners/flutter_test_runners.dart';
import 'package:test/test.dart';

void main() {
  const appBundleId = "com.flutterbountyhunters.deeplinks.example";

  // Command you can use to directly check a Universal Link:
  // xcrun simctl openurl booted https://deeplinks.flutterbountyhunters.com

  group("Deep link launches app > iOS >", () {
    test("xcrun sanity check", () async {
      print("Running xcrun Process sanity check.");

      print("Env variables:");
      print(Process.runSync('env', []).stdout);

      print("Running the command...");
      final process = await Process.start(
        "xcrun",
        [
          "simctl",
          "get_app_container",
          "booted",
          "com.flutterbountyhunters.deeplinks.example",
        ],
        environment: {'DEVELOPER_DIR': '/Applications/Xcode.app/Contents/Developer'},
      );
      process.stdout.transform(utf8.decoder).listen((data) {});
      process.stderr.transform(utf8.decoder).listen((data) {});
      print("The process started...");
      final exitCode = await process.exitCode;
      print("The xcrun call returned with exit code: $exitCode");
    });

    // testDeepLinkIosAppLaunch(
    //   "home screen",
    //   appBundleId: appBundleId,
    //   deepLink: "https://deeplinks.flutterbountyhunters.com",
    //   verbose: true,
    //   (driver) async {
    //     await driver.waitFor(find.text("Home Screen"));
    //     await Future.delayed(const Duration(seconds: 3));
    //   },
    // );

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

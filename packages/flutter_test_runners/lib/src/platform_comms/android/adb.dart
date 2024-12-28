import 'dart:convert';
import 'dart:io';

/// A Dart interface for common Android Debug Bridge (ADB) commands.
class Adb {
  /// Returns `true` if the app with the given [appPackage] ID is currently
  /// in memory on the Android device.
  ///
  /// A return value of `true` doesn't mean the app is visible. The app might
  /// be in the background, but still in memory.
  static Future<bool> isAppRunning(String appPackage) async {
    final result = await Process.run(
      "sh",
      ["-c", "adb shell ps | grep $appPackage"],
    );
    final output = result.stdout;
    return output != null && output is String && output.isNotEmpty;
  }

  /// Starts listening to ADB logcat for Android logs, and returns the
  /// [Process] that's listening to logcat.
  ///
  /// This method assumes that `stdout` and `stderr` from Logcat send messages
  /// with UTF8 encoding. If anything else is received, the behavior is undefined,
  /// but probably an error.
  static Future<Process> listenToAdbForFlutterLogs({
    void Function(String)? onLog,
    void Function(String)? onError,
  }) async {
    final result = await Process.start("adb", ["logcat", "-s", "flutter"]);

    result.stdout.transform(utf8.decoder).listen(onLog);
    result.stderr.transform(utf8.decoder).listen(onError);

    return result;
  }

  /// Connects the given TCP [port] from the host machine to the running Android
  /// device.
  ///
  /// This is useful, for example, when you want to connect to the Dart VM service
  /// running in a debug Flutter app on an Android device.
  static Future<void> forwardTcpPort(int port) async {
    await Process.run("adb", ["forward", "tcp:$port", "tcp:$port"]);
  }

  /// Tells Android to launch the app with the given [appPackage] ID using
  /// the given [deepLink].
  ///
  /// The structure of the deep link is determined by the given app.
  static Future<void> launchAppWithDeepLink({
    required String appPackage,
    required String deepLink,
  }) async {
    await Process.start("adb", [
      "shell",
      "am",
      "start",
      "-W",
      "-a",
      "android.intent.action.VIEW",
      "-d",
      "\"$deepLink\"",
      appPackage,
    ]);
  }

  /// Waits for the app with the given [appPackage] to appear in memory.
  ///
  /// This method polls the OS to check if the app is running. To use a custom
  /// polling duration, provide a [pollDuration].
  ///
  /// This method fails if the app hasn't launched within the given [timeout]
  /// duration.
  static Future<bool> waitForAppToLaunch(
    String appPackage, {
    Duration pollDuration = const Duration(milliseconds: 250),
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final now = DateTime.now();

    bool isAppRunning = false;
    do {
      isAppRunning = await Adb.isAppRunning(appPackage);
      if (!isAppRunning) {
        await Future.delayed(pollDuration);
      }
    } while (!isAppRunning && (DateTime.now().difference(now) < timeout));

    return isAppRunning;
  }

  /// Kills the app with the given [package] ID, e.g., com.acme.myapp.
  static Future<void> killApp(String package) async {
    await Process.run("adb", ["shell", "am", "force-stop", package]);
  }

  /// Clears all logs in logcat.
  ///
  /// Note: Logcat retains logs such that connecting to logcat will
  /// initially print a bunch of old logs before printing new logs.
  /// When searching logs for specific info, like a URL, those old logs
  /// can lead to an attempt to connect to dead services. This method
  /// clears those logs before listening for new logs.
  static Future<void> clearLogcat() async {
    await Process.run("adb", ["logcat", "-b", "all", "-c"]);
  }
}

import 'dart:convert';
import 'dart:io';

/// A Dart interface for common `xcrun` commands.
class Xcrun {
  /// Returns `true` if the app with the given [appBundleId] ID is currently
  /// in memory on the iOS device.
  ///
  /// A return value of `true` doesn't mean the app is visible. The app might
  /// be in the background, but still in memory.
  static Future<bool> isAppRunning(String appBundleId) async {
    final result = await Process.run(
      "sh",
      ["-c", "xcrun simctl spawn booted launchctl list | grep \"$appBundleId\""],
    );
    final output = result.stdout;
    return output != null && output is String && output.isNotEmpty;
  }

  /// Starts listening to the running iOS device's log stream, and returns the
  /// [Process] that's listening.
  ///
  /// This method assumes that `stdout` and `stderr` from Logcat send messages
  /// with UTF8 encoding. If anything else is received, the behavior is undefined,
  /// but probably an error.
  static Future<Process> listenToXcrunForFlutterLogs(
    String appBundleId, {
    void Function(String)? onLog,
    void Function(String)? onError,
  }) async {
    final result = await Process.start("xcrun", [
      "simctl",
      "spawn",
      "booted",
      "log",
      "stream",
      "--level",
      "debug",
      // Only log things related to the desired app.
      "--predicate",
      "(eventMessage CONTAINS '$appBundleId' OR eventMessage CONTAINS 'flutter')",
    ]);

    result.stdout.transform(utf8.decoder).listen(onLog);
    result.stderr.transform(utf8.decoder).listen(onError);

    return result;
  }

  /// Connects the given TCP [port] from the host machine to the running iOS
  /// device.
  ///
  /// This is useful, for example, when you want to connect to the Dart VM service
  /// running in a debug Flutter app on an iOS device.
  static Future<void> forwardTcpPort(int port) async {
    await Process.run("xcrun", ["simctl", "port", "forward", "booted", "$port:$port"]);
  }

  /// Tells iOS to launch the given Universal Link, which might launch an app, if
  /// an app is registered to handle the domain of the link.
  ///
  /// The structure of the deep link is determined by the given app.
  static Future<void> launchAppWithUniversalLink({
    required String universalLink,
  }) async {
    // Not sure why we need to dispatch through a shell, but if we try to
    // run the xcrun command directly, the deep link doesn't launch.
    await Process.run("sh", [
      "-c",
      "xcrun simctl openurl booted \"$universalLink\"",
    ]);
  }

  /// Waits for the app with the given [appBundleId] to appear in memory.
  ///
  /// This method polls the OS to check if the app is running. To use a custom
  /// polling duration, provide a [pollDuration].
  ///
  /// This method fails if the app hasn't launched within the given [timeout]
  /// duration.
  static Future<bool> waitForAppToLaunch(
    String appBundleId, {
    Duration pollDuration = const Duration(milliseconds: 250),
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final now = DateTime.now();

    bool isAppRunning = false;
    do {
      isAppRunning = await Xcrun.isAppRunning(appBundleId);
      if (!isAppRunning) {
        await Future.delayed(pollDuration);
      }
    } while (!isAppRunning && (DateTime.now().difference(now) < timeout));

    return isAppRunning;
  }

  /// Kills the app with the given [appBundleId] ID, e.g., `com.acme.myapp`.
  static Future<void> killApp(String appBundleId) async {
    await Process.run("sh", ["-c", "xcrun", "simctl", "terminate", "booted", appBundleId]);
  }

  /// Clears all logs in the iOS log stream.
  static Future<void> clearLogcat() async {
    await Process.run("xcrun", ["simctl", "spawn", "booted", "log", "erase"]);
  }
}

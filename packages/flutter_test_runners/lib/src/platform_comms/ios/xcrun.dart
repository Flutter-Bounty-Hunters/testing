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
    print("isAppRunning() - $appBundleId");
    // final result = await Process.run(
    //   "sh",
    //   [
    //     "-c",
    //     "xcrun simctl spawn booted launchctl list | grep \"$appBundleId\"",
    //   ],
    //   runInShell: true,
    // );

    // final result = await Process.run("sh", [
    //   "-c",
    //   "xcrun simctl spawn booted launchctl list | grep \"$appBundleId\"",
    // ]);

    print("Trying command through shell - no grep...");
    var result = await _runInShell([
      "xcrun simctl spawn booted launchctl list",
    ]);
    print("Done with command without grep:");
    print(result.stdout);
    final output = result.stdout;
    if (output is! String) {
      // We don't know how to handle this.
      return false;
    }

    return output.contains(appBundleId);

    // print("Trying command through shell with '| grep'...");
    // result = await _runInShell([
    //   "xcrun simctl spawn booted launchctl list | grep \"$appBundleId\"",
    // ]);
    // final output = result.stdout;
    // print("Is app running? ${output != null && output is String && output.isNotEmpty}");
    // return output != null && output is String && output.isNotEmpty;
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
    // This command doesn't work when run with a "sh -c". It also doesn't
    // work when concatenating the args into a single string.
    final result = await Process.start(
      "xcrun",
      [
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
      ],
      runInShell: true,
    );

    result.stdout.transform(utf8.decoder).listen(onLog);
    result.stderr.transform(utf8.decoder).listen(onError);

    return result;
  }

  /// Connects the given TCP [port] from the host machine to the running iOS
  /// device.
  ///
  /// This is useful, for example, when you want to connect to the Dart VM service
  /// running in a debug Flutter app on an iOS device.
  static Future<void> forwardTcpPort(int port) {
    return _runInShell(["xcrun", "simctl", "port", "forward", "booted", "$port:$port"]);
  }

  /// Tells iOS to launch the given Universal Link, which might launch an app, if
  /// an app is registered to handle the domain of the link.
  ///
  /// The structure of the deep link is determined by the given app.
  static Future<void> launchAppWithUniversalLink({
    required String universalLink,
  }) {
    // Note: This command only works when run with "sh" and the
    // command as a single string. If the command is passed as
    // individual arguments, it doesn't work. If the command is
    // run without "sh" and `runInShell` is `true`, it won't work.
    return _runInShell(["xcrun simctl openurl booted \"$universalLink\""]);
    // return Process.run(
    //   "sh",
    //   ["-c", "xcrun simctl openurl booted \"$universalLink\""],
    // );
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
    // final result = await Process.run(
    //   "xcrun",
    //   ["simctl", "terminate", "booted", appBundleId],
    //   runInShell: true,
    // );

    print("Sending xcrun simctl terminate command...");
    final process = await Process.start(
      "sh",
      ["-c", "xcrun simctl terminate booted $appBundleId"],
    );
    print("terminate command process was started");

    process.stdin.close();

    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    // process.stdout.transform(utf8.decoder).listen((log) {
    //   print("terminate command log: $log");
    // });
    //
    // process.stderr.transform(utf8.decoder).listen((error) {
    //   print("terminate command error: $error");
    // });

    print("Waiting for exit code...");
    final exitCode = await process.exitCode;
    print("Killed app - exit code: $exitCode");
  }

  /// Clears all logs in the iOS log stream.
  static Future<void> clearLogs() async {
    await _runInShell(["xcrun", "simctl", "spawn", "booted", "log", "erase"]);
  }

  static Future<Process> _startInShell(List<String> commandAndArgs) {
    return Process.start("sh", ["-c", ...commandAndArgs]);

    // return Process.start(
    //   commandAndArgs.first,
    //   commandAndArgs.length > 1 ? commandAndArgs.sublist(1) : [],
    //   runInShell: true,
    // );
  }

  static Future<ProcessResult> _runInShell(List<String> commandAndArgs) async {
    final command = commandAndArgs.join(" ");
    print("Sending shell command: '$command'");
    final result = await Process.run("sh", ["--verbose", "--debug", "-c", command]);
    print("Shell command exit code: ${result.exitCode}");

    if (result.exitCode != 0) {
      throw Exception("Failed to execute command in a shell:\n'$command'\nExit code: ${result.exitCode}");
    }

    return result;

    // return Process.run(
    //   commandAndArgs.first,
    //   commandAndArgs.length > 1 ? commandAndArgs.sublist(1) : [],
    //   runInShell: true,
    // );
  }
}

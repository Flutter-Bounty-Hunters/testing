import 'dart:convert';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test_runners/src/platform_comms/android/adb.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// A test that runs after launching the Android app with the given
/// [appPackage], with the given [deepLink].
///
/// The test implementation is defined by the caller within [testRunner].
/// The [testRunner] works the same way as a typical `test()` callback,
/// except that the [testRunner] is given a [FlutterDriver] to inspect
/// the app.
///
/// Tests that launch apps with deep links must use a [FlutterDriver],
/// instead of a [WidgetTester], because [WidgetTester]s require building
/// and launching the app with instrumentation. Launching an app with a
/// deep link doesn't have instrumentation. Instead, the host machine
/// users the [FlutterDriver] to talk to the running app.
void testDeepLinkAndroidAppLaunch(
  String description,
  Future<void> Function(FlutterDriver driver) testRunner, {
  required String appPackage,
  required String deepLink,
  bool verbose = false,
}) {
  test(description, () async {
    _initLogs(verbose);
    _log.info("Running deep link test driver...");

    // Pre-emptively the kill the app, in case it's already running.
    await Adb.killApp(appPackage);

    late final FlutterDriver? driver;
    addTearDown(() async {
      _log.info("Cleaning up after the test");
      // Dispose the FlutterDriver connection.
      driver?.serviceClient.dispose();

      // Kill the app when we're done.
      await Adb.killApp(appPackage);
    });

    // Ensure the app isn't running yet.
    expect(await Adb.isAppRunning(appPackage), isFalse);

    // Clear previous logcat messages so we don't try to connect to a previous
    // Dart VM service listing.
    await Adb.clearLogcat();

    // Listen to logcat to find the Dart VM service for the running app.
    String? dartVmService;
    await Adb.listenToAdbForFlutterLogs(onLog: (data) {
      if (data.contains("Dart VM service")) {
        _log.info("Found Dart VM log:\n$data");

        final regex = RegExp(r'.*Dart VM service.*(http[s]?://[^\s]+)');
        final httpUrl = Uri.parse(regex.firstMatch(data)!.group(1)!);

        dartVmService = Uri(scheme: "ws", host: httpUrl.host, port: httpUrl.port, path: "${httpUrl.path}ws").toString();
      }
    }, onError: (error) {
      _log.shout("LOGCAT ERROR:");
      _log.shout(error);
    });

    // Send the deep link.
    await Adb.launchAppWithDeepLink(appPackage: appPackage, deepLink: deepLink);

    // Wait until the deep link launches the app.
    final isAppRunning = await Adb.waitForAppToLaunch(appPackage);
    expect(
      isAppRunning,
      isTrue,
      reason: "The app never launched after sending the deeplink. Package: $appPackage, Deeplink: $deepLink",
    );

    // Wait for a moment so that the app has time to start the Dart VM
    // service and report it in the ADB logs.
    //
    // When running locally, waiting 1 second is probably sufficient. But
    // when running in GitHub CI, we need to wait longer to make sure the
    // Dart VM service reports its URL.
    _log.info("Waiting a moment so that app can launch the Dart VM service.");
    await Future.delayed(const Duration(seconds: 5));

    // Ensure that we found the Dart VM service URL.
    expect(
      dartVmService,
      isNotNull,
      reason: "Couldn't find the Dart VM service for the app that was launched with a deep link.",
    );
    expect(
      dartVmService,
      isNotEmpty,
      reason: "Couldn't find the Dart VM service for the app that was launched with a deep link.",
    );

    // Setup port forwarding between the host machine running the test, and the
    // Android device that's running the app, so we can talk to the Dart VM service.
    final port = Uri.parse(dartVmService!).port;
    await Adb.forwardTcpPort(port);

    // Connect to the Dart VM service in the app with Flutter Driver.
    try {
      driver = await FlutterDriver.connect(
        dartVmServiceUrl: dartVmService,
      );
    } catch (exception) {
      if (verbose) {
        await _logVmDetailsAfterConnectionFailure(dartVmService!);
      }

      throw TestFailure(
        "Couldn't connect FlutterDriver to the app's Dart VM service (the app successfully launched with the deep link, though)",
      );
    }

    // Run the test.
    await testRunner(driver);
  });
}

Future<void> _logVmDetailsAfterConnectionFailure(String dartVmService) async {
  _log.warning("Failed to connect to the FlutterDriver!");

  // Connect to the Dart VM service to query info.
  late final VmService vmService;
  try {
    vmService = await vmServiceConnectUri(dartVmService);
  } catch (exception) {
    _log.warning("Tried to connect to the Dart VM service to provide more details, but we couldn't connect to it.");
    _log.warning(exception);
    return;
  }

  // Get the VM.
  late final VM vm;
  try {
    vm = await vmService.getVM();
  } catch (exception) {
    _log.warning("Tried to get the VM from the Dart VM service, but we failed to query it.");
    _log.warning(exception);
    return;
  }

  _log.info('''
Additional VM service info:
 - name: ${vm.name}
 - type: ${vm.type}
 - host CPU: ${vm.hostCPU}
 - target CPU: ${vm.targetCPU}
 - OS: ${vm.operatingSystem}
 - PID: ${vm.pid}
''');

  if (vm.isolates != null) {
    _log.info("Isolates attached to the Dart VM service:");
    for (final remoteIsolate in vm.isolates!) {
      late final Isolate isolate;
      try {
        isolate = await vmService.getIsolate(remoteIsolate.id!);
      } catch (exception) {
        _log.warning("Tried to load isolate data for '${remoteIsolate.id}', but failed.");
        continue;
      }

      _log.info('''Isolate:
  - ID: ${isolate.id}
  - name: ${isolate.name}
  - type: ${isolate.type}
  - is system isolate: ${isolate.isSystemIsolate}
  - registered extensions:
  
  ${isolate.extensionRPCs}
''');
    }
  }
}

void _initLogs(bool writeLogs) {
  if (!writeLogs) {
    return;
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

final _log = Logger("flutter_test_runners.deep_links");

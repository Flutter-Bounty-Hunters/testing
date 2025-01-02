import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test_runners/src/platform_comms/ios/xcrun.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// A test that runs after launching the iOS app with the given
/// [appBundleId], with the given [deepLink].
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
void testDeepLinkIosAppLaunch(
  String description,
  Future<void> Function(FlutterDriver driver) testRunner, {
  required String appBundleId,
  required String deepLink,
  bool verbose = false,
  Duration timeout = const Duration(minutes: 5),
}) {
  test(description, () async {
    _initLogs(verbose);
    _log.info("Running deep link test driver...");

    // Pre-emptively the kill the app, in case it's already running.
    _log.info("Pre-emptively killing the app");
    await Xcrun.killApp(appBundleId);

    FlutterDriver? driver;
    addTearDown(() async {
      _log.info("Cleaning up after the test");
      // Dispose the FlutterDriver connection.
      driver?.serviceClient.dispose();

      // Kill the app when we're done.
      await Xcrun.killApp(appBundleId);
    });

    // Ensure the app isn't running yet.
    _log.info("Checking if the app is running...");
    expect(await Xcrun.isAppRunning(appBundleId), isFalse);
    _log.info("We've verified the app isn't running");

    // Clear previous logcat messages so we don't try to connect to a previous
    // Dart VM service listing.
    _log.info("Clearing old logs");
    await Xcrun.clearLogcat();
    _log.info("We've cleared old logs");

    // Listen to iOS logs to find the Dart VM service for the running app.
    _log.info("Registering for simulator logs");
    String? dartVmService;
    await Xcrun.listenToXcrunForFlutterLogs(
      appBundleId,
      onLog: (log) {
        // _log.info(log);
        if (log.contains("Dart VM service")) {
          _log.info("Found Dart VM log:\n$log");

          final regex = RegExp(r'.*Dart VM service.*(http[s]?://[^\s]+)');
          final httpUrl = Uri.parse(regex.firstMatch(log)!.group(1)!);

          dartVmService =
              Uri(scheme: "ws", host: httpUrl.host, port: httpUrl.port, path: "${httpUrl.path}ws").toString();
        }
      },
      onError: (error) {
        _log.shout("iOS ERROR:");
        _log.shout(error);
      },
    );
    _log.info("We're now listening to logs and errors from iOS");

    // Send the deep link.
    _log.info("Sending the deep link: $deepLink");
    await Xcrun.launchAppWithUniversalLink(universalLink: deepLink);

    // Wait until the deep link launches the app.
    _log.info("Waiting for app to launch: $appBundleId");
    final isAppRunning = await Xcrun.waitForAppToLaunch(appBundleId);
    expect(
      isAppRunning,
      isTrue,
      reason: "The app never launched after sending the deeplink. Package: $appBundleId, Deeplink: $deepLink",
    );

    // Wait for a moment so that the app has time to start the Dart VM
    // service and report it in the device logs.
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
    _log.info("Forwarding simulator port: $port");
    await Xcrun.forwardTcpPort(port);

    // Connect to the Dart VM service in the app with Flutter Driver.
    try {
      _log.info("Connecting to Flutter Driver extension in the Dart VM service.");
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
  }, timeout: Timeout(timeout));
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

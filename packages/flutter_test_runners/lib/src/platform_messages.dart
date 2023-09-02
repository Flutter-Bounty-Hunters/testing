import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension on [WidgetTester] to easily intercept platform messages.
extension TestMessageInterceptor on WidgetTester {
  /// Creates a handler to intercept messages of the given [channel].
  PlatformMessageHandler interceptChannel(String channel) {
    final handler = PlatformMessageHandler();

    binding.defaultBinaryMessenger.setMockMessageHandler(channel, (message) async {
      return await handler.handleMessage(message);
    });

    return handler;
  }
}

/// A method to handle platform method calls.
typedef PlatformMethodHandler = Future<ByteData?>? Function(MethodCall methodCall);

/// Configures handlers to intercept platform method calls.
///
/// Use [interceptMethod] to configure a handler for a method.
class PlatformMessageHandler {
  final _handlers = <String, PlatformMethodHandler>{};

  /// Configures a [handler] to a [method].
  PlatformMessageHandler interceptMethod(String method, PlatformMethodHandler handler) {
    _handlers[method] = handler;
    return this;
  }

  /// Decodes platform messages and dispatches to the configured handlers.
  Future<ByteData?>? handleMessage(ByteData? message) async {
    final methodCall = const JSONMethodCodec().decodeMethodCall(message);
    final handler = _handlers[methodCall.method];

    if (handler == null) {
      return null;
    }

    return await handler(methodCall);
  }
}

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:abrova_chat/abrova_chat.dart';

/// Provides the AbrovaChatClient to the widget tree.
///
/// This is the root widget for AbrovaChat UI. Place it near the top
/// of your widget tree to provide chat functionality to all descendants.
///
/// ```dart
/// AbrovaChatScope(
///   config: config,
///   child: MyApp(),
/// )
/// ```
class AbrovaChatScope extends StatefulWidget {
  /// The AbrovaChat configuration.
  final AbrovaChatConfig config;

  /// Whether to automatically connect on mount.
  final bool autoConnect;

  /// Called when the client connects.
  final VoidCallback? onConnected;

  /// Called when a connection error occurs.
  final void Function(Object error)? onError;

  /// The child widget.
  final Widget child;

  const AbrovaChatScope({
    super.key,
    required this.config,
    this.autoConnect = true,
    this.onConnected,
    this.onError,
    required this.child,
  });

  /// Gets the AbrovaChatClient from the nearest ancestor.
  static AbrovaChatClient of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AbrovaChatInherited>();
    if (scope == null) {
      throw FlutterError(
        'AbrovaChatScope.of() called with a context that does not contain a AbrovaChatScope.\n'
        'Ensure that AbrovaChatScope is an ancestor of the widget calling AbrovaChatScope.of().',
      );
    }
    return scope.client;
  }

  /// Gets the AbrovaChatClient without establishing a dependency.
  static AbrovaChatClient read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_AbrovaChatInherited>();
    if (scope == null) {
      throw FlutterError(
        'AbrovaChatScope.read() called with a context that does not contain a AbrovaChatScope.\n'
        'Ensure that AbrovaChatScope is an ancestor of the widget calling AbrovaChatScope.read().',
      );
    }
    return scope.client;
  }

  /// Tries to get the AbrovaChatClient, returns null if not found.
  static AbrovaChatClient? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AbrovaChatInherited>();
    return scope?.client;
  }

  @override
  State<AbrovaChatScope> createState() => _AbrovaChatScopeState();
}

class _AbrovaChatScopeState extends State<AbrovaChatScope> {
  late AbrovaChatClient _client;
  StreamSubscription<ConnectionErrorEvent>? _errorSub;

  @override
  void initState() {
    super.initState();
    _client = AbrovaChatClient(widget.config);

    _errorSub = _client.onConnectionError.listen((event) {
      widget.onError?.call(event.error);
    });

    if (widget.autoConnect) {
      _connect();
    }
  }

  Future<void> _connect() async {
    try {
      await _client.connect();
      widget.onConnected?.call();
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  @override
  void didUpdateWidget(AbrovaChatScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recreate client if config changes
    if (oldWidget.config.apiKey != widget.config.apiKey ||
        oldWidget.config.userId != widget.config.userId) {
      _errorSub?.cancel();
      _client.dispose();

      _client = AbrovaChatClient(widget.config);
      _errorSub = _client.onConnectionError.listen((event) {
        widget.onError?.call(event.error);
      });

      if (widget.autoConnect) {
        _connect();
      }
    }
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AbrovaChatInherited(
      client: _client,
      child: widget.child,
    );
  }
}

class _AbrovaChatInherited extends InheritedWidget {
  final AbrovaChatClient client;

  const _AbrovaChatInherited({
    required this.client,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AbrovaChatInherited oldWidget) {
    return client != oldWidget.client;
  }
}

/// Provides an existing AbrovaChatClient to the widget tree.
///
/// Use this when you already have a AbrovaChatClient instance (e.g., from Riverpod
/// or another state management solution) and want to use it with AbrovaChat UI widgets.
///
/// Unlike [AbrovaChatScope], this widget does NOT create or manage the client lifecycle.
/// You are responsible for creating, connecting, and disposing the client.
///
/// ```dart
/// final client = ref.read(abrovaChatClientProvider);
/// AbrovaChatProvider(
///   client: client,
///   child: ChatScreen(roomId: 'room-123', currentUserId: 'user-456'),
/// )
/// ```
class AbrovaChatProvider extends StatelessWidget {
  /// The existing AbrovaChatClient to provide.
  final AbrovaChatClient client;

  /// The child widget.
  final Widget child;

  const AbrovaChatProvider({
    super.key,
    required this.client,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _AbrovaChatInherited(
      client: client,
      child: child,
    );
  }
}

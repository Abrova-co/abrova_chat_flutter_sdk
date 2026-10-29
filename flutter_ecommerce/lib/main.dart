import 'package:flutter/material.dart';
import 'package:abrova_chat/abrova_chat.dart';
import 'package:abrova_chat_ui/abrova_chat_ui.dart';
import 'package:abrova_push/abrova_push.dart';

import 'screens/login_screen.dart';
import 'screens/orders_screen.dart';
import 'services/file_upload_service.dart';

/// AbrovaChat E-commerce Example App
///
/// This example demonstrates a real-world e-commerce chat integration where:
/// - Buyers can chat with sellers about their orders
/// - Each order has its own chat room (1:1 conversation)
/// - Supports file attachments, reactions, typing indicators, and more
///
/// Features demonstrated:
/// - AbrovaChatScope for client lifecycle management
/// - ChatScreen for complete chat UI
/// - Custom message bubbles with order context
/// - File upload integration
/// - Unread badges and room list
/// - Presence and typing indicators
/// - Message reactions and pinning
/// - Read receipts

/// Your project's public key from Abrova Console. Pass it when you run the app:
///
///   flutter run --dart-define=ABROVA_API_KEY=ab_live_...
const String abrovaApiKey = String.fromEnvironment(
  'ABROVA_API_KEY',
  defaultValue: 'ab_live_YOUR_PUBLIC_KEY',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AbrovaPush.init(const AbrovaPushConfig(
    apiKey: abrovaApiKey,
    showNotificationInForeground: true,
  ));

  AbrovaPush.onMessage((message) {
    debugPrint('AbrovaPush message: ${message.title} - ${message.body}');
  });

  AbrovaPush.onRegistered((deviceId) {
    debugPrint('AbrovaPush registered with deviceId: $deviceId');
  });

  AbrovaPush.onError((error) {
    debugPrint('AbrovaPush ERROR: $error');
  });

  AbrovaPush.onDetailedError((error) {
    debugPrint(
        'AbrovaPush DETAILED ERROR: code=${error.code}, message=${error.message}');
  });

  AbrovaPush.onNotificationTapped((notification) {
    debugPrint('Notification tapped: ${notification.data}');
  });

  runApp(const AbrovaChatEcommerceApp());
}

class AbrovaChatEcommerceApp extends StatefulWidget {
  const AbrovaChatEcommerceApp({super.key});

  @override
  State<AbrovaChatEcommerceApp> createState() => _AbrovaChatEcommerceAppState();
}

class _AbrovaChatEcommerceAppState extends State<AbrovaChatEcommerceApp> {
  // In a real app, these would come from your auth system
  String? _currentUserId;
  String? _currentUserName;
  String? _userRole; // 'buyer' or 'seller'

  // Your project's public key (see [abrovaApiKey]).
  static const String _apiKey = abrovaApiKey;

  void _onLogin(String userId, String userName, String role) {
    debugPrint(
        '_onLogin called: userId=$userId, userName=$userName, role=$role');
    setState(() {
      _currentUserId = userId;
      _currentUserName = userName;
      _userRole = role;
    });
    debugPrint('Calling AbrovaPush.register...');
    AbrovaPush.register(
        userId: userId,
        metadata: {'displayName': userName, 'role': role}).then((_) {
      debugPrint('AbrovaPush.register() completed (async result returned)');
    }).catchError((e) {
      debugPrint('AbrovaPush.register() FAILED: $e');
    });
    AbrovaPush.getDeviceId()
        .then((id) => debugPrint('AbrovaPush deviceId: $id'));
  }

  void _onLogout() {
    AbrovaPush.unregister();
    setState(() {
      _currentUserId = null;
      _currentUserName = null;
      _userRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return MaterialApp(
        title: 'AbrovaChat E-commerce Demo',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: LoginScreen(onLogin: _onLogin),
      );
    }

    // Create AbrovaChat configuration with file uploader
    final config = AbrovaChatConfig(
      apiKey: _apiKey,
      userId: _currentUserId!,
      userInfo: {
        'displayName': _currentUserName,
        'role': _userRole,
      },
      fileUploader: FileUploadService.uploadFile,
    );

    // AbrovaChatScope wraps MaterialApp so all Navigator routes inherit it
    return AbrovaChatScope(
      config: config,
      autoConnect: true,
      onConnected: () {
        debugPrint('AbrovaChat connected!');
      },
      onError: (error) {
        debugPrint('AbrovaChat error: $error');
      },
      child: MaterialApp(
        title: 'AbrovaChat E-commerce Demo',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: OrdersScreen(
          currentUserId: _currentUserId!,
          currentUserName: _currentUserName!,
          userRole: _userRole!,
          onLogout: _onLogout,
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}

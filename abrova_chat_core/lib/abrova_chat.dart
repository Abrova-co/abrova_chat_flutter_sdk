/// AbrovaChat SDK - Headless chat-as-a-service for Flutter.
///
/// This is a minimal, unopinionated SDK that works with any state management.
/// For pre-built UI widgets, use the `abrova_chat_ui` package.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:abrova_chat/abrova_chat.dart';
///
/// // Configure
/// final config = AbrovaChatConfig(
///   apiKey: 'your-api-key',
///   userId: 'user-123',
/// );
///
/// // Create client
/// final client = AbrovaChatClient(config);
///
/// // Connect
/// await client.connect();
///
/// // Subscribe to a room
/// await client.subscribeRoom('room-id');
///
/// // Listen to messages
/// client.onMessage.listen((message) {
///   print('New message: ${message.content}');
/// });
///
/// // Send a message
/// await client.sendMessage('room-id', content: 'Hello!');
///
/// // Cleanup
/// client.dispose();
/// ```
library abrova_chat;

// Config
export 'src/config.dart';

// SDK identity
export 'src/version.dart' show abrovaChatSdkName, abrovaChatSdkVersion;

// Client
export 'src/abrova_chat_client.dart';

// Models
export 'src/models/enums.dart';
export 'src/models/attachment.dart';
export 'src/models/reaction.dart';
export 'src/models/message.dart';
export 'src/models/participant.dart';
export 'src/models/room.dart';
export 'src/models/unread_summary.dart';
export 'src/models/search_result.dart';

// Events
export 'src/events/events.dart';

// Offline outbox
export 'src/outbox/outbox_store.dart';
export 'src/outbox/pending_message.dart';

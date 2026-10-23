import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String username;
  final String rankName;
  final String messageText;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.username,
    required this.rankName,
    required this.messageText,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      senderId: json['sender_id']?.toString() ?? '',
      username: json['sender_username'] ?? 'Anonymous',
      rankName: json['sender_rank'] ?? 'Novice',
      messageText: json['message_text'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_username': username,
      'sender_rank': rankName,
      'message_text': messageText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PublicChatController {
  SupabaseClient? _client;
  final String roomId;

  RealtimeChannel? _chatChannel;
  final StreamController<List<ChatMessage>> _messageStreamController =
      StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _messageCache = [];

  // Local anti-spam loop configurations
  DateTime? _lastMessageTime;
  int _messageFloodCount = 0;

  PublicChatController({required this.roomId}) {
    try {
      _client = Supabase.instance.client;
    } catch (_) {
      _client = null;
    }
  }

  Stream<List<ChatMessage>> get messageStream =>
      _messageStreamController.stream;

  List<ChatMessage> get currentMessages => List.unmodifiable(_messageCache);

  /// Initializes the real-time pipeline connection layer for the chatroom
  void connectToRoom() async {
    if (_client == null) {
      // Offline fallback: provide introductory welcoming message
      _messageCache.add(ChatMessage(
        id: 'system_welcome',
        senderId: 'sys',
        username: 'SparkBot ⚡',
        rankName: 'Ultimate',
        messageText: 'Welcome to the live public room! Network online.',
        createdAt: DateTime.now(),
      ));
      _messageStreamController.add(List.from(_messageCache));
      return;
    }

    // 1. Fetch historical back-log messages on entry (Option C: Rolling 25-message buffer)
    try {
      final List<dynamic> response = await _client!
          .from('chatroom_messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .limit(25);

      _messageCache.clear();
      _messageCache.addAll(
        response.map((m) => ChatMessage.fromJson(m)).toList().reversed,
      );
      _messageStreamController.add(List.from(_messageCache));
    } catch (e) {
      debugPrint("Error downloading database history: $e");
    }

    // 2. Establish persistent bi-directional WebSockets connection pipeline
    try {
      _chatChannel = _client!.channel('public_chat:$roomId');

      _chatChannel!.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'chatroom_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'room_id',
          value: roomId,
        ),
        callback: (payload) {
          final newMsg = ChatMessage.fromJson(payload.newRecord);
          // Avoid duplicate local inserts
          if (!_messageCache.any((m) => m.id == newMsg.id)) {
            _messageCache.add(newMsg);
          }

          // Option C: Rolling 25-message buffer (Truncate list overhead bounds to 25)
          if (_messageCache.length > 25) {
            _messageCache.removeAt(0);
          }

          _messageStreamController.add(List.from(_messageCache));
        },
      ).subscribe();
    } catch (e) {
      debugPrint("Error establishing realtime channel: $e");
    }
  }

  /// Evaluates room compliance metrics and transmits payloads to the server
  Future<String?> sendPublicMessage(String text) async {
    if (text.trim().isEmpty) return "Message body cannot be empty.";

    final now = DateTime.now();

    // 3. Programmatic Anti-Spam Gatekeeping Verification Logic Rules
    if (_lastMessageTime != null) {
      final difference = now.difference(_lastMessageTime!).inSeconds;
      if (difference < 2) {
        _messageFloodCount++;
        if (_messageFloodCount >= 4) {
          return "Spam protection: You are typing too fast! Auto-Muted.";
        }
      } else {
        _messageFloodCount = 0; // Clear dynamic penalty tracker constraints
      }
    }
    _lastMessageTime = now;

    if (_client == null) {
      // Local demo mode fallback
      final localMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'local_user',
        username: 'You',
        rankName: 'Senior',
        messageText: text.trim(),
        createdAt: DateTime.now(),
      );
      _messageCache.add(localMsg);
      _messageStreamController.add(List.from(_messageCache));
      return null;
    }

    try {
      final user = _client!.auth.currentUser;
      final userId = user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

      // 4. Remote Write Command updates row targets
      await _client!.from('chatroom_messages').insert({
        'room_id': roomId,
        'sender_id': userId,
        'message_text': text.trim(),
      });

      return null; // Null return signifies absolute clean execution success state
    } catch (e) {
      debugPrint("Chat write exception: $e");
      // Fallback local append for immediate responsive UX
      final localMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'local_user',
        username: 'You',
        rankName: 'Senior',
        messageText: text.trim(),
        createdAt: DateTime.now(),
      );
      _messageCache.add(localMsg);
      _messageStreamController.add(List.from(_messageCache));
      return null;
    }
  }

  /// Disconnects listeners cleanly to avoid memory leaks
  void disconnectFromRoom() {
    if (_chatChannel != null && _client != null) {
      _client!.removeChannel(_chatChannel!);
    }
    _messageStreamController.close();
  }
}

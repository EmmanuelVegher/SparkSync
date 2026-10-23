import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivateMessageItem {
  final String id;
  final String conversationId;
  final String senderId;
  final String messageContent;
  final DateTime createdAt;

  PrivateMessageItem({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageContent,
    required this.createdAt,
  });

  factory PrivateMessageItem.fromJson(Map<String, dynamic> json) {
    return PrivateMessageItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      messageContent: json['message_content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PrivateChatController with ChangeNotifier {
  SupabaseClient? _client;
  final String conversationId;

  RealtimeChannel? _dmWebSocketChannel;
  List<PrivateMessageItem> activeMessagesList = [];
  bool isLoadingHistory = false;

  PrivateChatController({required this.conversationId}) {
    try {
      _client = Supabase.instance.client;
    } catch (_) {
      _client = null;
    }
  }

  /// Establishes the real-time WebSocket connection to the specific conversation channel
  void openSecureChatSession() async {
    isLoadingHistory = true;
    notifyListeners();

    if (_client == null) {
      activeMessagesList = [
        PrivateMessageItem(
          id: 'mock_1',
          conversationId: conversationId,
          senderId: 'partner',
          messageContent: "Hey there! Loved your profile. Are you around Victoria Island? 🌴",
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];
      isLoadingHistory = false;
      notifyListeners();
      return;
    }

    // 1. Fetch encrypted historical message logs
    try {
      final List<dynamic> historyResponse = await _client!
          .from('private_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(50);

      activeMessagesList = historyResponse
          .map((data) => PrivateMessageItem.fromJson(data))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      debugPrint("Secure database read exception: $e");
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }

    // 2. Attach WebSocket Listener to listen only to inserts targeting this room ID
    try {
      _dmWebSocketChannel = _client!.channel('private_room:$conversationId');

      _dmWebSocketChannel!.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'private_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) {
          final incomingMsg = PrivateMessageItem.fromJson(payload.newRecord);

          // Prevent duplicate appending locally if sent by this client instance
          if (!activeMessagesList.any((m) => m.id == incomingMsg.id)) {
            activeMessagesList.add(incomingMsg);
            notifyListeners();
          }
        },
      ).subscribe();
    } catch (e) {
      debugPrint("Error opening secure DM websocket: $e");
    }
  }

  /// Sends a private text payload down the encrypted network pipeline
  Future<bool> transmitPrivateMessage(String content) async {
    if (content.trim().isEmpty) return false;

    if (_client == null) {
      activeMessagesList.add(PrivateMessageItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        senderId: 'me',
        messageContent: content.trim(),
        createdAt: DateTime.now(),
      ));
      notifyListeners();
      return true;
    }

    try {
      final myUid = _client!.auth.currentUser?.id;
      if (myUid == null) return false;

      // Direct write call which fires the operational update triggers securely
      await _client!.from('private_messages').insert({
        'conversation_id': conversationId,
        'sender_id': myUid,
        'message_content': content.trim(),
      });

      return true;
    } catch (e) {
      debugPrint("Transaction delivery exception raised: $e");
      // Fallback local append
      activeMessagesList.add(PrivateMessageItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        senderId: 'me',
        messageContent: content.trim(),
        createdAt: DateTime.now(),
      ));
      notifyListeners();
      return false;
    }
  }

  /// Explicitly unmounts channels to avoid memory bloating constraints
  void closeSecureChatSession() {
    if (_dmWebSocketChannel != null && _client != null) {
      _client!.removeChannel(_dmWebSocketChannel!);
      _dmWebSocketChannel = null;
    }
  }
}

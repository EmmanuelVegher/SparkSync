import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/private_chat_controller.dart';

class PrivateChatScreen extends StatefulWidget {
  final String conversationId;
  final String matchName;

  const PrivateChatScreen({
    super.key,
    required this.conversationId,
    required this.matchName,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  late PrivateChatController _chatController;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    try {
      currentUserId = Supabase.instance.client.auth.currentUser?.id ?? 'me';
    } catch (_) {
      currentUserId = 'me';
    }
    _chatController =
        PrivateChatController(conversationId: widget.conversationId);
    _chatController.openSecureChatSession();
    _chatController.addListener(_autoScrollToBottom);
  }

  @override
  void dispose() {
    _chatController.removeListener(_autoScrollToBottom);
    _chatController.closeSecureChatSession();
    _inputController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _autoScrollToBottom() {
    if (_listScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listScrollController.hasClients) {
          _listScrollController.animateTo(
            _listScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16162A),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF252545),
              child: Text(
                widget.matchName.isNotEmpty
                    ? widget.matchName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.matchName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    "🔒 Encrypted Match Room",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _chatController,
              builder: (context, _) {
                if (_chatController.isLoadingHistory) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.pinkAccent),
                  );
                }

                final messages = _chatController.activeMessagesList;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet. Say hi to break the ice! 🥂",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _listScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.senderId == currentUserId ||
                        msg.senderId == 'me';
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInputFieldDock(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(PrivateMessageItem msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF6C63FF) : const Color(0xFF252545),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          msg.messageContent,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputFieldDock() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF16162A),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Send a secure message...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  fillColor: const Color(0xFF0F0F1E),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _transmit(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 16),
                onPressed: _transmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _transmit() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    await _chatController.transmitPrivateMessage(text);
  }
}

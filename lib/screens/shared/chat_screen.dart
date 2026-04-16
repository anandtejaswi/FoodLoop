// ============================================================
// screens/shared/chat_screen.dart
// Widgets: Scaffold, AppBar, ListView, Container, Row, Column,
//          Text, TextField, IconButton, Align, SizedBox, Padding
// ============================================================

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class _ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  const _ChatMessage({required this.text, required this.isMe, required this.time});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // TextEditingController – message input field
  final _inputCtrl    = TextEditingController();
  // ScrollController – auto-scroll to bottom
  final _scrollCtrl   = ScrollController();

  // Sample initial messages (replace with API calls for real chat)
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Hi! Is the food still available?',        isMe: false, time: DateTime.now().subtract(const Duration(minutes: 10))),
    _ChatMessage(text: 'Yes! Come between 5-7 PM please.',        isMe: true,  time: DateTime.now().subtract(const Duration(minutes: 8))),
    _ChatMessage(text: 'Sure, I\'ll be there at 5:30. Thank you!', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 5))),
    _ChatMessage(text: 'Great! See you then 😊',                   isMe: true,  time: DateTime.now().subtract(const Duration(minutes: 3))),
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true, time: DateTime.now()));
    });
    _inputCtrl.clear();
    // Scroll to bottom after send
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // ── Bubble builder ────────────────────────────────────────
  Widget _bubble(_ChatMessage msg) {
    final isMe = msg.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Text – message content
            Text(msg.text, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: isMe ? Colors.white : AppTheme.textPrimary, height: 1.4)),
            const SizedBox(height: 4),
            // Text – timestamp
            Text(
              '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: isMe ? Colors.white60 : AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold – chat page layout
    return Scaffold(
      // AppBar – giver name + avatar
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            // CircleAvatar – contact avatar
            const CircleAvatar(radius: 18, backgroundColor: Colors.white30, child: Icon(Icons.person, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rahul Kumar', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('Online', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
        ],
      ),

      body: Column(
        children: [
          // ListView – scrollable message list
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _bubble(_messages[i]),
              ),
            ),
          ),

          // ── Message input bar ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // IconButton – attachment
                  IconButton(icon: const Icon(Icons.attach_file_rounded, color: AppTheme.textSecondary), onPressed: () {}),
                  // Expanded TextField – message input
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        hintStyle: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button – circular button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 46, height: 46,
                      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/core/database/database.dart';
import 'package:drift/drift.dart' hide Column;

class ChatPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const ChatPage({super.key, this.initialQuery});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _sendMessage(widget.initialQuery!);
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      await ref.read(aiRepositoryProvider).chat(text);
    } catch (e) {
      // Handled inside AI repo
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      body: Column(
        children: [
          // Message History Area
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: (db.select(db.chats)
                    ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
                  .watch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: OneDarkTheme.primary),
                  );
                }

                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                // Trigger scroll down when messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const _LoadingBubble();
                    }
                    final msg = messages[index];
                    return _ChatBubble(
                      isUser: msg.role == 'user',
                      content: msg.content,
                      timestamp: msg.timestamp,
                    );
                  },
                );
              },
            ),
          ),

          // Divider
          const Divider(),

          // Chat Input Area
          Container(
            padding: const EdgeInsets.all(20),
            color: OneDarkTheme.background,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: OneDarkTheme.error),
                  tooltip: 'Clear Chat History',
                  onPressed: () {
                    ref.read(aiRepositoryProvider).clearHistory();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14, color: OneDarkTheme.textLight),
                    decoration: const InputDecoration(
                      hintText: 'Ask your academic assistant...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (val) {
                      _sendMessage(val);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: const Icon(Icons.send, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: OneDarkTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OneDarkTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt,
                color: OneDarkTheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'How can I help you today?',
              style: TextStyle(
                color: OneDarkTheme.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask me to schedule a study session, view assignments, '
              'or search your Google Drive documents.',
              textAlign: TextAlign.center,
              style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _QuickPromptChip(
                  label: 'What deadlines do I have?',
                  onTap: () => _sendMessage('What deadlines do I have?'),
                ),
                _QuickPromptChip(
                  label: 'Schedule ML study tomorrow',
                  onTap: () => _sendMessage('Schedule a study session for Machine Learning tomorrow'),
                ),
                _QuickPromptChip(
                  label: 'Summarize today\'s emails',
                  onTap: () => _sendMessage('Summarize today\'s academic emails'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final String content;
  final DateTime timestamp;

  const _ChatBubble({
    required this.isUser,
    required this.content,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? OneDarkTheme.primary.withOpacity(0.15) : OneDarkTheme.cardBg,
          border: Border.all(
            color: isUser ? OneDarkTheme.primary.withOpacity(0.3) : OneDarkTheme.border,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13.5, height: 1.45),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: OneDarkTheme.cardBg,
          border: Border.all(color: OneDarkTheme.border),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: OneDarkTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: OneDarkTheme.cardBg,
          border: Border.all(color: OneDarkTheme.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 12),
        ),
      ),
    );
  }
}

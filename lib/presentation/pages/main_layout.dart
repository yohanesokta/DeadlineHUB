import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/core/services/sync/sync_status_repository.dart';
import 'package:deadlinehub/features/ai/domain/repositories/ai_repository.dart';
import 'package:deadlinehub/core/database/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_svg/flutter_svg.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final TextEditingController _promptController = TextEditingController();
  bool _rightPanelExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncCoordinatorProvider).startPeriodicSync();
    });
  }

  @override
  void dispose() {
    ref.read(syncCoordinatorProvider).stopPeriodicSync();
    _promptController.dispose();
    super.dispose();
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') return 0;
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/drive')) return 3;
    if (location.startsWith('/classroom')) return 4;
    if (location.startsWith('/email')) return 5;
    if (location.startsWith('/settings')) return 6;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        context.go('/drive');
        break;
      case 4:
        context.go('/classroom');
        break;
      case 5:
        context.go('/email');
        break;
      case 6:
        context.go('/settings');
        break;
    }
  }

  void _submitGlobalPrompt() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;
    _promptController.clear();
    context.go('/chat?query=${Uri.encodeComponent(text)}');
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: OneDarkTheme.background,
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 240,
            color: OneDarkTheme.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / App Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: OneDarkTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DeadlineAI',
                        style: TextStyle(
                          color: OneDarkTheme.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _SidebarItem(
                        iconPath: 'assets/icons/insights.svg',
                        label: 'Insights',
                        isSelected: selectedIndex == 0,
                        onTap: () => _onItemTapped(0, context),
                      ),
                      _SidebarItem(
                        iconPath: 'assets/icons/ai_chat.svg',
                        label: 'AI Chat',
                        isSelected: selectedIndex == 1,
                        onTap: () => _onItemTapped(1, context),
                      ),
                      _SidebarItem(
                        iconPath: 'assets/icons/calendar.svg',
                        label: 'Calendar',
                        isSelected: selectedIndex == 2,
                        onTap: () => _onItemTapped(2, context),
                      ),
                      _SidebarItem(
                        iconPath: 'assets/icons/drive.svg',
                        label: 'Google Drive',
                        isSelected: selectedIndex == 3,
                        onTap: () => _onItemTapped(3, context),
                      ),
                      _SidebarItem(
                        iconPath: 'assets/icons/classroom.svg',
                        label: 'Classroom',
                        isSelected: selectedIndex == 4,
                        onTap: () => _onItemTapped(4, context),
                      ),
                      _SidebarItem(
                        iconPath: 'assets/icons/email.svg',
                        label: 'Academic Email',
                        isSelected: selectedIndex == 5,
                        onTap: () => _onItemTapped(5, context),
                      ),
                      _SidebarItem(
                        iconPath: 'assets/icons/settings.svg',
                        label: 'Settings',
                        isSelected: selectedIndex == 6,
                        onTap: () => _onItemTapped(6, context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Integration Status Center
                const _IntegrationStatusCenter(),
                // Bottom Profile info
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: profileAsync.when(
                    data: (profile) {
                      final name = profile?.name ?? 'Student User';
                      final email = profile?.email ?? 'student@university.edu';
                      final picture = profile?.picture ?? '';
                      final hasPicture = picture.isNotEmpty;

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: OneDarkTheme.border,
                            backgroundImage: hasPicture ? NetworkImage(picture) : null,
                            child: !hasPicture
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                    style: const TextStyle(color: OneDarkTheme.primary, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  email,
                                  style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, size: 16, color: OneDarkTheme.textMain),
                            onPressed: () {
                              ref.read(authRepositoryProvider).signOut();
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => Row(
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: OneDarkTheme.primary),
                        ),
                        SizedBox(width: 12),
                        Text('Loading profile...', style: TextStyle(color: OneDarkTheme.textDark, fontSize: 11)),
                      ],
                    ),
                    error: (err, stack) => Row(
                      children: const [
                        Icon(Icons.error_outline, color: OneDarkTheme.error, size: 16),
                        SizedBox(width: 12),
                        Text('Error loading profile', style: TextStyle(color: OneDarkTheme.error, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Vertical divider
          const VerticalDivider(),

          // Center Panel Content & Persistent bottom prompt bar
          Expanded(
            child: Container(
              color: OneDarkTheme.surface,
              child: Column(
                children: [
                  // Toolbar
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          _getToolbarTitle(selectedIndex),
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (selectedIndex != 1)
                          IconButton(
                            icon: Icon(
                              _rightPanelExpanded ? Icons.splitscreen : Icons.splitscreen_outlined,
                              size: 20,
                              color: OneDarkTheme.textMain,
                            ),
                            onPressed: () {
                              setState(() {
                                _rightPanelExpanded = !_rightPanelExpanded;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Sub-page Content
                  Expanded(
                    child: widget.child,
                  ),

                  const Divider(),
                  // Bottom Global Prompt Box (Raycast style)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: OneDarkTheme.cardBg,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promptController,
                                style: const TextStyle(fontSize: 14, color: OneDarkTheme.textLight),
                                decoration: const InputDecoration(
                                  hintText: 'Ask DeadlineAI anything... (e.g. show deadlines, schedule study session)',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onSubmitted: (_) => _submitGlobalPrompt(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filled(
                              onPressed: _submitGlobalPrompt,
                              icon: const Icon(Icons.arrow_upward, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: OneDarkTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const _AiTaskTimeline(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contextual Right Panel (Collapsible)
          if (_rightPanelExpanded && selectedIndex != 1) ...[
            const VerticalDivider(),
            const _RightAiAssistantPanel(),
          ]
        ],
      ),
    );
  }

  String _getToolbarTitle(int index) {
    switch (index) {
      case 0:
        return 'Daily Insights';
      case 1:
        return 'AI Conversational Assistant';
      case 2:
        return 'Smart Calendar & Planner';
      case 3:
        return 'Google Drive Files';
      case 4:
        return 'Classroom Deadline Monitor';
      case 5:
        return 'Gmail Academic Inbox';
      case 6:
        return 'Preferences & API Keys';
      default:
        return 'DeadlineAI';
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? OneDarkTheme.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            ListTile(
              onTap: onTap,
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: SvgPicture.asset(
                iconPath,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isSelected ? OneDarkTheme.primary : OneDarkTheme.textMain,
                  BlendMode.srcIn,
                ),
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: isSelected ? OneDarkTheme.textLight : OneDarkTheme.textMain,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: Container(
                  color: OneDarkTheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IntegrationStatusCenter extends ConsumerStatefulWidget {
  const _IntegrationStatusCenter();

  @override
  ConsumerState<_IntegrationStatusCenter> createState() => _IntegrationStatusCenterState();
}

class _IntegrationStatusCenterState extends ConsumerState<_IntegrationStatusCenter> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return 'Never';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final syncStatusAsync = ref.watch(syncStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'INTEGRATION STATUS',
            style: TextStyle(
              color: OneDarkTheme.textDark,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        syncStatusAsync.when(
          data: (status) {
            return Column(
              children: [
                _buildSyncTile(
                  label: 'Calendar',
                  status: status.calendar,
                  retryCallback: () => ref.read(syncCoordinatorProvider).syncCalendar(),
                ),
                _buildSyncTile(
                  label: 'Drive',
                  status: status.drive,
                  retryCallback: () => ref.read(syncCoordinatorProvider).syncDrive(),
                ),
                _buildSyncTile(
                  label: 'Classroom',
                  status: status.classroom,
                  retryCallback: () => ref.read(syncCoordinatorProvider).syncClassroom(),
                ),
                _buildSyncTile(
                  label: 'Gmail',
                  status: status.gmail,
                  retryCallback: () => ref.read(syncCoordinatorProvider).syncGmail(),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: OneDarkTheme.primary),
              ),
            ),
          ),
          error: (e, s) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Error loading sync status: $e',
              style: const TextStyle(color: OneDarkTheme.error, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSyncTile({
    required String label,
    required ModuleSyncStatus status,
    required VoidCallback retryCallback,
  }) {
    String stateText = '';
    Color textColor = OneDarkTheme.textMain;
    Widget? actionWidget;

    switch (status.state) {
      case SyncState.idle:
        stateText = 'Synced ${_formatTimeAgo(status.lastSynced)}';
        textColor = OneDarkTheme.textMain;
        break;
      case SyncState.syncing:
        stateText = 'Syncing...';
        textColor = OneDarkTheme.primary;
        break;
      case SyncState.failed:
        stateText = '$label Sync Failed';
        textColor = OneDarkTheme.error;
        actionWidget = InkWell(
          onTap: retryCallback,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              'Retry',
              style: TextStyle(
                color: OneDarkTheme.cyan,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: status.state == SyncState.syncing
                      ? OneDarkTheme.primary
                      : status.state == SyncState.failed
                          ? OneDarkTheme.error
                          : OneDarkTheme.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: OneDarkTheme.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                stateText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                ),
              ),
              if (actionWidget != null) ...[
                const SizedBox(width: 8),
                actionWidget,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AiTaskTimeline extends ConsumerWidget {
  const _AiTaskTimeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(aiTaskEventsProvider);

    return eventsAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'AI ACTIVITY LOG',
                  style: TextStyle(
                    color: OneDarkTheme.textDark,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...tasks.map((task) {
                IconData icon;
                Color color;
                switch (task.state) {
                  case TaskState.pending:
                    icon = Icons.circle_outlined;
                    color = OneDarkTheme.textDark;
                    break;
                  case TaskState.running:
                    icon = Icons.play_circle_outline_rounded;
                    color = OneDarkTheme.primary;
                    break;
                  case TaskState.completed:
                    icon = Icons.check_circle_outline_rounded;
                    color = OneDarkTheme.success;
                    break;
                  case TaskState.failed:
                    icon = Icons.error_outline_rounded;
                    color = OneDarkTheme.error;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      if (task.state == TaskState.running)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OneDarkTheme.primary,
                          ),
                        )
                      else
                        Icon(icon, size: 14, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: task.state == TaskState.running
                                ? OneDarkTheme.textLight
                                : OneDarkTheme.textMain,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        task.state.name.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _RightAiAssistantPanel extends ConsumerStatefulWidget {
  const _RightAiAssistantPanel();

  @override
  ConsumerState<_RightAiAssistantPanel> createState() => _RightAiAssistantPanelState();
}

class _RightAiAssistantPanelState extends ConsumerState<_RightAiAssistantPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Container(
      width: 300,
      color: OneDarkTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Academic Assistant',
                  style: TextStyle(
                    color: OneDarkTheme.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: OneDarkTheme.error, size: 18),
                  tooltip: 'Clear History',
                  onPressed: () {
                    ref.read(aiRepositoryProvider).clearHistory();
                  },
                ),
              ],
            ),
          ),
          
          const Divider(),

          // Chat Messages
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: (db.select(db.chats)
                    ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
                  .watch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: OneDarkTheme.primary),
                  );
                }

                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Tanya saya tentang deadline, jadwal kuliah, atau file Drive Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: OneDarkTheme.textDark, fontSize: 13),
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: OneDarkTheme.primary),
                          ),
                        ),
                      );
                    }
                    final msg = messages[index];
                    final isUser = msg.role == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? OneDarkTheme.primary.withOpacity(0.15) : OneDarkTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUser ? OneDarkTheme.primary.withOpacity(0.3) : OneDarkTheme.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isUser ? 'You' : 'AI',
                              style: TextStyle(
                                color: isUser ? OneDarkTheme.primary : OneDarkTheme.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _SidebarMarkdownText(content: msg.content),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Quick Action Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _QuickActionChip(
                  label: "Apa deadline saya?",
                  onTap: () => _sendMessage("Apa deadline saya?"),
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: "Jadwalkan belajar besok",
                  onTap: () => _sendMessage("Jadwalkan belajar besok"),
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: "Analisis tugas tersulit",
                  onTap: () => _sendMessage("Analisis tugas tersulit"),
                ),
              ],
            ),
          ),

          const Divider(),

          // Chat Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 13, color: OneDarkTheme.textLight),
                    decoration: InputDecoration(
                      hintText: 'Tanya asisten...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      fillColor: OneDarkTheme.cardBg,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: OneDarkTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: OneDarkTheme.border),
                      ),
                    ),
                    onSubmitted: (val) {
                      _sendMessage(val);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: OneDarkTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMarkdownText extends StatelessWidget {
  final String content;

  const _SidebarMarkdownText({required this.content});

  List<InlineSpan> _parseInline(String inlineText, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    final RegExp exp = RegExp(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)');
    int start = 0;

    final matches = exp.allMatches(inlineText);
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: inlineText.substring(start, match.start),
          style: baseStyle,
        ));
      }

      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        spans.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        spans.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.white.withOpacity(0.08),
          ),
        ));
      }

      start = match.end;
    }

    if (start < inlineText.length) {
      spans.add(TextSpan(
        text: inlineText.substring(start),
        style: baseStyle,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium ?? const TextStyle(color: OneDarkTheme.textMain, fontSize: 13);
    
    final List<Widget> children = [];
    final lines = content.split('\n');
    
    bool inCodeBlock = false;
    List<String> codeBlockLines = [];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().startsWith('```')) {
        if (inCodeBlock) {
          final codeContent = codeBlockLines.join('\n');
          children.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E222A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: OneDarkTheme.border),
              ),
              child: SelectableText(
                codeContent,
                style: style.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: const Color(0xFFABB2BF),
                ),
              ),
            ),
          );
          codeBlockLines.clear();
          inCodeBlock = false;
        } else {
          inCodeBlock = true;
        }
        continue;
      }

      if (inCodeBlock) {
        codeBlockLines.add(line);
        continue;
      }

      final trimmed = line.trim();

      if (trimmed.startsWith('# ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              trimmed.substring(2),
              style: style.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('## ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              trimmed.substring(3),
              style: style.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              trimmed.substring(4),
              style: style.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final contentText = trimmed.substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: style.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInline(contentText, style),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (trimmed.isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: RichText(
              text: TextSpan(
                children: _parseInline(line, style),
              ),
            ),
          ),
        );
      } else {
        children.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: OneDarkTheme.border,
          border: Border.all(color: OneDarkTheme.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: OneDarkTheme.textLight,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

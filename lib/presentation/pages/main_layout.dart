import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/core/services/sync/sync_status_repository.dart';
import 'package:deadlinehub/features/ai/domain/repositories/ai_repository.dart';

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
                        icon: Icons.dashboard_outlined,
                        label: 'Insights',
                        isSelected: selectedIndex == 0,
                        onTap: () => _onItemTapped(0, context),
                      ),
                      _SidebarItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'AI Chat',
                        isSelected: selectedIndex == 1,
                        onTap: () => _onItemTapped(1, context),
                      ),
                      _SidebarItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Calendar',
                        isSelected: selectedIndex == 2,
                        onTap: () => _onItemTapped(2, context),
                      ),
                      _SidebarItem(
                        icon: Icons.folder_open_outlined,
                        label: 'Google Drive',
                        isSelected: selectedIndex == 3,
                        onTap: () => _onItemTapped(3, context),
                      ),
                      _SidebarItem(
                        icon: Icons.school_outlined,
                        label: 'Classroom',
                        isSelected: selectedIndex == 4,
                        onTap: () => _onItemTapped(4, context),
                      ),
                      _SidebarItem(
                        icon: Icons.mail_outline,
                        label: 'Academic Email',
                        isSelected: selectedIndex == 5,
                        onTap: () => _onItemTapped(5, context),
                      ),
                      _SidebarItem(
                        icon: Icons.settings_outlined,
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
          if (_rightPanelExpanded) ...[
            const VerticalDivider(),
            Container(
              width: 280,
              color: OneDarkTheme.background,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Academic Overview',
                    style: TextStyle(
                      color: OneDarkTheme.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Today's summary widget
                  _QuickStatCard(
                    title: "Today's Schedule",
                    value: "1 Class",
                    icon: Icons.calendar_today,
                    color: OneDarkTheme.cyan,
                  ),
                  const SizedBox(height: 12),
                  _QuickStatCard(
                    title: "Assignments Pending",
                    value: "3 Items",
                    icon: Icons.assignment_late,
                    color: OneDarkTheme.warning,
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'AI Recommendation',
                    style: TextStyle(
                      color: OneDarkTheme.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: OneDarkTheme.cardBg,
                      border: Border.all(color: OneDarkTheme.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'You have 2 deadlines within the next 48 hours (Machine Learning & PKM Proposal). '
                      'Ask me: "Schedule study session for ML" to block out time.',
                      style: TextStyle(
                        color: OneDarkTheme.textMain,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isSelected ? OneDarkTheme.border.withOpacity(0.3) : Colors.transparent,
        leading: Icon(
          icon,
          size: 18,
          color: isSelected ? OneDarkTheme.primary : OneDarkTheme.textMain,
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
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OneDarkTheme.cardBg,
        border: Border.all(color: OneDarkTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 16,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          )
        ],
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

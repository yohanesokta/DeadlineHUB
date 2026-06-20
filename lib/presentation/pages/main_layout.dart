import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final TextEditingController _promptController = TextEditingController();
  bool _rightPanelExpanded = true;

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
                // Bottom Profile info
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: OneDarkTheme.border,
                        child: Text(
                          'S',
                          style: TextStyle(color: OneDarkTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student User',
                              style: TextStyle(color: OneDarkTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'student@university.edu',
                              style: TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
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
                    child: Row(
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

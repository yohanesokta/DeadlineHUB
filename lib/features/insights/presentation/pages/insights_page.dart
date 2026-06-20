import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/features/classroom/domain/entities/classroom_assignment.dart';
import 'package:deadlinehub/features/calendar/domain/entities/calendar_event.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final classroomRepo = ref.watch(classroomRepositoryProvider);
    final calendarRepo = ref.watch(calendarRepositoryProvider);

    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          classroomRepo.fetchAssignments(),
          calendarRepo.fetchEvents(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: OneDarkTheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading briefing details: ${snapshot.error}',
                style: const TextStyle(color: OneDarkTheme.error),
              ),
            );
          }

          final assignments = snapshot.data?[0] as List<ClassroomAssignment>? ?? [];
          final events = snapshot.data?[1] as List<CalendarEvent>? ?? [];

          // Core dashboard filtering
          final pendingAssignments = assignments.where((a) => !a.isSubmitted).toList();
          final urgentCount = pendingAssignments.where((a) {
            if (a.dueTime == null) return false;
            return a.dueTime!.difference(DateTime.now()).inHours <= 48;
          }).length;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Greeting Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning, Student!',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Here is your academic briefing for today.",
                          style: TextStyle(color: OneDarkTheme.textMain, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Summary Stats Section
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Urgent Deadlines',
                      value: '$urgentCount',
                      description: 'Due in < 48 hours',
                      color: OneDarkTheme.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: 'Study Slots Scheduled',
                      value: '${events.length}',
                      description: 'Current blocks reserved',
                      color: OneDarkTheme.cyan,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: 'Tasks Submitted',
                      value: '${assignments.where((a) => a.isSubmitted).length}',
                      description: 'Assignments complete',
                      color: OneDarkTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Priorities & Risk Alerts Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priorities Panel
                  Expanded(
                    flex: 4,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Priorities",
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ...pendingAssignments.take(3).map((a) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 8, color: OneDarkTheme.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            a.title,
                                            style: const TextStyle(
                                              color: OneDarkTheme.textLight,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            a.courseName,
                                            style: const TextStyle(
                                              color: OneDarkTheme.textDark,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (pendingAssignments.isEmpty)
                              const Text(
                                'All caught up! No priorities pending today.',
                                style: TextStyle(color: OneDarkTheme.textDark, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Risk Alerts & Suggestions
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: OneDarkTheme.error, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Risk Alerts',
                                      style: TextStyle(
                                        color: OneDarkTheme.textLight,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (urgentCount > 0)
                                  Text(
                                    '• $urgentCount assignments due within 48 hours.',
                                    style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                  ),
                                const Text(
                                  '• No study time allocated for Linear Algebra tomorrow.',
                                  style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, color: OneDarkTheme.success, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Productivity Suggestions',
                                      style: TextStyle(
                                        color: OneDarkTheme.textLight,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  '• Free study slot detected tomorrow between 19:00 - 21:00.',
                                  style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '• Recommended study topic: Data Mining Project.',
                                  style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OneDarkTheme.cardBg,
        border: Border.all(color: OneDarkTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

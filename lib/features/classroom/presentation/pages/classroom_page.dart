import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/features/classroom/domain/entities/classroom_assignment.dart';

class ClassroomPage extends ConsumerStatefulWidget {
  const ClassroomPage({super.key});

  @override
  ConsumerState<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends ConsumerState<ClassroomPage> {
  List<ClassroomAssignment> _assignments = [];
  bool _isLoading = true;
  String _sortBy = 'deadline'; // 'deadline', 'course', 'urgency'

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments({bool force = false}) async {
    setState(() => _isLoading = true);
    try {
      final res = await ref.read(classroomRepositoryProvider).fetchAssignments(forceRefresh: force);
      setState(() => _assignments = res);
    } catch (e) {
      //
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSubmitted(ClassroomAssignment ass) async {
    final nextState = !ass.isSubmitted;
    
    // We update local state instantly for optimal UX
    setState(() {
      _assignments = _assignments.map((item) {
        if (item.id == ass.id) {
          return item.copyWith(isSubmitted: nextState);
        }
        return item;
      }).toList();
    });

    try {
      await ref.read(classroomRepositoryProvider).submitAssignment(ass.courseId, ass.id, 'mock_sub_id');
    } catch (e) {
      //
    }
  }

  void _sortAssignments() {
    if (_sortBy == 'deadline') {
      _assignments.sort((a, b) {
        if (a.dueTime == null) return 1;
        if (b.dueTime == null) return -1;
        return a.dueTime!.compareTo(b.dueTime!);
      });
    } else if (_sortBy == 'course') {
      _assignments.sort((a, b) => a.courseName.compareTo(b.courseName));
    } else if (_sortBy == 'urgency') {
      _assignments.sort((a, b) {
        final now = DateTime.now();
        final aHours = a.dueTime?.difference(now).inHours ?? 9999;
        final bHours = b.dueTime?.difference(now).inHours ?? 9999;
        return aHours.compareTo(bHours);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _sortAssignments();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter / Control Bar
            Row(
              children: [
                const Text(
                  'Sort by:',
                  style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  dropdownColor: OneDarkTheme.cardBg,
                  underline: const SizedBox(),
                  style: const TextStyle(color: OneDarkTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  items: const [
                    DropdownMenuItem(value: 'deadline', child: Text('Due Date')),
                    DropdownMenuItem(value: 'course', child: Text('Course Name')),
                    DropdownMenuItem(value: 'urgency', child: Text('Urgency')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _sortBy = val);
                    }
                  },
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => _loadAssignments(force: true),
                  icon: const Icon(Icons.sync, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: OneDarkTheme.border,
                    foregroundColor: OneDarkTheme.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: OneDarkTheme.primary))
                  : _assignments.isEmpty
                      ? const Center(child: Text('No deadlines found.', style: TextStyle(color: OneDarkTheme.textDark)))
                      : ListView.builder(
                          itemCount: _assignments.length,
                          itemBuilder: (context, index) {
                            final ass = _assignments[index];
                            return _AssignmentCard(
                              assignment: ass,
                              onToggle: () => _toggleSubmitted(ass),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final ClassroomAssignment assignment;
  final VoidCallback onToggle;

  const _AssignmentCard({required this.assignment, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remainingHours = assignment.dueTime?.difference(now).inHours ?? 9999;
    final isUrgent = remainingHours <= 48 && !assignment.isSubmitted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OneDarkTheme.cardBg,
        border: Border.all(
          color: isUrgent ? OneDarkTheme.error.withOpacity(0.5) : OneDarkTheme.border,
          width: isUrgent ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: assignment.isSubmitted,
          activeColor: OneDarkTheme.success,
          onChanged: (_) => onToggle(),
        ),
        title: Row(
          children: [
            Text(
              '[${assignment.courseName}]',
              style: const TextStyle(
                color: OneDarkTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                assignment.title,
                style: TextStyle(
                  color: assignment.isSubmitted ? OneDarkTheme.textDark : OneDarkTheme.textLight,
                  decoration: assignment.isSubmitted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (assignment.description != null && assignment.description!.isNotEmpty) ...[
                Text(
                  assignment.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 12),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: OneDarkTheme.textDark),
                  const SizedBox(width: 4),
                  Text(
                    assignment.dueTime != null
                        ? 'Due: ${assignment.dueTime!.toLocal().toString().split('.')[0]}'
                        : 'No due date',
                    style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
                  ),
                  const SizedBox(width: 12),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: OneDarkTheme.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Urgent (<48h)',
                        style: TextStyle(color: OneDarkTheme.error, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, size: 16, color: OneDarkTheme.textMain),
          onPressed: () {
            // Launches remote assignment link
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final cacheRepo = ref.read(cacheRepositoryProvider);
    final cached = await cacheRepo.getClassroomAssignments();
    if (cached.isNotEmpty) {
      setState(() {
        _assignments = cached;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final remote = await ref.read(classroomRepositoryProvider).fetchAssignments(forceRefresh: force);
      setState(() {
        _assignments = remote;
      });
      await cacheRepo.saveClassroomAssignments(remote);
    } catch (e) {
      // Keep displaying cached data on failure
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nextState
              ? '"${ass.title}" ditandai sebagai selesai.'
              : '"${ass.title}" ditandai sebagai aktif kembali.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      if (nextState) {
        await ref.read(classroomRepositoryProvider).submitAssignment(ass.courseId, ass.id, 'mock_sub_id');
      } else {
        await ref.read(classroomRepositoryProvider).unsubmitAssignment(ass.courseId, ass.id);
      }
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

    final activeAssignments = _assignments.where((ass) => !ass.isSubmitted).toList();
    final completedAssignments = _assignments.where((ass) => ass.isSubmitted).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TabBar header
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: OneDarkTheme.border, width: 1),
                  ),
                ),
                child: TabBar(
                  labelColor: OneDarkTheme.primary,
                  unselectedLabelColor: OneDarkTheme.textMain,
                  indicatorColor: OneDarkTheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text('Tugas Aktif (${activeAssignments.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_turned_in_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text('Tugas Selesai (${completedAssignments.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
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
              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Tugas Aktif
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: OneDarkTheme.primary))
                        : activeAssignments.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada tugas aktif.',
                                  style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                itemCount: activeAssignments.length,
                                itemBuilder: (context, index) {
                                  final ass = activeAssignments[index];
                                  return _AssignmentCard(
                                    assignment: ass,
                                    onToggle: () => _toggleSubmitted(ass),
                                  );
                                },
                              ),
                    // Tab 2: Tugas Selesai
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: OneDarkTheme.primary))
                        : completedAssignments.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada tugas yang ditandai selesai.',
                                  style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                itemCount: completedAssignments.length,
                                itemBuilder: (context, index) {
                                  final ass = completedAssignments[index];
                                  return _AssignmentCard(
                                    assignment: ass,
                                    onToggle: () => _toggleSubmitted(ass),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ],
          ),
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
        title: Row(
          children: [
            Text(
              '[${assignment.courseName}]',
              style: TextStyle(
                color: assignment.isSubmitted ? OneDarkTheme.primary.withOpacity(0.5) : OneDarkTheme.primary,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  decoration: assignment.isSubmitted ? TextDecoration.lineThrough : null,
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
                  style: TextStyle(
                    color: assignment.isSubmitted ? OneDarkTheme.textDark : OneDarkTheme.textMain, 
                    fontSize: 12
                  ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onToggle,
              child: Text(
                assignment.isSubmitted ? 'Batalkan' : 'Selesai',
                style: TextStyle(
                  color: assignment.isSubmitted ? OneDarkTheme.error : OneDarkTheme.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(assignment.alternateLink);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                'Buka',
                style: TextStyle(
                  color: OneDarkTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

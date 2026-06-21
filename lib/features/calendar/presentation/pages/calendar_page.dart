import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/features/calendar/domain/entities/calendar_event.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  final TextEditingController _promptController = TextEditingController();
  List<CalendarEvent> _events = [];
  List<CalendarEvent> _draftEvents = [];
  bool _isLoadingEvents = true;
  bool _isGeneratingDraft = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final cacheRepo = ref.read(cacheRepositoryProvider);
    final cached = await cacheRepo.getCalendarEvents();
    if (cached.isNotEmpty) {
      setState(() {
        _events = cached;
        _isLoadingEvents = false;
      });
    } else {
      setState(() {
        _isLoadingEvents = true;
      });
    }

    try {
      final remote = await ref.read(calendarRepositoryProvider).fetchEvents();
      setState(() {
        _events = remote;
      });
      await cacheRepo.saveCalendarEvents(remote);
    } catch (e) {
      // Keep displaying cached data on remote failure
    } finally {
      setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _generateDraft() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;
    
    setState(() => _isGeneratingDraft = true);
    try {
      final generated = await ref.read(calendarRepositoryProvider).generateScheduleFromPrompt(text);
      setState(() => _draftEvents = generated);
    } catch (e) {
      //
    } finally {
      setState(() => _isGeneratingDraft = false);
    }
  }

  Future<void> _confirmAndSync() async {
    final repo = ref.read(calendarRepositoryProvider);
    for (final event in _draftEvents) {
      await repo.createEvent(event);
    }
    setState(() {
      _draftEvents = [];
      _promptController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Events successfully synced to Google Calendar!')),
    );
    _loadEvents();
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return null;

    if (!context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _showEditEventDialog({
    required BuildContext context,
    required CalendarEvent event,
    required Function(CalendarEvent) onSave,
  }) async {
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description);
    DateTime start = event.startTime;
    DateTime end = event.endTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: OneDarkTheme.surface,
              title: const Text('Edit Event', style: TextStyle(color: OneDarkTheme.textLight)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Title', style: TextStyle(color: OneDarkTheme.textDark, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Event Title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description', style: TextStyle(color: OneDarkTheme.textDark, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Event Description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Start Time', style: TextStyle(color: OneDarkTheme.textDark, fontSize: 12)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await _pickDateTime(context, start);
                        if (picked != null) {
                          setState(() => start = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: OneDarkTheme.cardBg,
                          border: Border.all(color: OneDarkTheme.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: OneDarkTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              start.toLocal().toString().split('.')[0],
                              style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('End Time', style: TextStyle(color: OneDarkTheme.textDark, fontSize: 12)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await _pickDateTime(context, end);
                        if (picked != null) {
                          setState(() => end = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: OneDarkTheme.cardBg,
                          border: Border.all(color: OneDarkTheme.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: OneDarkTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              end.toLocal().toString().split('.')[0],
                              style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: OneDarkTheme.textDark)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: OneDarkTheme.primary),
                  onPressed: () {
                    final edited = event.copyWith(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      startTime: start,
                      endTime: end,
                    );
                    onSave(edited);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Existing Calendar Schedule
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Planner', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoadingEvents
                        ? const Center(child: CircularProgressIndicator(color: OneDarkTheme.primary))
                        : _events.isEmpty
                            ? const Center(
                                child: Text(
                                  'No calendar events available.',
                                  style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _events.length,
                                itemBuilder: (context, index) {
                                  final event = _events[index];
                                  return _EventListItem(
                                    event: event,
                                    onEdit: () {
                                      _showEditEventDialog(
                                        context: context,
                                        event: event,
                                        onSave: (edited) async {
                                          try {
                                            await ref.read(calendarRepositoryProvider).updateEvent(edited);
                                            _loadEvents();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Event updated successfully!')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to update event: $e')),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                    onDelete: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: OneDarkTheme.surface,
                                          title: const Text('Delete Event', style: TextStyle(color: OneDarkTheme.textLight)),
                                          content: const Text(
                                            'Are you sure you want to delete this event from Google Calendar?',
                                            style: TextStyle(color: OneDarkTheme.textMain),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel', style: TextStyle(color: OneDarkTheme.textDark)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: OneDarkTheme.error),
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          await ref.read(calendarRepositoryProvider).deleteEvent(event.id);
                                          _loadEvents();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Event deleted successfully!')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to delete event: $e')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
          
          const VerticalDivider(),

          // Right: AI Schedule Generator Form & Preview
          Expanded(
            flex: 2,
            child: Container(
              color: OneDarkTheme.background,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: OneDarkTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI Schedule Creator',
                        style: TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Describe your study goals naturally, and DeadlineAI will draft optimization schedules for you.',
                    style: TextStyle(color: OneDarkTheme.textMain, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _promptController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: OneDarkTheme.textLight),
                    decoration: const InputDecoration(
                      hintText: 'e.g., Study machine learning for 2 hours every evening starting tomorrow.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OneDarkTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isGeneratingDraft ? null : _generateDraft,
                      icon: const Icon(Icons.bolt, size: 16),
                      label: Text(_isGeneratingDraft ? 'Generating slots...' : 'Generate Schedule'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Draft preview list
                  if (_draftEvents.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Schedule Preview (Drafts)',
                          style: TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() => _draftEvents = []);
                          },
                          child: const Text('Clear', style: TextStyle(color: OneDarkTheme.error, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _draftEvents.length,
                        itemBuilder: (context, index) {
                          final event = _draftEvents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: OneDarkTheme.cardBg,
                            child: ListTile(
                              dense: true,
                              title: Text(event.title, style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${event.startTime.toLocal().toString().split('.')[0]} (${event.endTime.difference(event.startTime).inHours} hrs)',
                                style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 11),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16, color: OneDarkTheme.primary),
                                    onPressed: () {
                                      _showEditEventDialog(
                                        context: context,
                                        event: event,
                                        onSave: (edited) {
                                          setState(() {
                                            _draftEvents[index] = edited;
                                          });
                                        },
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16, color: OneDarkTheme.error),
                                    onPressed: () {
                                      setState(() {
                                        _draftEvents.removeAt(index);
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OneDarkTheme.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _confirmAndSync,
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync to Google Calendar'),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _EventListItem({
    required this.event,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final startTimeStr = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OneDarkTheme.cardBg,
        border: Border.all(color: OneDarkTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time details box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: OneDarkTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  event.isAllDay ? 'ALL DAY' : startTimeStr,
                  style: const TextStyle(color: OneDarkTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                if (!event.isAllDay) ...[
                  const SizedBox(height: 4),
                  Text(
                    endTimeStr,
                    style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Event Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 12),
                ),
                if (event.meetLink != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: OneDarkTheme.cyan.withOpacity(0.15),
                        border: Border.all(color: OneDarkTheme.cyan.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.video_call, color: OneDarkTheme.cyan, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Join Google Meet',
                            style: TextStyle(color: OneDarkTheme.cyan.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: 16),
            Column(
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: OneDarkTheme.primary),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onEdit != null && onDelete != null) const SizedBox(height: 12),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: OneDarkTheme.error),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

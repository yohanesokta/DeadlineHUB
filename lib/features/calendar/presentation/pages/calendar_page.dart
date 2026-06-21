import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
  DateTime _focusedDate = DateTime.now();

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

  DateTime get _startOfWeek {
    final dayOffset = _focusedDate.weekday - 1;
    final monday = _focusedDate.subtract(Duration(days: dayOffset));
    return DateTime(monday.year, monday.month, monday.day);
  }

  List<DateTime> get _weekDates {
    final start = _startOfWeek;
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  String _getMonthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }

  void _showEventDetailsDialog(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        final startTimeStr = event.startTime.toLocal().toString().split('.')[0];
        final endTimeStr = event.endTime.toLocal().toString().split('.')[0];
        final meetLink = event.meetLink;

        return AlertDialog(
          backgroundColor: OneDarkTheme.surface,
          title: Text(event.title, style: const TextStyle(color: OneDarkTheme.textLight)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: OneDarkTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$startTimeStr - $endTimeStr',
                      style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (event.description.isNotEmpty) ...[
                const Text('Description:', style: TextStyle(color: OneDarkTheme.textDark, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(event.description, style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 13)),
                const SizedBox(height: 16),
              ],
              if (meetLink != null && meetLink.isNotEmpty) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OneDarkTheme.cyan,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(meetLink);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join Google Meet'),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: OneDarkTheme.primary),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditEventDialog(
                  context: context,
                  event: event,
                  onSave: (edited) async {
                    try {
                      await ref.read(calendarRepositoryProvider).updateEvent(edited);
                      _loadEvents();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event updated successfully!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update event: $e')),
                      );
                    }
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: OneDarkTheme.error),
              onPressed: () async {
                Navigator.of(context).pop();
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event deleted successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete event: $e')),
                    );
                  }
                }
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: OneDarkTheme.textDark)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    double startHour = event.startTime.hour + (event.startTime.minute / 60.0);
    double endHour = event.endTime.hour + (event.endTime.minute / 60.0);

    // Clamp values to active hours (07:00 to 23:00)
    if (startHour < 7.0) startHour = 7.0;
    if (endHour > 23.0) endHour = 23.0;
    if (endHour <= startHour) return const SizedBox.shrink();

    final topOffset = (startHour - 7.0) * 60.0;
    final heightOffset = (endHour - startHour) * 60.0;

    Color eventColor = OneDarkTheme.primary;
    if (event.meetLink != null && event.meetLink!.isNotEmpty) {
      eventColor = OneDarkTheme.cyan;
    } else if (event.title.toLowerCase().contains('classroom') ||
               event.title.toLowerCase().contains('deadline') ||
               event.title.toLowerCase().contains('tugas')) {
      eventColor = const Color(0xFFC678DD); // Purple/Magenta
    } else if (event.title.toLowerCase().contains('exam') ||
               event.title.toLowerCase().contains('quiz') ||
               event.title.toLowerCase().contains('uas') ||
               event.title.toLowerCase().contains('uts')) {
      eventColor = OneDarkTheme.error; // Red
    }

    return Positioned(
      top: topOffset + 2,
      height: heightOffset - 4,
      left: 4,
      right: 4,
      child: GestureDetector(
        onTap: () => _showEventDetailsDialog(event),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: eventColor.withOpacity(0.15),
            border: Border(
              left: BorderSide(color: eventColor, width: 3),
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: OneDarkTheme.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              if (heightOffset > 35) ...[
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: OneDarkTheme.textMain,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = _startOfWeek;
    final end = start.add(const Duration(days: 6));
    String dateRangeStr = '${_getMonthName(start.month)} ${start.year}';
    if (start.year != end.year) {
      dateRangeStr = '${_getMonthName(start.month)} ${start.year} - ${_getMonthName(end.month)} ${end.year}';
    } else if (start.month != end.month) {
      dateRangeStr = '${_getMonthName(start.month)} - ${_getMonthName(end.month)} ${start.year}';
    }

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Weekly Planner Canvas
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(dateRangeStr, style: theme.textTheme.titleMedium),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: OneDarkTheme.textLight),
                        onPressed: () {
                          setState(() {
                            _focusedDate = _focusedDate.subtract(const Duration(days: 7));
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _focusedDate = DateTime.now();
                          });
                        },
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            color: OneDarkTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: OneDarkTheme.textLight),
                        onPressed: () {
                          setState(() {
                            _focusedDate = _focusedDate.add(const Duration(days: 7));
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Canvas Day Headers
                  Row(
                    children: [
                      const SizedBox(width: 50), // Spacing for time labels
                      ...List.generate(7, (dayIndex) {
                        final dayDate = _weekDates[dayIndex];
                        final isToday = DateUtils.isSameDay(dayDate, DateTime.now());
                        final weekdayStr = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][dayIndex];
                        
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isToday ? OneDarkTheme.primary.withOpacity(0.05) : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: isToday ? OneDarkTheme.primary : OneDarkTheme.border,
                                  width: isToday ? 2 : 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  weekdayStr,
                                  style: TextStyle(
                                    color: isToday ? OneDarkTheme.primary : OneDarkTheme.textDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isToday ? OneDarkTheme.primary : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${dayDate.day}',
                                    style: TextStyle(
                                      color: isToday ? Colors.white : OneDarkTheme.textLight,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  
                  // Canvas Grid Area
                  Expanded(
                    child: _isLoadingEvents
                        ? const Center(child: CircularProgressIndicator(color: OneDarkTheme.primary))
                        : SingleChildScrollView(
                            child: Stack(
                              children: [
                                // Background Hour Rows Grid
                                Column(
                                  children: List.generate(16, (hourIndex) {
                                    final hour = 7 + hourIndex;
                                    return Container(
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: OneDarkTheme.border, width: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            alignment: Alignment.topRight,
                                            padding: const EdgeInsets.only(right: 8, top: 4),
                                            child: Text(
                                              '${hour.toString().padLeft(2, '0')}:00',
                                              style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 10),
                                            ),
                                          ),
                                          ...List.generate(7, (dayIndex) {
                                            return Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(color: OneDarkTheme.border, width: 0.5),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                
                                // Overlay Events Placement Grid
                                Positioned.fill(
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 50),
                                      ...List.generate(7, (dayIndex) {
                                        final dayDate = _weekDates[dayIndex];
                                        final dayEvents = _events.where((e) {
                                          return e.startTime.year == dayDate.year &&
                                                 e.startTime.month == dayDate.month &&
                                                 e.startTime.day == dayDate.day;
                                        }).toList();

                                        return Expanded(
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: dayEvents.map((event) {
                                                return _buildEventCard(event);
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

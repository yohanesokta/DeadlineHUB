import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/features/classroom/domain/entities/classroom_assignment.dart';
import 'package:deadlinehub/features/calendar/domain/entities/calendar_event.dart';
import 'package:deadlinehub/features/email/domain/entities/academic_email.dart';
import 'package:deadlinehub/features/drive/domain/entities/drive_file.dart';
import 'package:deadlinehub/features/ai/domain/repositories/ai_repository.dart';

class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage> {
  int _selectedDayOffset = 0; // 0 = Today, 1 = Tomorrow, etc.

  List<ClassroomAssignment> _assignments = [];
  List<CalendarEvent> _events = [];
  List<AcademicEmail> _emails = [];
  List<DriveFile> _files = [];

  bool _isFetchingBackground = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardDataFlow();
  }

  Future<void> _loadDashboardDataFlow() async {
    final cacheRepo = ref.read(cacheRepositoryProvider);
    final secureStorage = ref.read(secureStorageProvider);

    // 1. Load from cache first for instant response
    final cachedAssignments = await cacheRepo.getClassroomAssignments();
    final cachedEvents = await cacheRepo.getCalendarEvents();
    final cachedEmails = await cacheRepo.getEmails();
    final cachedFiles = await cacheRepo.getDriveFiles();

    if (mounted) {
      setState(() {
        _assignments = cachedAssignments;
        _events = cachedEvents;
        _emails = cachedEmails;
        _files = cachedFiles;
      });
    }

    // 2. Check if we need to fetch background (cache for 1 day)
    final lastFetch = await secureStorage.getLastFetchTime();
    final now = DateTime.now();

    final needsFetch = lastFetch == null ||
        now.difference(lastFetch).inHours >= 24 ||
        (cachedAssignments.isEmpty &&
            cachedEvents.isEmpty &&
            cachedEmails.isEmpty &&
            cachedFiles.isEmpty);

    if (needsFetch) {
      _fetchDataInBackground();
    }
  }

  Future<void> _fetchDataInBackground() async {
    if (_isFetchingBackground) return;

    setState(() {
      _isFetchingBackground = true;
    });

    final classroomRepo = ref.read(classroomRepositoryProvider);
    final calendarRepo = ref.read(calendarRepositoryProvider);
    final emailRepo = ref.read(emailRepositoryProvider);
    final driveRepo = ref.read(driveRepositoryProvider);
    final cacheRepo = ref.read(cacheRepositoryProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final aiRepo = ref.read(aiRepositoryProvider);

    // Log refresh activity to show up in bottom timeline logger
    aiRepo.logActivity('insights_refresh', 'Memuat data dashboard terbaru...', TaskState.running);

    try {
      final results = await Future.wait([
        classroomRepo.fetchAssignments(forceRefresh: true).catchError((_) => <ClassroomAssignment>[]),
        calendarRepo.fetchEvents().catchError((_) => <CalendarEvent>[]),
        emailRepo.fetchRecentEmails(forceRefresh: true).catchError((_) => <AcademicEmail>[]),
        driveRepo.fetchRecentFiles().catchError((_) => <DriveFile>[]),
      ]);

      final assignments = results[0] as List<ClassroomAssignment>;
      final events = results[1] as List<CalendarEvent>;
      final emails = results[2] as List<AcademicEmail>;
      final files = results[3] as List<DriveFile>;

      // Save to cache
      await cacheRepo.saveClassroomAssignments(assignments);
      await cacheRepo.saveCalendarEvents(events);
      await cacheRepo.saveEmails(emails);
      await cacheRepo.saveDriveFiles(files);

      // Save last fetch timestamp
      await secureStorage.saveLastFetchTime(DateTime.now());

      if (mounted) {
        setState(() {
          _assignments = assignments;
          _events = events;
          _emails = emails;
          _files = files;
        });
      }

      aiRepo.logActivity('insights_refresh', 'Memuat data dashboard terbaru...', TaskState.completed);
    } catch (e) {
      aiRepo.logActivity('insights_refresh', 'Memuat data dashboard terbaru...', TaskState.failed, error: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingBackground = false;
        });
      }
    }
  }

  DateTime _getDateForOffset(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: offset));
  }

  bool _isSameDay(DateTime? date, int offset) {
    if (date == null) return false;
    final localDate = date.toLocal();
    final targetDate = _getDateForOffset(offset);
    return localDate.year == targetDate.year &&
        localDate.month == targetDate.month &&
        localDate.day == targetDate.day;
  }

  List<String> _generateSuggestions(
    List<DriveFile> files,
    List<ClassroomAssignment> assignments,
  ) {
    final List<String> suggestions = [];
    final placeholderFile = DriveFile(
      id: '',
      name: '',
      mimeType: '',
      webViewLink: '',
      modifiedTime: DateTime(1970),
    );

    // 1. Spreadsheet Suggestion
    final spreadsheet = files.firstWhere(
      (f) {
        final mime = f.mimeType.toLowerCase();
        final name = f.name.toLowerCase();
        return mime.contains('spreadsheet') ||
            mime.contains('sheet') ||
            mime.contains('excel') ||
            name.endsWith('.xlsx') ||
            name.endsWith('.csv');
      },
      orElse: () => placeholderFile,
    );
    if (spreadsheet.id.isNotEmpty) {
      suggestions.add("Mana spreadsheet ${spreadsheet.name} saya?");
    }

    // 2. Meeting / Rapat Suggestion
    final meeting = files.firstWhere(
      (f) {
        final name = f.name.toLowerCase();
        return name.contains('rapat') ||
            name.contains('meeting') ||
            name.contains('notes') ||
            name.contains('minutes');
      },
      orElse: () => placeholderFile,
    );
    if (meeting.id.isNotEmpty) {
      suggestions.add("Buka file rapat ${meeting.name} terakhir");
    }

    // 3. Presentation / Slide Suggestion
    final slide = files.firstWhere(
      (f) {
        final mime = f.mimeType.toLowerCase();
        final name = f.name.toLowerCase();
        return mime.contains('presentation') ||
            mime.contains('slide') ||
            name.endsWith('.pptx');
      },
      orElse: () => placeholderFile,
    );
    if (slide.id.isNotEmpty) {
      suggestions.add("Tampilkan slide ${slide.name}");
    }

    // 4. Active Assignment Suggestion
    final pending = _assignments.where((a) => !a.isSubmitted).toList();
    if (pending.isNotEmpty) {
      suggestions.add("Tanya AI tips menyelesaikan tugas ${pending.first.title}");
    }

    // Static relevant fallback questions to guarantee 4 options
    final fallbacks = [
      "Apa deadline tugas terdekat saya?",
      "Bantu buat jadwal belajar minggu ini",
      "Adakah email akademis penting hari ini?",
      "Cari file paling baru di Google Drive saya",
      "Bagaimana statistik akademik saya bulan ini?",
      "Buatkan ringkasan email kuliah kemarin",
    ];

    final dateHash = DateTime.now().day + DateTime.now().month * 31;
    final rotatedFallbacks = List<String>.from(fallbacks);
    // Rotate fallbacks based on day of the month to keep them fresh daily
    for (int i = 0; i < (dateHash % fallbacks.length); i++) {
      final first = rotatedFallbacks.removeAt(0);
      rotatedFallbacks.add(first);
    }

    for (final fallback in rotatedFallbacks) {
      if (suggestions.length >= 4) break;
      if (!suggestions.contains(fallback)) {
        suggestions.add(fallback);
      }
    }

    return suggestions.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);

    final pendingAssignments = _assignments.where((a) => !a.isSubmitted).toList();
    final now = DateTime.now();

    // Assignments due within next 72 hours (Classroom Deadlines Reminder)
    final urgentDeadlines = pendingAssignments.where((a) {
      if (a.dueTime == null) return false;
      final diff = a.dueTime!.difference(now);
      return diff.inHours > 0 && diff.inHours <= 72;
    }).toList();

    // Weekly planner filtering for the selected day offset
    final selectedDate = _getDateForOffset(_selectedDayOffset);
    final selectedEvents = _events.where((e) => _isSameDay(e.startTime, _selectedDayOffset)).toList();
    final selectedAssignments = pendingAssignments.where((a) => _isSameDay(a.dueTime, _selectedDayOffset)).toList();
    final selectedEmails = _emails.where((e) => _isSameDay(e.receivedAt, _selectedDayOffset) && (e.isPriority || e.isAcademic)).toList();

    final hasSelectedItems = selectedEvents.isNotEmpty ||
        selectedAssignments.isNotEmpty ||
        selectedEmails.isNotEmpty;

    // Generate dynamic search suggestions
    final dynamicSuggestions = _generateSuggestions(_files, _assignments);

    return Scaffold(
      backgroundColor: OneDarkTheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  children: [
                    // Greeting Section
                    profileAsync.when(
                      data: (profile) => Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: OneDarkTheme.primary.withOpacity(0.1),
                            backgroundImage: profile?.picture.isNotEmpty == true
                                ? NetworkImage(profile!.picture)
                                : null,
                            child: profile?.picture.isNotEmpty != true
                                ? const Icon(Icons.person, color: OneDarkTheme.primary)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat pagi, ${profile?.name.isNotEmpty == true ? profile!.name : "Student"}!',
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                                      style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                                    ),
                                    if (_isFetchingBackground) ...[
                                      const SizedBox(width: 12),
                                      const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: OneDarkTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Memuat data terbaru...',
                                        style: TextStyle(
                                          color: OneDarkTheme.textMain.withOpacity(0.7),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: OneDarkTheme.textMain),
                            onPressed: _fetchDataInBackground,
                          ),
                        ],
                      ),
                      loading: () => Row(
                        children: [
                          const Icon(Icons.person_outline, color: OneDarkTheme.textMain),
                          const SizedBox(width: 12),
                          Text(
                            'Selamat pagi, Student!',
                            style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                      error: (err, stack) => Row(
                        children: [
                          const Icon(Icons.person_outline, color: OneDarkTheme.textMain),
                          const SizedBox(width: 12),
                          Text(
                            'Selamat pagi, Student!',
                            style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Reminder Classroom Deadline (Only show if exists!)
                    if (urgentDeadlines.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              OneDarkTheme.error.withOpacity(0.15),
                              OneDarkTheme.warning.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: OneDarkTheme.error.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.alarm, color: OneDarkTheme.error, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reminder Deadline Classroom (${urgentDeadlines.length})',
                                    style: const TextStyle(
                                      color: OneDarkTheme.textLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...urgentDeadlines.map((ass) {
                                final dueStr = ass.dueTime != null
                                    ? DateFormat('HH:mm (d MMM)').format(ass.dueTime!.toLocal())
                                    : '';
                                final remainingHours = ass.dueTime!.difference(now).inHours;
                                final hoursStr = remainingHours <= 0
                                    ? 'Tenggat telah lewat'
                                    : 'Tersisa $remainingHours jam';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.warning_amber_rounded,
                                          size: 14, color: OneDarkTheme.warning),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${ass.courseName} - ${ass.title}',
                                          style: const TextStyle(
                                            color: OneDarkTheme.textLight,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$dueStr • $hoursStr',
                                        style: const TextStyle(
                                          color: OneDarkTheme.error,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Weekly Planner Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Weekly Planner & Focus', style: theme.textTheme.titleMedium),
                        const Text(
                          'Pilih hari untuk melihat fokus detail',
                          style: TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Weekly Horizontal Slider
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final date = _getDateForOffset(index);
                          final isSelected = _selectedDayOffset == index;

                          // Check if day has any schedules/assignments/emails
                          final hasDayEvents = _events.any((e) => _isSameDay(e.startTime, index));
                          final hasDayAssignments = pendingAssignments.any((a) => _isSameDay(a.dueTime, index));
                          final hasDayEmails = _emails.any((e) => _isSameDay(e.receivedAt, index) && (e.isPriority || e.isAcademic));

                          final dayName = index == 0 ? 'Hari ini' : DateFormat('EEE', 'id_ID').format(date);
                          final dayNum = DateFormat('d').format(date);

                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 75,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDayOffset = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? OneDarkTheme.primary.withOpacity(0.15)
                                      : OneDarkTheme.cardBg,
                                  border: Border.all(
                                    color: isSelected ? OneDarkTheme.primary : OneDarkTheme.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dayName,
                                      style: TextStyle(
                                        color: isSelected ? OneDarkTheme.primary : OneDarkTheme.textMain,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dayNum,
                                      style: TextStyle(
                                        color: isSelected ? OneDarkTheme.primary : OneDarkTheme.textLight,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Indicator dots for activities
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (hasDayEvents)
                                          Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                            decoration: const BoxDecoration(
                                              color: OneDarkTheme.cyan,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        if (hasDayAssignments)
                                          Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                            decoration: const BoxDecoration(
                                              color: OneDarkTheme.error,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        if (hasDayEmails)
                                          Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                            decoration: const BoxDecoration(
                                              color: OneDarkTheme.purple,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Planner Focus Detail Panel
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: OneDarkTheme.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Fokus Hari: ${DateFormat('EEEE, d MMM', 'id_ID').format(selectedDate)}',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // If absolutely no items, show clean complete state without dummy text
                            if (!hasSelectedItems)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: OneDarkTheme.success.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_outline,
                                          color: OneDarkTheme.success,
                                          size: 36,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Hari ini santai!',
                                        style: TextStyle(
                                          color: OneDarkTheme.textLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Tidak ada jadwal kuliah, tugas, atau email penting.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: OneDarkTheme.textDark,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              // Classroom Assignments Section
                              if (selectedAssignments.isNotEmpty) ...[
                                _buildDetailSubSectionHeader('Tenggat Tugas Classroom', OneDarkTheme.error),
                                ...selectedAssignments.map((ass) => _buildAssignmentItem(ass)),
                                const SizedBox(height: 16),
                              ],

                              // Calendar Events Section
                              if (selectedEvents.isNotEmpty) ...[
                                _buildDetailSubSectionHeader('Jadwal Acara & Kuliah', OneDarkTheme.cyan),
                                ...selectedEvents.map((e) => _buildCalendarItem(e)),
                                const SizedBox(height: 16),
                              ],

                              // Priority Academic Emails Section
                              if (selectedEmails.isNotEmpty) ...[
                                _buildDetailSubSectionHeader('Email Masuk Penting (Gmail)', OneDarkTheme.purple),
                                ...selectedEmails.map((e) => _buildEmailItem(e)),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // absolute-docked Floating AI Suggestions
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: OneDarkTheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OneDarkTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: OneDarkTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: dynamicSuggestions.map((suggestion) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              onPressed: () {
                                // Navigate to AI Chat with the query param
                                final encodedQuery = Uri.encodeComponent(suggestion);
                                context.go('/chat?query=$encodedQuery');
                              },
                              backgroundColor: OneDarkTheme.cardBg,
                              side: const BorderSide(color: OneDarkTheme.border),
                              label: Text(
                                suggestion,
                                style: const TextStyle(
                                  color: OneDarkTheme.textLight,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            ),
                          );
                        }).toList(),
                      ),
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

  Widget _buildDetailSubSectionHeader(String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: OneDarkTheme.textLight,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(ClassroomAssignment ass) {
    final dueTimeStr = ass.dueTime != null
        ? DateFormat('HH:mm').format(ass.dueTime!.toLocal())
        : 'Tidak ada jam';
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.edit_calendar, size: 14, color: OneDarkTheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ass.title,
                  style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${ass.courseName} • Jam $dueTimeStr',
                  style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarItem(CalendarEvent event) {
    final startStr = DateFormat('HH:mm').format(event.startTime.toLocal());
    final endStr = DateFormat('HH:mm').format(event.endTime.toLocal());
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: OneDarkTheme.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '$startStr - $endStr ${event.meetLink != null ? '• Meet link' : ''}',
                  style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailItem(AcademicEmail email) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mail_outline, size: 14, color: OneDarkTheme.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.subject,
                  style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Dari: ${email.sender.split('<')[0]} • ${email.snippet}',
                  style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

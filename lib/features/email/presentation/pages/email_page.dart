import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/features/email/domain/entities/academic_email.dart';

class EmailPage extends ConsumerStatefulWidget {
  const EmailPage({super.key});

  @override
  ConsumerState<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<EmailPage> {
  List<AcademicEmail> _emails = [];
  bool _isLoading = true;
  bool _academicOnly = true;

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails({bool force = false}) async {
    final cacheRepo = ref.read(cacheRepositoryProvider);
    final cached = await cacheRepo.getEmails();
    if (cached.isNotEmpty) {
      setState(() {
        _emails = cached;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final remote = await ref.read(emailRepositoryProvider).fetchRecentEmails(forceRefresh: force);
      setState(() {
        _emails = remote;
      });
      await cacheRepo.saveEmails(remote);
    } catch (e) {
      // Keep displaying cached data on failure
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showSummary(AcademicEmail email) async {
    // If summary is already cached locally, show it directly
    if (email.bodySummary != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: OneDarkTheme.cardBg,
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: OneDarkTheme.primary, size: 20),
                SizedBox(width: 8),
                Text('AI Email Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OneDarkTheme.textLight)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject: ${email.subject}', style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  email.bodySummary!,
                  style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 13, height: 1.45),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss', style: TextStyle(color: OneDarkTheme.textMain)),
              ),
            ],
          );
        },
      );
      return;
    }

    // If summary is null, show a FutureBuilder dialog to fetch it dynamically
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: OneDarkTheme.cardBg,
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: OneDarkTheme.primary, size: 20),
              SizedBox(width: 8),
              Text('AI Email Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OneDarkTheme.textLight)),
            ],
          ),
          content: FutureBuilder<String>(
            future: ref.read(emailRepositoryProvider).summarizeEmail(email.snippet),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject: ${email.subject}', style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 24),
                    const Center(
                      child: CircularProgressIndicator(color: OneDarkTheme.primary),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }

              if (snapshot.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject: ${email.subject}', style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Error generating summary: ${snapshot.error}',
                      style: const TextStyle(color: OneDarkTheme.error, fontSize: 13),
                    ),
                  ],
                );
              }

              final summary = snapshot.data ?? 'No summary generated.';

              // Update the email in parent page state after the current frame builds
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _emails = _emails.map((e) {
                      if (e.id == email.id) {
                        return e.copyWith(bodySummary: summary);
                      }
                      return e;
                    }).toList();
                  });
                }
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject: ${email.subject}', style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    summary,
                    style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 13, height: 1.45),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss', style: TextStyle(color: OneDarkTheme.textMain)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedEmails = _academicOnly ? _emails.where((e) => e.isAcademic).toList() : _emails;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter controls
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Academic & Courses', style: TextStyle(fontSize: 12)),
                  selected: _academicOnly,
                  selectedColor: OneDarkTheme.primary.withOpacity(0.2),
                  checkmarkColor: OneDarkTheme.primary,
                  onSelected: (val) {
                    setState(() => _academicOnly = true);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All Emails', style: TextStyle(fontSize: 12)),
                  selected: !_academicOnly,
                  selectedColor: OneDarkTheme.primary.withOpacity(0.2),
                  checkmarkColor: OneDarkTheme.primary,
                  onSelected: (val) {
                    setState(() => _academicOnly = false);
                  },
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => _loadEmails(force: true),
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
                  : displayedEmails.isEmpty
                      ? const Center(
                          child: Text(
                            'No emails available.',
                            style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedEmails.length,
                          itemBuilder: (context, index) {
                            final email = displayedEmails[index];
                            return _EmailListItem(
                              email: email,
                              onSummarize: () => _showSummary(email),
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

class _EmailListItem extends StatelessWidget {
  final AcademicEmail email;
  final VoidCallback onSummarize;

  const _EmailListItem({required this.email, required this.onSummarize});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OneDarkTheme.cardBg,
        border: Border.all(
          color: email.isPriority ? OneDarkTheme.warning.withOpacity(0.5) : OneDarkTheme.border,
          width: email.isPriority ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          email.isAcademic ? Icons.school : Icons.mail,
          color: email.isAcademic ? OneDarkTheme.primary : OneDarkTheme.textDark,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                email.sender,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: OneDarkTheme.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${email.receivedAt.hour.toString().padLeft(2, '0')}:${email.receivedAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 10),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email.subject,
                style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.w500, fontSize: 12.5),
              ),
              const SizedBox(height: 4),
              Text(
                email.snippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 12, height: 1.3),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: OneDarkTheme.border,
                foregroundColor: OneDarkTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: onSummarize,
              icon: const Icon(Icons.auto_awesome, size: 12),
              label: const Text('Summarize', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

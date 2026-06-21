import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/features/drive/domain/entities/drive_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DrivePage extends ConsumerStatefulWidget {
  const DrivePage({super.key});

  @override
  ConsumerState<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends ConsumerState<DrivePage> {
  final TextEditingController _searchController = TextEditingController();
  List<DriveFile> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    final cacheRepo = ref.read(cacheRepositoryProvider);
    final cached = await cacheRepo.getDriveFiles();
    if (cached.isNotEmpty) {
      setState(() {
        _files = cached;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final remote = await ref.read(driveRepositoryProvider).fetchRecentFiles();
      setState(() {
        _files = remote;
      });
      await cacheRepo.saveDriveFiles(remote);
    } catch (e) {
      // Keep displaying cached data on failure
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    setState(() => _isLoading = true);
    try {
      final res = await ref.read(driveRepositoryProvider).searchFiles(query);
      setState(() => _files = res);
    } catch (e) {
      //
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openFile(DriveFile file) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${file.name} in default browser...')),
    );
    final uri = Uri.parse(file.webViewLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drive Quick Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14, color: OneDarkTheme.textLight),
                    decoration: const InputDecoration(
                      hintText: 'Search files on Google Drive (e.g. machine learning, spreadsheet)...',
                      prefixIcon: Icon(Icons.search, color: OneDarkTheme.textMain),
                    ),
                    onChanged: (val) {
                      _search(val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _fetchFiles();
                  },
                  icon: const Icon(Icons.refresh, color: OneDarkTheme.textMain),
                )
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              _searchController.text.isEmpty ? 'Frequently & Recently Modified' : 'Search Results',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: OneDarkTheme.primary))
                  : _files.isEmpty
                      ? const Center(
                          child: Text(
                            'No drive files available.',
                            style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: _files.length,
                          itemBuilder: (context, index) {
                            final file = _files[index];
                            return _FileGridItem(
                              file: file,
                              onTap: () => _openFile(file),
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

class _FileGridItem extends StatelessWidget {
  final DriveFile file;
  final VoidCallback onTap;

  const _FileGridItem({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String getIconPath() {
      final mime = file.mimeType.toLowerCase();
      if (mime == 'application/vnd.google-apps.folder') {
        return 'assets/icons/file_folder.svg';
      }
      if (mime == 'application/pdf') {
        return 'assets/icons/file_pdf.svg';
      }
      if (mime.contains('document') || mime.contains('word')) {
        return 'assets/icons/file_doc.svg';
      }
      if (mime.contains('spreadsheet') || mime.contains('sheet') || mime.contains('excel')) {
        return 'assets/icons/file_sheet.svg';
      }
      if (mime.contains('presentation') || mime.contains('slide') || mime.contains('powerpoint')) {
        return 'assets/icons/file_slide.svg';
      }
      if (mime.contains('zip') ||
          mime.contains('compressed') ||
          mime.contains('archive') ||
          mime.contains('tar') ||
          file.name.endsWith('.zip') ||
          file.name.endsWith('.rar') ||
          file.name.endsWith('.tar') ||
          file.name.endsWith('.7z') ||
          file.name.endsWith('.gz')) {
        return 'assets/icons/file_archive.svg';
      }
      if (mime.contains('x-msdownload') ||
          mime.contains('x-sh') ||
          mime.contains('x-executable') ||
          file.name.endsWith('.exe') ||
          file.name.endsWith('.sh') ||
          file.name.endsWith('.bat') ||
          file.name.endsWith('.bin')) {
        return 'assets/icons/file_executable.svg';
      }
      if (mime.startsWith('image/')) {
        return 'assets/icons/file_image.svg';
      }
      if (mime.startsWith('audio/')) {
        return 'assets/icons/file_audio.svg';
      }
      if (mime.startsWith('video/')) {
        return 'assets/icons/file_video.svg';
      }
      if (mime.contains('code') ||
          mime.contains('javascript') ||
          mime.contains('json') ||
          file.name.endsWith('.py') ||
          file.name.endsWith('.dart') ||
          file.name.endsWith('.ipynb')) {
        return 'assets/icons/file_code.svg';
      }
      if (mime.startsWith('text/')) {
        return 'assets/icons/file_text.svg';
      }
      return 'assets/icons/file_generic.svg';
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                getIconPath(),
                width: 28,
                height: 28,
              ),
              const Spacer(),
              Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: OneDarkTheme.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Modified: ${file.modifiedTime.day}/${file.modifiedTime.month}/${file.modifiedTime.year}',
                style: const TextStyle(color: OneDarkTheme.textDark, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

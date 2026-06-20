import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/features/drive/domain/entities/drive_file.dart';
import 'package:url_launcher/url_launcher.dart';

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
    setState(() => _isLoading = true);
    try {
      final res = await ref.read(driveRepositoryProvider).fetchRecentFiles();
      setState(() => _files = res);
    } catch (e) {
      //
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
    IconData getIcon() {
      final name = file.name.toLowerCase();
      if (name.contains('.pdf')) return Icons.picture_as_pdf;
      if (name.contains('.docx') || name.contains('.txt')) return Icons.description;
      if (name.contains('.xlsx') || name.contains('.csv')) return Icons.table_chart;
      if (name.contains('.ipynb')) return Icons.code;
      return Icons.insert_drive_file;
    }

    Color getIconColor() {
      final name = file.name.toLowerCase();
      if (name.contains('.pdf')) return OneDarkTheme.error;
      if (name.contains('.docx')) return OneDarkTheme.primary;
      if (name.contains('.xlsx')) return OneDarkTheme.success;
      if (name.contains('.ipynb')) return OneDarkTheme.purple;
      return OneDarkTheme.textMain;
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
              Icon(getIcon(), color: getIconColor(), size: 28),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureText = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final key = await ref.read(secureStorageProvider).getGeminiApiKey();
    if (key != null) {
      _apiKeyController.text = key;
    }
    final auth = await ref.read(authRepositoryProvider).isAuthenticated();
    setState(() {
      _isAuthenticated = auth;
    });
  }

  Future<void> _saveKey() async {
    final key = _apiKeyController.text.trim();
    await ref.read(secureStorageProvider).saveGeminiApiKey(key);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API Key saved securely!')),
      );
    }
  }

  Future<void> _toggleAuth() async {
    final repo = ref.read(authRepositoryProvider);
    if (_isAuthenticated) {
      await repo.signOut();
    } else {
      await repo.signIn();
    }
    final status = await repo.isAuthenticated();
    setState(() {
      _isAuthenticated = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Application Settings', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Configure your Google API authentication and primary Gemini credentials below.',
              style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // Google Account Connection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: OneDarkTheme.primary.withOpacity(0.1),
                      radius: 20,
                      child: const Icon(Icons.account_circle, color: OneDarkTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Google Integration',
                            style: TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isAuthenticated 
                              ? 'Status: Connected (student@university.edu)' 
                              : 'Status: Disconnected',
                            style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAuthenticated ? OneDarkTheme.error : OneDarkTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: _toggleAuth,
                      child: Text(_isAuthenticated ? 'Sign Out' : 'Connect Account'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gemini API Key config
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vpn_key_outlined, color: OneDarkTheme.cyan, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Google Gemini API Key',
                          style: TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'DeadlineAI uses the Gemini model for smart scheduling and email extraction. '
                      'Enter your personal API Key (obtained from Google AI Studio). If left empty, a robust local agent simulation will be used.',
                      style: TextStyle(color: OneDarkTheme.textMain, fontSize: 12, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _obscureText,
                      style: const TextStyle(fontSize: 13, color: OneDarkTheme.textLight),
                      decoration: InputDecoration(
                        hintText: 'Enter AI Studio API Key (AIzaSy...)',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: OneDarkTheme.textMain,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OneDarkTheme.cyan,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _saveKey,
                        child: const Text('Save API Key'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            const Divider(),
            const SizedBox(height: 20),
            Text('Danger Zone', style: theme.textTheme.titleMedium?.copyWith(color: OneDarkTheme.error, fontSize: 15)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: OneDarkTheme.error,
                side: const BorderSide(color: OneDarkTheme.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                await ref.read(secureStorageProvider).clearAll();
                await ref.read(aiRepositoryProvider).clearHistory();
                setState(() {
                  _apiKeyController.clear();
                  _isAuthenticated = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All secure storage credentials cleared.')),
                  );
                }
              },
              icon: const Icon(Icons.delete_forever, size: 16),
              label: const Text('Reset Application Cache'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/presentation/pages/auth_gate.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureText = true;
  bool _isAuthenticated = false;
  
  List<String> _availableModels = [];
  String? _selectedModel;
  bool _loadingModels = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(secureStorageProvider);
    final key = await storage.getGeminiApiKey();
    final model = await storage.getGeminiModel();
    final auth = await ref.read(authRepositoryProvider).isAuthenticated();
    
    if (key != null) {
      _apiKeyController.text = key;
    }
    
    setState(() {
      _isAuthenticated = auth;
      _selectedModel = model;
    });

    if (key != null && key.isNotEmpty) {
      _fetchModels(key);
    }
  }

  Future<void> _fetchModels(String apiKey) async {
    setState(() => _loadingModels = true);
    try {
      final response = await http.get(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> modelsJson = data['models'] ?? [];
        final List<String> textModels = [];
        for (final m in modelsJson) {
          final name = m['name'] as String? ?? '';
          final methods = m['supportedGenerationMethods'] as List<dynamic>? ?? [];
          
          if (methods.contains('generateContent') && 
              (name.contains('gemini') || name.contains('gemma')) &&
              !name.contains('tts') && 
              !name.contains('image')) {
            textModels.add(name);
          }
        }
        setState(() {
          _availableModels = textModels;
          if (_selectedModel == null && textModels.isNotEmpty) {
            _selectedModel = _findBestModel(textModels);
          }
        });
      }
    } catch (_) {}
    setState(() => _loadingModels = false);
  }

  String _findBestModel(List<String> models) {
    for (final name in ['models/gemini-2.0-flash', 'models/gemini-2.5-flash', 'models/gemini-1.5-flash']) {
      if (models.contains(name)) return name;
    }
    for (final name in ['gemini-2.0-flash', 'gemini-2.5-flash', 'gemini-1.5-flash']) {
      if (models.contains(name)) return name;
    }
    final flash = models.firstWhere((m) => m.toLowerCase().contains('flash'), orElse: () => '');
    if (flash.isNotEmpty) return flash;
    return models.first;
  }

  Future<void> _saveKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API Key cannot be empty.')),
      );
      return;
    }
    
    // Save and validate immediately
    await ref.read(secureStorageProvider).saveGeminiApiKey(key);
    await ref.read(authGateProvider.notifier).checkValidity();
    
    final state = ref.read(authGateProvider);
    if (state.isGeminiKeyValid) {
      await _fetchModels(key);
      if (_selectedModel != null) {
        await ref.read(secureStorageProvider).saveGeminiModel(_selectedModel!);
        await ref.read(authGateProvider.notifier).selectModel(_selectedModel!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemini API Key saved and validated successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Gemini API Key. Key verification failed.')),
        );
      }
    }
  }

  Future<void> _toggleAuth() async {
    final repo = ref.read(authRepositoryProvider);
    if (_isAuthenticated) {
      await repo.signOut();
    }
    ref.read(authGateProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);

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
                child: profileAsync.when(
                  data: (profile) {
                    final isConnected = _isAuthenticated && profile != null;
                    final name = profile?.name ?? '';
                    final email = profile?.email ?? '';
                    final picture = profile?.picture ?? '';
                    final hasPicture = picture.isNotEmpty;

                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: OneDarkTheme.primary.withOpacity(0.1),
                          radius: 20,
                          backgroundImage: hasPicture && isConnected ? NetworkImage(picture) : null,
                          child: !hasPicture || !isConnected
                              ? const Icon(Icons.account_circle, color: OneDarkTheme.primary, size: 24)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isConnected ? name : 'Google Integration',
                                style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isConnected 
                                  ? 'Status: Connected ($email)' 
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
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: OneDarkTheme.primary),
                  ),
                  error: (e, s) => Row(
                    children: [
                      const Icon(Icons.error_outline, color: OneDarkTheme.error),
                      const SizedBox(width: 16),
                      Text('Error loading profile info: $e', style: const TextStyle(color: OneDarkTheme.error)),
                    ],
                  ),
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
                      'Enter your personal API Key (obtained from Google AI Studio). A valid API Key is required to run the application.',
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
                    
                    if (_loadingModels) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: OneDarkTheme.cyan),
                        ),
                      ),
                    ] else if (_availableModels.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedModel,
                        dropdownColor: OneDarkTheme.surface,
                        style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Active Text Model',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        items: _availableModels.map((model) {
                          final displayName = model.replaceFirst('models/', '');
                          return DropdownMenuItem<String>(
                            value: model,
                            child: Text(displayName),
                          );
                        }).toList(),
                        onChanged: (val) async {
                          if (val != null) {
                            setState(() => _selectedModel = val);
                            await ref.read(secureStorageProvider).saveGeminiModel(val);
                            await ref.read(authGateProvider.notifier).selectModel(val);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Active model switched to ${val.replaceFirst('models/', '')}')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                    
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
                  _availableModels.clear();
                  _selectedModel = null;
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

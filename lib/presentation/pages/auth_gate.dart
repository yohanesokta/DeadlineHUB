import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:deadlinehub/core/theme/theme.dart';
import 'package:deadlinehub/core/providers/providers.dart';

class AuthGateState {
  final bool checking;
  final bool isGoogleAuthenticated;
  final bool isGeminiKeyValid;
  final bool isStarted;
  final String? errorMessage;
  final List<String> availableModels;
  final String? selectedModel;

  const AuthGateState({
    required this.checking,
    required this.isGoogleAuthenticated,
    required this.isGeminiKeyValid,
    required this.isStarted,
    this.errorMessage,
    this.availableModels = const [],
    this.selectedModel,
  });

  bool get isValid => isGoogleAuthenticated && isGeminiKeyValid && isStarted;

  AuthGateState copyWith({
    bool? checking,
    bool? isGoogleAuthenticated,
    bool? isGeminiKeyValid,
    bool? isStarted,
    String? errorMessage,
    List<String>? availableModels,
    String? selectedModel,
  }) {
    return AuthGateState(
      checking: checking ?? this.checking,
      isGoogleAuthenticated: isGoogleAuthenticated ?? this.isGoogleAuthenticated,
      isGeminiKeyValid: isGeminiKeyValid ?? this.isGeminiKeyValid,
      isStarted: isStarted ?? this.isStarted,
      errorMessage: errorMessage,
      availableModels: availableModels ?? this.availableModels,
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }
}

class AuthGateNotifier extends Notifier<AuthGateState> {
  @override
  AuthGateState build() {
    final authStream = ref.watch(authRepositoryProvider).authStateChanges;
    final subscription = authStream.listen((isAuthenticated) {
      checkValidity();
    });
    ref.onDispose(() {
      subscription.cancel();
    });

    Future.microtask(() => checkValidity());
    return const AuthGateState(
      checking: true,
      isGoogleAuthenticated: false,
      isGeminiKeyValid: false,
      isStarted: false,
    );
  }

  Future<void> checkValidity() async {
    if (!state.isStarted) {
      state = state.copyWith(checking: true);
    }
    final authRepo = ref.read(authRepositoryProvider);
    final secureStorage = ref.read(secureStorageProvider);

    final isAuthed = await authRepo.isAuthenticated();
    final geminiKey = await secureStorage.getGeminiApiKey();
    final savedModel = await secureStorage.getGeminiModel();

    bool geminiValid = false;
    List<String> models = [];
    if (geminiKey != null && geminiKey.isNotEmpty) {
      try {
        models = await _fetchAvailableTextModels(geminiKey);
        geminiValid = models.isNotEmpty;
      } catch (e) {
        debugPrint('Failed to load text models: $e');
        geminiValid = false;
      }
    }

    final isInitialCheck = !state.isGoogleAuthenticated && !state.isGeminiKeyValid && !state.isStarted;
    final autoStart = isInitialCheck && isAuthed && geminiValid && savedModel != null;

    state = AuthGateState(
      checking: false,
      isGoogleAuthenticated: isAuthed,
      isGeminiKeyValid: geminiValid,
      isStarted: autoStart || (isAuthed && geminiValid && state.isStarted),
      availableModels: models,
      selectedModel: savedModel ?? (models.isNotEmpty ? _findBestModel(models) : null),
    );
  }

  Future<List<String>> _fetchAvailableTextModels(String apiKey) async {
    final response = await http.get(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> modelsJson = data['models'] ?? [];
      final List<String> textModels = [];
      for (final m in modelsJson) {
        final name = m['name'] as String? ?? '';
        final methods = m['supportedGenerationMethods'] as List<dynamic>? ?? [];
        
        // Filter text-generation models
        if (methods.contains('generateContent') && 
            (name.contains('gemini') || name.contains('gemma')) &&
            !name.contains('tts') && 
            !name.contains('image')) {
          textModels.add(name);
        }
      }
      return textModels;
    } else {
      throw Exception('Failed to fetch models: ${response.statusCode}');
    }
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

  Future<void> authenticateGoogle() async {
    state = state.copyWith(checking: true);
    try {
      final success = await ref.read(authRepositoryProvider).signIn();
      if (success) {
        state = state.copyWith(isGoogleAuthenticated: true, checking: false);
      } else {
        state = state.copyWith(checking: false, errorMessage: 'Google sign-in returned failure.');
      }
    } catch (e) {
      state = state.copyWith(checking: false, errorMessage: 'OAuth Error: $e');
    }
  }

  Future<void> submitGeminiKey(String key) async {
    state = state.copyWith(checking: true);
    try {
      final models = await _fetchAvailableTextModels(key);
      if (models.isNotEmpty) {
        await ref.read(secureStorageProvider).saveGeminiApiKey(key);
        final best = _findBestModel(models);
        await ref.read(secureStorageProvider).saveGeminiModel(best);
        
        state = state.copyWith(
          isGeminiKeyValid: true,
          checking: false,
          availableModels: models,
          selectedModel: best,
        );
      } else {
        state = state.copyWith(checking: false, errorMessage: 'No compatible text generation models found for this API Key.');
      }
    } catch (e) {
      state = state.copyWith(
        checking: false,
        errorMessage: 'Verification failed: $e',
      );
    }
  }

  Future<void> selectModel(String model) async {
    await ref.read(secureStorageProvider).saveGeminiModel(model);
    state = state.copyWith(selectedModel: model);
  }

  void startApplication() {
    if (state.isGoogleAuthenticated && state.isGeminiKeyValid) {
      state = state.copyWith(isStarted: true);
    }
  }

  Future<void> reset() async {
    state = state.copyWith(checking: true);
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthGateState(
      checking: false,
      isGoogleAuthenticated: false,
      isGeminiKeyValid: false,
      isStarted: false,
    );
  }
}

final authGateProvider = NotifierProvider<AuthGateNotifier, AuthGateState>(AuthGateNotifier.new);

class AuthGate extends ConsumerStatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final TextEditingController _geminiKeyController = TextEditingController();
  bool _obscureGeminiKey = true;

  @override
  void initState() {
    super.initState();
    _loadInputs();
  }

  Future<void> _loadInputs() async {
    final storage = ref.read(secureStorageProvider);
    final key = await storage.getGeminiApiKey();
    if (key != null) {
      _geminiKeyController.text = key;
    }
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authGateProvider);

    if (state.checking) {
      return const Scaffold(
        backgroundColor: OneDarkTheme.background,
        body: Center(child: CircularProgressIndicator(color: OneDarkTheme.primary)),
      );
    }

    if (state.isValid) {
      return widget.child;
    }

    // Blurred Authentication Screen Overlay
    return Scaffold(
      backgroundColor: OneDarkTheme.background,
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: OneDarkTheme.background.withOpacity(0.6)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 580,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: OneDarkTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OneDarkTheme.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: OneDarkTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.security, color: OneDarkTheme.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Workspace Connection',
                                style: TextStyle(
                                  color: OneDarkTheme.textLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Complete setup to activate DeadlineAI',
                                style: TextStyle(color: OneDarkTheme.textMain, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // STEP 1: Google Account
                    _buildStepCard(
                      stepNumber: '1',
                      title: 'Google Workspace Account',
                      subtitle: 'Authenticate Google Calendar, Classroom, Drive, and Gmail.',
                      isCompleted: state.isGoogleAuthenticated,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.isGoogleAuthenticated)
                            Row(
                              children: const [
                                Icon(Icons.check_circle, color: OneDarkTheme.success, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Successfully connected to Google account.',
                                  style: TextStyle(color: OneDarkTheme.success, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: OneDarkTheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  ref.read(authGateProvider.notifier).authenticateGoogle();
                                },
                                icon: const Icon(Icons.login, size: 18),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // STEP 2: Gemini API Key & Model Selection
                    _buildStepCard(
                      stepNumber: '2',
                      title: 'Gemini AI API Key & Model',
                      subtitle: 'Required for study planning and document summarization. Stored locally.',
                      isCompleted: state.isGeminiKeyValid,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.isGeminiKeyValid) ...[
                            Row(
                              children: const [
                                Icon(Icons.check_circle, color: OneDarkTheme.success, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Gemini API Key verified.',
                                  style: TextStyle(color: OneDarkTheme.success, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (state.availableModels.isNotEmpty)
                              DropdownButtonFormField<String>(
                                value: state.selectedModel,
                                dropdownColor: OneDarkTheme.surface,
                                style: const TextStyle(color: OneDarkTheme.textLight, fontSize: 13),
                                decoration: const InputDecoration(
                                  labelText: 'Active Text Model',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                                items: state.availableModels.map((model) {
                                  final displayName = model.replaceFirst('models/', '');
                                  return DropdownMenuItem<String>(
                                    value: model,
                                    child: Text(displayName),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(authGateProvider.notifier).selectModel(val);
                                  }
                                },
                              ),
                          ] else ...[
                            TextField(
                              controller: _geminiKeyController,
                              obscureText: _obscureGeminiKey,
                              style: const TextStyle(fontSize: 13, color: OneDarkTheme.textLight),
                              decoration: InputDecoration(
                                hintText: 'Enter Gemini API Key (AIzaSy...)',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _obscureGeminiKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: OneDarkTheme.textMain,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscureGeminiKey = !_obscureGeminiKey);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.paste_outlined, color: OneDarkTheme.textMain, size: 18),
                                      onPressed: () async {
                                        final data = await Clipboard.getData('text/plain');
                                        if (data?.text != null) {
                                          _geminiKeyController.text = data!.text!.trim();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: OneDarkTheme.cyan,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  final key = _geminiKeyController.text.trim();
                                  if (key.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Gemini API key is required.')),
                                    );
                                    return;
                                  }
                                  ref.read(authGateProvider.notifier).submitGeminiKey(key);
                                },
                                icon: const Icon(Icons.vpn_key, size: 18),
                                label: const Text(
                                  'Validate & Save Gemini Key',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (state.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: OneDarkTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: OneDarkTheme.error.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: OneDarkTheme.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: OneDarkTheme.error, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Divider(),
                    const SizedBox(height: 24),

                    // STEP 3: Start Application Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            ref.read(authGateProvider.notifier).reset();
                            _geminiKeyController.clear();
                          },
                          child: const Text('Reset All', style: TextStyle(color: OneDarkTheme.textDark)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.isGoogleAuthenticated && state.isGeminiKeyValid
                                ? OneDarkTheme.success
                                : OneDarkTheme.cardBg,
                            foregroundColor: state.isGoogleAuthenticated && state.isGeminiKeyValid
                                ? Colors.white
                                : OneDarkTheme.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: state.isGoogleAuthenticated && state.isGeminiKeyValid
                                    ? OneDarkTheme.success
                                    : OneDarkTheme.border,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          onPressed: state.isGoogleAuthenticated && state.isGeminiKeyValid
                              ? () {
                                  ref.read(authGateProvider.notifier).startApplication();
                                }
                              : null,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text(
                            'Start Application',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OneDarkTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? OneDarkTheme.success.withOpacity(0.5) : OneDarkTheme.border,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number / indicator
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? OneDarkTheme.success.withOpacity(0.15) : OneDarkTheme.border,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: OneDarkTheme.success, size: 16)
                  : Text(
                      stepNumber,
                      style: const TextStyle(
                        color: OneDarkTheme.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: OneDarkTheme.textLight, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: OneDarkTheme.textMain, fontSize: 11),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

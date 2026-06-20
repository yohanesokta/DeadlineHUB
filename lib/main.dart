import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/navigation.dart';
import 'core/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: DeadlineAIApp(),
    ),
  );
}

class DeadlineAIApp extends StatelessWidget {
  const DeadlineAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeadlineAI',
      debugShowCheckedModeBanner: false,
      theme: OneDarkTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}

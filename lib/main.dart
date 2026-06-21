import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/navigation/navigation.dart';
import 'core/theme/theme.dart';
import 'presentation/pages/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: DeadlineAIApp()));
}

class DeadlineAIApp extends StatelessWidget {
  const DeadlineAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeadlineHUB',
      debugShowCheckedModeBanner: false,
      theme: OneDarkTheme.darkTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return AuthGate(child: child!);
      },
    );
  }
}

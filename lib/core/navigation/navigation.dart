import 'package:go_router/go_router.dart';
import 'package:deadlinehub/presentation/pages/main_layout.dart';
import 'package:deadlinehub/features/insights/presentation/pages/insights_page.dart';
import 'package:deadlinehub/features/ai/presentation/pages/chat_page.dart';
import 'package:deadlinehub/features/calendar/presentation/pages/calendar_page.dart';
import 'package:deadlinehub/features/drive/presentation/pages/drive_page.dart';
import 'package:deadlinehub/features/classroom/presentation/pages/classroom_page.dart';
import 'package:deadlinehub/features/email/presentation/pages/email_page.dart';
import 'package:deadlinehub/features/settings/presentation/pages/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const InsightsPage(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) {
            final query = state.uri.queryParameters['query'];
            return ChatPage(initialQuery: query);
          },
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          path: '/drive',
          builder: (context, state) => const DrivePage(),
        ),
        GoRoute(
          path: '/classroom',
          builder: (context, state) => const ClassroomPage(),
        ),
        GoRoute(
          path: '/email',
          builder: (context, state) => const EmailPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);

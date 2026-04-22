import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/signup_screen.dart';
import '../../features/auth/login_screen.dart';

import '../../features/diagnostic/diagnostic_test_screen.dart';
import '../../features/diagnostic/diagnostic_report_screen.dart';

import '../../features/learning/modules_screen.dart';
import '../../features/learning/teaching_screen.dart';

import '../../features/parent/parent_control_screen.dart';

// ─────────────────────────────────────────────
// ROUTE NAMES
// ─────────────────────────────────────────────

abstract final class AppRoutes {
  static const signup = '/signup';
  static const login = '/login';

  static const diagnosticTest = '/diagnostic-test';
  static const diagnosticReport = '/diagnostic-report';

  static const modules = '/modules';
  static const teaching = '/teaching';

  static const parentControl = '/parent-control';
}

// ─────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────

final appRouter = GoRouter(
  debugLogDiagnostics: true,

  initialLocation: _getInitialRoute(),

  routes: [

    // AUTH
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // DIAGNOSTIC FLOW
    GoRoute(
      path: AppRoutes.diagnosticTest,
      name: 'diagnostic-test',
      builder: (context, state) => const DiagnosticTestScreen(),
    ),

    GoRoute(
      path: AppRoutes.diagnosticReport,
      name: 'diagnostic-report',
      builder: (context, state) => const DiagnosticReportScreen(),
    ),

    // LEARNING FLOW
    GoRoute(
      path: AppRoutes.modules,
      name: 'modules',
      builder: (context, state) => const ModulesScreen(),
    ),

    GoRoute(
      path: AppRoutes.teaching,
      name: 'teaching',
      builder: (context, state) => const TeachingScreen(),
    ),

    // PARENT CONTROL
    GoRoute(
      path: AppRoutes.parentControl,
      name: 'parent-control',
      builder: (context, state) => const ParentControlScreen(),
    ),
  ],
);


// ─────────────────────────────────────────────
// INITIAL ROUTE DECIDER
// ─────────────────────────────────────────────

String _getInitialRoute() {

  final session =
      Supabase.instance.client.auth.currentSession;

  if (session == null) {
    return AppRoutes.signup;
  }

  final metadata =
      Supabase.instance.client.auth.currentUser?.userMetadata;

  final diagnosticCompleted =
      metadata?['diagnosticCompleted'] ?? false;

  if (diagnosticCompleted == true) {
    return AppRoutes.modules;
  }

  return AppRoutes.diagnosticTest;
}
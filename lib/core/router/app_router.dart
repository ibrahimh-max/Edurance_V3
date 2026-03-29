import 'package:go_router/go_router.dart';

import '../../features/auth/signup_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/diagnostic/diagnostic_test_screen.dart';
import '../../features/diagnostic/diagnostic_report_screen.dart';
import '../../features/learning/modules_screen.dart';
import '../../features/learning/teaching_screen.dart';
import '../../features/parent/parent_control_screen.dart';

// ─────────────────────────────────────────────
//  ROUTE NAMES  (use these constants everywhere
//  instead of raw strings to avoid typos)
// ─────────────────────────────────────────────
abstract final class AppRoutes {
  static const signup         = '/signup';
  static const login          = '/login';
  static const diagnostic     = '/diagnostic';
  static const diagnosticReport = '/diagnostic-report';
  static const modules        = '/modules';
  static const teaching       = '/teaching';
  static const parentControl  = '/parent-control';
}

// ─────────────────────────────────────────────
//  ROUTER
// ─────────────────────────────────────────────
final appRouter = GoRouter(
  initialLocation: AppRoutes.signup,
  debugLogDiagnostics: true,       // prints route changes in debug console
  routes: [
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
    GoRoute(
      path: AppRoutes.diagnostic,
      name: 'diagnostic',
      builder: (context, state) => const DiagnosticTestScreen(),
    ),
    GoRoute(
      path: AppRoutes.diagnosticReport,
      name: 'diagnostic-report',
      builder: (context, state) => const DiagnosticReportScreen(),
    ),
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
    GoRoute(
      path: AppRoutes.parentControl,
      name: 'parent-control',
      builder: (context, state) => const ParentControlScreen(),
    ),
  ],
);

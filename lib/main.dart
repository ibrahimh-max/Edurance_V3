import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'providers/session_bootstrap_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
try {
  await dotenv.load(fileName: ".env");
} catch (_) {}
  
  await Supabase.initialize(
    url: 'https://puxscqufuccztrwmibsk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1eHNjcXVmdWNjenRyd21pYnNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4MDIwNzAsImV4cCI6MjA5MjM3ODA3MH0.NcG9_qCMg4PAEatzbEd9VCc9HlhcLmi7j_xumwr17WI',
  );
  
  runApp(
    const ProviderScope(
      child: EduranceApp(),
    ),
  );
}

class EduranceApp extends ConsumerWidget {
  const EduranceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hydrate SignupState from Supabase metadata on every startup / refresh.
    ref.watch(sessionBootstrapProvider);

    return MaterialApp.router(
      title: 'Edurance',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD94A),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
    );
  }
}


//edurance is psuedo agentic platfrom solving the problem of studnents not getting personalized 1:1 attetnion in a class where only 1 teacher is present //
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static bool get isLoggedIn =>
      Supabase.instance.client.auth.currentSession != null;
}

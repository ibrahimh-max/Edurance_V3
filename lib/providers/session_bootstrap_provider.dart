import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'signup_notifier.dart';

/// Hydrates [signupProvider] from Supabase user metadata.
///
/// Call this once from [SplashScreen] after confirming the user is
/// authenticated. Using a plain async function instead of [FutureProvider]
/// prevents the hydration from running during every [MaterialApp] rebuild.
Future<void> bootstrapSession(WidgetRef ref) async {
  debugPrint('Startup: bootstrapSession — begin');

  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    debugPrint('Startup: bootstrapSession — no authenticated user, skipping');
    return;
  }

final profile = await Supabase.instance.client
    .from('profiles')
    .select()
    .eq('id', user.id)
    .maybeSingle();

if (profile == null) {
  debugPrint('Startup: Profile not found.');
  return;
}

ref.read(signupProvider.notifier)
    .updateChildName(profile['child_name'] ?? '');

ref.read(signupProvider.notifier)
    .updateGender(profile['gender'] ?? '');

ref.read(signupProvider.notifier)
    .updateAge((profile['age'] ?? 0) as int);

ref.read(signupProvider.notifier)
    .updateClassLevel((profile['class_level'] ?? 0) as int);

ref.read(signupProvider.notifier)
    .updateParentMobile(profile['parent_mobile'] ?? '');

ref.read(signupProvider.notifier)
    .updateParentEmail(user.email ?? '');

debugPrint(
  'Startup: Session hydrated from profiles table.',
);

debugPrint('Startup: Session hydrated from profiles table.');
}

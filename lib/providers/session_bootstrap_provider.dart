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

  final metadata = user.userMetadata ?? {};

  ref
      .read(signupProvider.notifier)
      .updateChildName((metadata['childName'] as String?) ?? '');

  ref
      .read(signupProvider.notifier)
      .updateGender((metadata['gender'] as String?) ?? '');

  ref
      .read(signupProvider.notifier)
      .updateAge((metadata['age'] as num?)?.toInt() ?? 0);

  ref
      .read(signupProvider.notifier)
      .updateClassLevel((metadata['classLevel'] as num?)?.toInt() ?? 0);

  ref
      .read(signupProvider.notifier)
      .updateParentMobile((metadata['parentMobile'] as String?) ?? '');

  debugPrint('Startup: Session hydrated — childName=${metadata['childName']}');
}

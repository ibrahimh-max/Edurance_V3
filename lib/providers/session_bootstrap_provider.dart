import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'signup_notifier.dart';

/// Reads Supabase user metadata on startup and hydrates [signupProvider]
/// so the child name (and other profile fields) survive a browser refresh.
final sessionBootstrapProvider = FutureProvider<void>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return;

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
});

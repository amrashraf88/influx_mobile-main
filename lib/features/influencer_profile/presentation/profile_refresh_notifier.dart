import 'package:flutter/foundation.dart';

/// Global signal that the authenticated influencer profile should be refetched.
///
/// Bumped when the user opens the Profile / Settings tab again, and after a
/// successful profile edit, so the screens always show fresh API data instead
/// of the values cached when they were first built.
final ValueNotifier<int> influencerProfileRefresh = ValueNotifier<int>(0);

/// Request a profile refetch on all listeners.
void requestInfluencerProfileRefresh() {
  influencerProfileRefresh.value++;
}

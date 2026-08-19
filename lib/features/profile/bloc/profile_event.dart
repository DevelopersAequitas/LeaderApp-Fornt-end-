import 'package:flutter/material.dart';

@immutable
abstract class ProfileEvent {
  const ProfileEvent();
}

/// Triggers loading of user profile details.
class LoadProfileData extends ProfileEvent {
  const LoadProfileData();
}

/// Triggers sign-out flow.
class TriggerSignOut extends ProfileEvent {
  const TriggerSignOut();
}

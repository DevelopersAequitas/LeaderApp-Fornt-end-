abstract class P2PMeetingsEvent {
  const P2PMeetingsEvent();
}

class LoadP2PMeetings extends P2PMeetingsEvent {
  final String? circleId;
  const LoadP2PMeetings({this.circleId});
}

class CreateP2PMeetingEvent extends P2PMeetingsEvent {
  final String peerUserId;
  final String scheduledAt;
  final String mode;
  final String location;
  final String? notes;

  const CreateP2PMeetingEvent({
    required this.peerUserId,
    required this.scheduledAt,
    this.mode = 'online',
    this.location = 'Google Meet',
    this.notes,
  });
}

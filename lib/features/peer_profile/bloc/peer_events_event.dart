import 'package:equatable/equatable.dart';

abstract class PeerEventsEvent extends Equatable {
  const PeerEventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPeerEventsData extends PeerEventsEvent {
  final String memberId;
  final bool isRefresh;

  const LoadPeerEventsData({required this.memberId, this.isRefresh = false});

  @override
  List<Object?> get props => [memberId, isRefresh];
}

class ChangePeerEventsTab extends PeerEventsEvent {
  final int tabIndex;

  const ChangePeerEventsTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

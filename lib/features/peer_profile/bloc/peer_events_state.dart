import 'package:equatable/equatable.dart';
import '../model/peer_event_models.dart';

class PeerEventsState extends Equatable {
  final int activeTab;
  final bool isLoading;
  final List<MemberEventItemModel> events;
  final List<MemberEventRegistrationModel> registrations;
  final List<MemberAttendanceRecordModel> attendanceRecords;
  final String errorMessage;

  const PeerEventsState({
    this.activeTab = 0,
    this.isLoading = false,
    this.events = const [],
    this.registrations = const [],
    this.attendanceRecords = const [],
    this.errorMessage = '',
  });

  PeerEventsState copyWith({
    int? activeTab,
    bool? isLoading,
    List<MemberEventItemModel>? events,
    List<MemberEventRegistrationModel>? registrations,
    List<MemberAttendanceRecordModel>? attendanceRecords,
    String? errorMessage,
  }) {
    return PeerEventsState(
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      registrations: registrations ?? this.registrations,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        activeTab,
        isLoading,
        events,
        registrations,
        attendanceRecords,
        errorMessage,
      ];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/peers_repository.dart';
import '../model/peer_event_models.dart';
import 'peer_events_event.dart';
import 'peer_events_state.dart';

class PeerEventsBloc extends Bloc<PeerEventsEvent, PeerEventsState> {
  final PeersRepository _peersRepository;

  PeerEventsBloc({PeersRepository? peersRepository})
      : _peersRepository = peersRepository ?? PeersRepositoryImpl(),
        super(const PeerEventsState()) {
    on<LoadPeerEventsData>(_onLoadPeerEventsData);
    on<ChangePeerEventsTab>(_onChangePeerEventsTab);
  }

  Future<void> _onLoadPeerEventsData(
    LoadPeerEventsData event,
    Emitter<PeerEventsState> emit,
  ) async {
    final memberId = event.memberId.trim();
    if (memberId.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      // Concurrently fetch all three APIs
      final attendanceFuture = _peersRepository.getMemberAttendance(memberId);
      final eventsFuture = _peersRepository.getMemberEvents(memberId);
      final registrationsFuture = _peersRepository.getMemberEventRegistrations(memberId);

      final attendanceRes = await attendanceFuture;
      final eventsRes = await eventsFuture;
      final registrationsRes = await registrationsFuture;

      emit(state.copyWith(
        isLoading: false,
        attendanceRecords: attendanceRes.success && attendanceRes.data != null
            ? attendanceRes.data!
            : <MemberAttendanceRecordModel>[],
        events: eventsRes.success && eventsRes.data != null
            ? eventsRes.data!
            : <MemberEventItemModel>[],
        registrations: registrationsRes.success && registrationsRes.data != null
            ? registrationsRes.data!
            : <MemberEventRegistrationModel>[],
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load member events and attendance.',
      ));
    }
  }

  void _onChangePeerEventsTab(
    ChangePeerEventsTab event,
    Emitter<PeerEventsState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tabIndex));
  }
}

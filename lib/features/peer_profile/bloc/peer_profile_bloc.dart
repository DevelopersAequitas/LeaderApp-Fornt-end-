import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/peers_repository.dart';
import '../model/peer_profile_model.dart';
import 'peer_profile_event.dart';
import 'peer_profile_state.dart';

/// Business Logic Component for managing Peer Profile details dynamically.
class PeerProfileBloc extends Bloc<PeerProfileEvent, PeerProfileState> {
  final PeersRepository _peersRepository;

  PeerProfileBloc({PeersRepository? peersRepository})
      : _peersRepository = peersRepository ?? PeersRepositoryImpl(),
        super(const PeerProfileState()) {
    on<LoadPeerProfile>(_onLoadPeerProfile);
    on<ChangeProfileSubTab>(_onChangeProfileSubTab);
  }

  Future<void> _onLoadPeerProfile(LoadPeerProfile event, Emitter<PeerProfileState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final peer = event.peer;

    List<PeerMeetingModel> realMeetings = [];
    List<PeerActivityModel> realActivities = [];

    try {
      if (peer.id.isNotEmpty) {
        final meetingsRes = await _peersRepository.getPeerMeetings(peer.id);
        if (meetingsRes.success && meetingsRes.data != null) {
          realMeetings = meetingsRes.data!;
        }

        final activitiesRes = await _peersRepository.getPeerActivities(peer.id);
        if (activitiesRes.success && activitiesRes.data != null) {
          realActivities = activitiesRes.data!;
        }
      }
    } catch (_) {}

    final details = PeerProfileDetailModel(
      dealsClosed: peer.dealsFormatted,
      referralsGiven: peer.impactCount,
      p2pSessions: (peer.impactCount * 0.8).round(),
      coinsEarned: peer.coins,
      attendanceRate: peer.attendance,
      birthday: '',
      anniversary: '',
      meetings: realMeetings,
      activities: realActivities,
      testimonials: const [],
    );

    emit(
      state.copyWith(
        isLoading: false,
        peer: peer,
        details: details,
      ),
    );
  }

  void _onChangeProfileSubTab(ChangeProfileSubTab event, Emitter<PeerProfileState> emit) {
    emit(state.copyWith(activeSubTab: event.index));
  }
}

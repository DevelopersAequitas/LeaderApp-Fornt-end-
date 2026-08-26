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

    var currentPeer = event.peer;
    List<PeerMeetingModel> realMeetings = [];
    List<PeerActivityModel> realActivities = [];

    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    final hasValidId = currentPeer.id.trim().isNotEmpty && uuidRegex.hasMatch(currentPeer.id.trim());

    if (hasValidId) {
      try {
        final peerDetailsRes = await _peersRepository.getPeerDetails(currentPeer.id.trim());
        if (peerDetailsRes.success && peerDetailsRes.data != null) {
          currentPeer = peerDetailsRes.data!;
        }

        final meetingsRes = await _peersRepository.getPeerMeetings(currentPeer.id.trim());
        if (meetingsRes.success && meetingsRes.data != null) {
          realMeetings = meetingsRes.data!;
        }

        final activitiesRes = await _peersRepository.getPeerActivities(currentPeer.id.trim());
        if (activitiesRes.success && activitiesRes.data != null) {
          realActivities = activitiesRes.data!;
        }
      } catch (_) {}
    }

    final details = PeerProfileDetailModel(
      dealsClosed: currentPeer.dealsFormatted,
      referralsGiven: currentPeer.impactCount,
      p2pSessions: (currentPeer.impactCount * 0.8).round(),
      coinsEarned: currentPeer.coins,
      attendanceRate: currentPeer.attendance,
      birthday: '',
      anniversary: '',
      meetings: realMeetings,
      activities: realActivities,
      testimonials: const [],
    );

    emit(
      state.copyWith(
        isLoading: false,
        peer: currentPeer,
        details: details,
      ),
    );
  }

  void _onChangeProfileSubTab(ChangeProfileSubTab event, Emitter<PeerProfileState> emit) {
    emit(state.copyWith(activeSubTab: event.index));
  }
}

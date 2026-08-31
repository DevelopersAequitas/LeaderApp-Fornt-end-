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

  Future<void> _onLoadPeerProfile(
    LoadPeerProfile event,
    Emitter<PeerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    var currentPeer = event.peer;
    PeerProfileDetailModel details = PeerProfileDetailModel(
      bio: currentPeer.bio ?? '',
      birthday: currentPeer.birthday ?? '',
      anniversary: currentPeer.anniversary ?? '',
      joinedDate: currentPeer.joinedDate ?? '',
      dealsClosed: currentPeer.dealsFormatted,
      dealsGiven: currentPeer.dealsGiven ?? '₹0.0',
      dealsReceived: currentPeer.dealsReceived ?? '₹0.0',
      referralsGiven: currentPeer.referralsGiven ?? currentPeer.impactCount,
      referralsReceived: currentPeer.referralsReceived ?? 0,
      p2pSessions: currentPeer.p2pMeetings ?? (currentPeer.impactCount > 0 ? (currentPeer.impactCount * 0.4).round() : 0),
      coinsEarned: currentPeer.coins,
      attendanceRate: currentPeer.attendance.isNotEmpty ? currentPeer.attendance : '0%',
      impactCount: currentPeer.impactCount,
      tags: currentPeer.tags.isNotEmpty ? currentPeer.tags.split(' · ') : const [],
      phone: currentPeer.phone,
      email: currentPeer.email,
      whatsapp: currentPeer.whatsapp,
      linkedin: currentPeer.linkedin,
    );

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    final hasValidId = currentPeer.id.trim().isNotEmpty &&
        uuidRegex.hasMatch(currentPeer.id.trim());

    if (hasValidId) {
      try {
        final profileDetailRes =
            await _peersRepository.getPeerProfileDetail(currentPeer.id.trim());
        if (profileDetailRes.success && profileDetailRes.data != null) {
          details = profileDetailRes.data!;
        }

        final peerDetailsRes =
            await _peersRepository.getPeerDetails(currentPeer.id.trim());
        if (peerDetailsRes.success && peerDetailsRes.data != null) {
          currentPeer = peerDetailsRes.data!;
        }

        // Fallback for meetings if empty in primary response
        if (details.meetings.isEmpty) {
          final meetingsRes =
              await _peersRepository.getPeerMeetings(currentPeer.id.trim());
          if (meetingsRes.success && meetingsRes.data != null) {
            details = PeerProfileDetailModel(
              bio: details.bio,
              birthday: details.birthday,
              anniversary: details.anniversary,
              joinedDate: details.joinedDate,
              dealsClosed: details.dealsClosed,
              dealsGiven: details.dealsGiven,
              dealsReceived: details.dealsReceived,
              referralsGiven: details.referralsGiven,
              referralsReceived: details.referralsReceived,
              p2pSessions: details.p2pSessions,
              coinsEarned: details.coinsEarned,
              attendanceRate: details.attendanceRate,
              impactCount: details.impactCount,
              tags: details.tags,
              phone: details.phone,
              email: details.email,
              whatsapp: details.whatsapp,
              linkedin: details.linkedin,
              meetings: meetingsRes.data!,
              activities: details.activities,
              testimonials: details.testimonials,
            );
          }
        }
      } catch (_) {}
    }

    emit(
      state.copyWith(
        isLoading: false,
        peer: currentPeer,
        details: details,
      ),
    );
  }

  void _onChangeProfileSubTab(
    ChangeProfileSubTab event,
    Emitter<PeerProfileState> emit,
  ) {
    emit(state.copyWith(activeSubTab: event.index));
  }
}

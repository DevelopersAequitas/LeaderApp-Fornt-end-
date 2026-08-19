import 'package:flutter_bloc/flutter_bloc.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';
import 'peer_profile_event.dart';
import 'peer_profile_state.dart';

/// Business Logic Component for managing Peer Profile details.
class PeerProfileBloc extends Bloc<PeerProfileEvent, PeerProfileState> {
  PeerProfileBloc() : super(const PeerProfileState()) {
    on<LoadPeerProfile>(_onLoadPeerProfile);
    on<ChangeProfileSubTab>(_onChangeProfileSubTab);
  }

  void _onLoadPeerProfile(LoadPeerProfile event, Emitter<PeerProfileState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final peer = event.peer;

    // Priya Sharma's exact stats matching the mockup screenshots
    final bool isPriya = peer.name.contains('Priya');

    final details = PeerProfileDetailModel(
      dealsClosed: isPriya ? '₹32k' : peer.dealsFormatted,
      referralsGiven: isPriya ? 8 : 4,
      p2pSessions: isPriya ? 14 : 6,
      coinsEarned: peer.coins,
      attendanceRate: isPriya ? '96%' : peer.attendance,
      birthday: isPriya ? '12 Mar' : '22 Apr',
      anniversary: isPriya ? '18 Jun' : '15 Oct',
      meetings: const [
        PeerMeetingModel(
          day: '1',
          month: 'Aug',
          title: 'Monthly Circle Meeting',
          timeLocation: '7:30 AM - Grand Ballroom, Mumbai',
          status: 'Confirmed',
        ),
        PeerMeetingModel(
          day: '5',
          month: 'Sep',
          title: 'Monthly Circle Meeting',
          timeLocation: '7:30 AM - The Leela, Mumbai',
          status: 'Open',
        ),
        PeerMeetingModel(
          day: '3',
          month: 'Oct',
          title: 'Monthly Circle Meeting',
          timeLocation: '7:30 AM - Grand Ballroom, Mumbai',
          status: 'Planned',
        ),
      ],
      activities: const [
        PeerActivityModel(
          iconType: 'arrows',
          title: 'Completed P2P meeting',
          subtitle: '14 sessions total this quarter',
          time: '2 days ago',
        ),
        PeerActivityModel(
          iconType: 'speaker',
          title: 'Gave 8 referrals',
          subtitle: 'Across circle members',
          time: '1 week ago',
        ),
        PeerActivityModel(
          iconType: 'star',
          title: 'Earned Champion badge',
          subtitle: 'Impact score: 38 lives',
          time: '2 weeks ago',
        ),
        PeerActivityModel(
          iconType: 'trophy',
          title: 'Closed ₹32k in deals',
          subtitle: 'Business transactions confirmed',
          time: '3 weeks ago',
        ),
        PeerActivityModel(
          iconType: 'target',
          title: 'Joined Mumbai Tech Sunrise',
          subtitle: 'Since Jan 2024',
          time: 'Jan 2024',
        ),
      ],
      testimonials: const [
        PeerTestimonialModel(
          authorName: 'Ananya Patel',
          authorInitials: 'AP',
          subtitle: 'Testimonial for this peer - Jul 27, 2026',
          rating: 5,
          content: 'Ananya connected me with three healthcare clients through PEERS. Exceptional networker and a true peer!',
        ),
        PeerTestimonialModel(
          authorName: 'James O\'Brien',
          authorInitials: 'JO',
          subtitle: 'Written by this peer - Jul 24, 2026',
          rating: 5,
          content: 'Priya\'s introduction led to a ₹28k deal. The PEERS platform is transforming how we do business.',
        ),
      ],
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

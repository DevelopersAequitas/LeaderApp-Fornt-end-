import '../../core/network/api_response.dart';
import '../../features/business_deals/model/business_deal_model.dart';
import '../../features/impacts/model/impact_model.dart';
import '../../features/p2p_meetings/model/p2p_meeting_model.dart';
import '../../features/peers_by_coins/model/coin_balance_model.dart';
import '../../features/referrals/model/referral_model.dart';
import '../../features/requirements/model/requirement_model.dart';
import '../../features/testimonials/model/testimonial_model.dart';
import '../datasources/remote/activities_remote_datasource.dart';

abstract class ActivitiesRepository {
  Future<ApiResponse<List<ImpactModel>>> getImpacts({String? circleId});
  Future<ApiResponse<ImpactModel>> createImpact({
    required String beneficiaryUserId,
    required String impactType,
    required String title,
    required String description,
  });

  Future<ApiResponse<List<P2PMeetingModel>>> getP2PMeetings({String? circleId});
  Future<ApiResponse<P2PMeetingModel>> createP2PMeeting({
    required String peerUserId,
    required String scheduledAt,
    String mode = 'online',
    String location = 'Google Meet',
    String? notes,
  });

  Future<ApiResponse<List<BusinessDealModel>>> getBusinessDeals({String? circleId});
  Future<ApiResponse<BusinessDealModel>> createBusinessDeal({
    required String withPeerId,
    required dynamic amount,
    String currency = 'INR',
    String dealType = 'closed',
    String? notes,
  });

  Future<ApiResponse<List<ReferralModel>>> getReferrals({String? circleId, String? status});
  Future<ApiResponse<List<TestimonialModel>>> getTestimonials({String? circleId});
  Future<ApiResponse<TestimonialModel>> createTestimonial({
    required String toPeerId,
    required String content,
    int rating = 5,
  });
  Future<ApiResponse<List<CoinBalanceModel>>> getPeersByCoins({String? circleId});
  Future<ApiResponse<List<RequirementModel>>> getRequirements({String? circleId});
}

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  final ActivitiesRemoteDataSource _remoteDataSource;

  ActivitiesRepositoryImpl({ActivitiesRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? ActivitiesRemoteDataSource();

  @override
  Future<ApiResponse<List<ImpactModel>>> getImpacts({String? circleId}) {
    return _remoteDataSource.getImpacts(circleId: circleId);
  }

  @override
  Future<ApiResponse<ImpactModel>> createImpact({
    required String beneficiaryUserId,
    required String impactType,
    required String title,
    required String description,
  }) {
    return _remoteDataSource.createImpact(
      beneficiaryUserId: beneficiaryUserId,
      impactType: impactType,
      title: title,
      description: description,
    );
  }

  @override
  Future<ApiResponse<List<P2PMeetingModel>>> getP2PMeetings({String? circleId}) {
    return _remoteDataSource.getP2PMeetings(circleId: circleId);
  }

  @override
  Future<ApiResponse<P2PMeetingModel>> createP2PMeeting({
    required String peerUserId,
    required String scheduledAt,
    String mode = 'online',
    String location = 'Google Meet',
    String? notes,
  }) {
    return _remoteDataSource.createP2PMeeting(
      peerUserId: peerUserId,
      scheduledAt: scheduledAt,
      mode: mode,
      location: location,
      notes: notes,
    );
  }

  @override
  Future<ApiResponse<List<BusinessDealModel>>> getBusinessDeals({String? circleId}) {
    return _remoteDataSource.getBusinessDeals(circleId: circleId);
  }

  @override
  Future<ApiResponse<BusinessDealModel>> createBusinessDeal({
    required String withPeerId,
    required dynamic amount,
    String currency = 'INR',
    String dealType = 'closed',
    String? notes,
  }) {
    return _remoteDataSource.createBusinessDeal(
      withPeerId: withPeerId,
      amount: amount,
      currency: currency,
      dealType: dealType,
      notes: notes,
    );
  }

  @override
  Future<ApiResponse<List<ReferralModel>>> getReferrals({
    String? circleId,
    String? status,
  }) {
    return _remoteDataSource.getReferrals(circleId: circleId, status: status);
  }

  @override
  Future<ApiResponse<List<TestimonialModel>>> getTestimonials({String? circleId}) {
    return _remoteDataSource.getTestimonials(circleId: circleId);
  }

  @override
  Future<ApiResponse<TestimonialModel>> createTestimonial({
    required String toPeerId,
    required String content,
    int rating = 5,
  }) {
    return _remoteDataSource.createTestimonial(
      toPeerId: toPeerId,
      content: content,
      rating: rating,
    );
  }

  @override
  Future<ApiResponse<List<CoinBalanceModel>>> getPeersByCoins({String? circleId}) {
    return _remoteDataSource.getPeersByCoins(circleId: circleId);
  }

  @override
  Future<ApiResponse<List<RequirementModel>>> getRequirements({String? circleId}) {
    return _remoteDataSource.getRequirements(circleId: circleId);
  }
}

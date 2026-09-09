import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/business_deals/model/business_deal_model.dart';
import '../../../features/impacts/model/impact_model.dart';
import '../../../features/p2p_meetings/model/p2p_meeting_model.dart';
import '../../../features/peers_by_coins/model/coin_balance_model.dart';
import '../../../features/referrals/model/referral_model.dart';
import '../../../features/requirements/model/requirement_model.dart';
import '../../../features/testimonials/model/testimonial_model.dart';

/// Remote Data Source for all 7 Activity Endpoints.
class ActivitiesRemoteDataSource {
  final ApiClient _apiClient;

  ActivitiesRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str.trim());
  }

  // --- 1. Impacts (Life Impact) ---
  Future<ApiResponse<List<ImpactModel>>> getImpacts({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<ImpactModel>>(
      ApiEndpoints.impacts,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => ImpactModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <ImpactModel>[];
      },
    );
  }

  Future<ApiResponse<ImpactModel>> createImpact({
    required String beneficiaryUserId,
    required String impactType,
    required String title,
    required String description,
  }) async {
    return _apiClient.post<ImpactModel>(
      ApiEndpoints.impacts,
      body: {
        'beneficiary_user_id': beneficiaryUserId,
        'impact_type': impactType,
        'title': title,
        'description': description,
      },
      fromJsonT: (json) => ImpactModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 2. P2P Meetings ---
  Future<ApiResponse<List<P2PMeetingModel>>> getP2PMeetings({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<P2PMeetingModel>>(
      ApiEndpoints.p2pMeetings,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => P2PMeetingModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <P2PMeetingModel>[];
      },
    );
  }

  Future<ApiResponse<P2PMeetingModel>> createP2PMeeting({
    required String peerUserId,
    required String scheduledAt,
    String mode = 'online',
    String location = 'Google Meet',
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'peer_user_id': peerUserId,
      'scheduled_at': scheduledAt,
      'mode': mode,
      'location': location,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    return _apiClient.post<P2PMeetingModel>(
      ApiEndpoints.p2pMeetings,
      body: body,
      fromJsonT: (json) => P2PMeetingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 3. Business Deals ---
  Future<ApiResponse<List<BusinessDealModel>>> getBusinessDeals({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<BusinessDealModel>>(
      ApiEndpoints.businessDeals,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => BusinessDealModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <BusinessDealModel>[];
      },
    );
  }

  Future<ApiResponse<BusinessDealModel>> createBusinessDeal({
    required String withPeerId,
    required dynamic amount,
    String currency = 'INR',
    String dealType = 'closed',
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'with_peer_id': withPeerId,
      'amount': amount,
      'currency': currency,
      'deal_type': dealType,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    return _apiClient.post<BusinessDealModel>(
      ApiEndpoints.businessDeals,
      body: body,
      fromJsonT: (json) => BusinessDealModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 4. Referrals ---
  Future<ApiResponse<List<ReferralModel>>> getReferrals({String? circleId, String? status}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;
    if (status != null && status != 'All') params['status'] = status;

    return _apiClient.get<List<ReferralModel>>(
      ApiEndpoints.referrals,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => ReferralModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <ReferralModel>[];
      },
    );
  }

  // --- 5. Testimonials ---
  Future<ApiResponse<List<TestimonialModel>>> getTestimonials({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<TestimonialModel>>(
      ApiEndpoints.testimonials,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => TestimonialModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <TestimonialModel>[];
      },
    );
  }

  Future<ApiResponse<TestimonialModel>> createTestimonial({
    required String toPeerId,
    required String content,
    int rating = 5,
  }) async {
    return _apiClient.post<TestimonialModel>(
      ApiEndpoints.testimonials,
      body: {
        'to_peer_id': toPeerId,
        'content': content,
        'rating': rating,
      },
      fromJsonT: (json) => TestimonialModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 6. Peers by Coins ---
  Future<ApiResponse<List<CoinBalanceModel>>> getPeersByCoins({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<CoinBalanceModel>>(
      ApiEndpoints.peersByCoins,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is Map && json['leaderboard'] is List) {
          return (json['leaderboard'] as List)
              .map((item) => CoinBalanceModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (json is List) {
          return json
              .map((item) => CoinBalanceModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <CoinBalanceModel>[];
      },
    );
  }

  // --- 7. Requirements ---
  Future<ApiResponse<List<RequirementModel>>> getRequirements({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<RequirementModel>>(
      ApiEndpoints.requirements,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => RequirementModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <RequirementModel>[];
      },
    );
  }
}

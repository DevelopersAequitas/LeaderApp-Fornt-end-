import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/peers_by_coins/model/coin_balance_model.dart';
import '../../../features/referrals/model/referral_model.dart';
import '../../../features/testimonials/model/testimonial_model.dart';

class ReferralsRemoteDataSource {
  final ApiClient _apiClient;

  ReferralsRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str.trim());
  }

  /// Fetches referrals list.
  Future<ApiResponse<List<ReferralModel>>> getReferrals({String? circleId, String? status}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;
    if (status != null && status != 'All') params['status'] = status;

    return _apiClient.get<List<ReferralModel>>(
      ApiEndpoints.referrals,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => ReferralModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <ReferralModel>[];
      },
    );
  }

  /// Fetches testimonials list.
  Future<ApiResponse<List<TestimonialModel>>> getTestimonials({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<TestimonialModel>>(
      ApiEndpoints.testimonials,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => TestimonialModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <TestimonialModel>[];
      },
    );
  }

  /// Fetches peers sorted by coins leaderboard.
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
          return json.map((item) => CoinBalanceModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <CoinBalanceModel>[];
      },
    );
  }

  /// Creates and submits a new referral lead.
  Future<ApiResponse<Map<String, dynamic>>> createReferralLead({
    required String toPeerId,
    required String prospectName,
    String? prospectCompany,
    String? prospectPhone,
    String? prospectEmail,
    String? estimatedDealValue,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'to_peer_id': toPeerId,
      'prospect_name': prospectName,
    };
    if (prospectCompany != null) body['prospect_company'] = prospectCompany;
    if (prospectPhone != null) body['prospect_phone'] = prospectPhone;
    if (prospectEmail != null) body['prospect_email'] = prospectEmail;
    if (estimatedDealValue != null) body['estimated_deal_value'] = estimatedDealValue;
    if (notes != null) body['notes'] = notes;

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.referrals,
      body: body,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}

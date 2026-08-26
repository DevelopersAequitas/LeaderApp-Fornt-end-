import '../../core/network/api_response.dart';
import '../../features/circle_details/model/circle_event_model.dart';
import '../../features/circle_details/model/circle_sub_industry_model.dart';
import '../../features/peers/model/peer_model.dart';
import '../../features/teams/model/teams_model.dart';
import '../datasources/remote/teams_remote_datasource.dart';

abstract class TeamsRepository {
  Future<ApiResponse<TeamsSummaryModel>> getTeamsSummary();
  Future<ApiResponse<List<CircleTeamModel>>> getCircles({String? industry, String? status, String? search});
  Future<ApiResponse<CircleTeamModel>> getCircleDetails(String id);
  Future<ApiResponse<List<PeerModel>>> getCirclePeers(String circleId, {String? status, String? search, String? sort});
  Future<ApiResponse<CircleSubIndustriesResponse>> getSubIndustries(String circleId);
  Future<ApiResponse<List<CircleEventModel>>> getCircleEvents(String circleId, {String? filter});
  Future<ApiResponse<List<String>>> getIndustries();
  Future<ApiResponse<List<IndustryModel>>> getIndustriesList();
}

class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource _remoteDataSource;

  TeamsRepositoryImpl({
    TeamsRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? TeamsRemoteDataSource();

  @override
  Future<ApiResponse<TeamsSummaryModel>> getTeamsSummary() async {
    return _remoteDataSource.getTeamsSummary();
  }

  @override
  Future<ApiResponse<List<CircleTeamModel>>> getCircles({
    String? industry,
    String? status,
    String? search,
  }) async {
    return _remoteDataSource.getCircles(
      industry: industry,
      status: status,
      search: search,
    );
  }

  @override
  Future<ApiResponse<CircleTeamModel>> getCircleDetails(String id) async {
    return _remoteDataSource.getCircleDetails(id);
  }

  @override
  Future<ApiResponse<List<PeerModel>>> getCirclePeers(
    String circleId, {
    String? status,
    String? search,
    String? sort,
  }) async {
    return _remoteDataSource.getCirclePeers(
      circleId,
      status: status,
      search: search,
      sort: sort,
    );
  }

  @override
  Future<ApiResponse<CircleSubIndustriesResponse>> getSubIndustries(String circleId) async {
    return _remoteDataSource.getSubIndustries(circleId);
  }

  @override
  Future<ApiResponse<List<CircleEventModel>>> getCircleEvents(
    String circleId, {
    String? filter,
  }) async {
    return _remoteDataSource.getCircleEvents(circleId, filter: filter);
  }

  @override
  Future<ApiResponse<List<IndustryModel>>> getIndustriesList() async {
    return _remoteDataSource.getIndustriesList();
  }

  @override
  Future<ApiResponse<List<String>>> getIndustries() async {
    return _remoteDataSource.getIndustries();
  }
}

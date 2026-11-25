import '../../impacts/model/life_impact_detail_model.dart';

class PeerIdentityHeaderModel {
  final String id;
  final String peerCode;
  final String fullName;
  final String designation;
  final String companyName;
  final String primaryCategory;
  final String subCategory;
  final String level4Category;
  final String city;
  final String state;
  final String country;
  final String districtId;
  final String districtName;
  final String circleId;
  final String circleName;
  final String membershipStatus;
  final String accountStatus;
  final String? approvalStatus;
  final bool isVerified;
  final bool isOnline;
  final String? lastSeenAt;
  final String? currentLeadershipRole;
  final String? profilePhotoUrl;
  final bool contactAuthorized;
  final String? phone;
  final String? email;
  final String? whatsapp;
  final String? linkedin;

  const PeerIdentityHeaderModel({
    this.id = '',
    this.peerCode = '',
    this.fullName = '',
    this.designation = '',
    this.companyName = '',
    this.primaryCategory = '',
    this.subCategory = '',
    this.level4Category = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.districtId = '',
    this.districtName = '',
    this.circleId = '',
    this.circleName = '',
    this.membershipStatus = '',
    this.accountStatus = '',
    this.approvalStatus,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeenAt,
    this.currentLeadershipRole,
    this.profilePhotoUrl,
    this.contactAuthorized = false,
    this.phone,
    this.email,
    this.whatsapp,
    this.linkedin,
  });

  factory PeerIdentityHeaderModel.fromJson(Map<String, dynamic> json) {
    final contact = json['contact'] is Map
        ? Map<String, dynamic>.from(json['contact'] as Map)
        : <String, dynamic>{};
    String? clean(dynamic v) {
      final s = v?.toString().trim() ?? '';
      return (s.isEmpty || s == 'null') ? null : s;
    }

    return PeerIdentityHeaderModel(
      id: (json['id'] ?? '').toString(),
      peerCode: (json['peer_code'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      designation: (json['designation'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString(),
      primaryCategory: (json['primary_category'] ?? '').toString(),
      subCategory: (json['sub_category'] ?? '').toString(),
      level4Category: (json['level4_category'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      districtId: (json['district_id'] ?? '').toString(),
      districtName: (json['district_name'] ?? '').toString(),
      circleId: (json['circle_id'] ?? '').toString(),
      circleName: (json['circle_name'] ?? '').toString(),
      membershipStatus: (json['membership_status'] ?? '').toString(),
      accountStatus: (json['account_status'] ?? '').toString(),
      approvalStatus: clean(json['approval_status']),
      isVerified: json['is_verified'] == true,
      isOnline: json['is_online'] == true,
      lastSeenAt: clean(json['last_seen_at']),
      currentLeadershipRole: clean(json['current_leadership_role']),
      profilePhotoUrl: clean(
        json['profile_photo_url'] ?? json['profile_image'] ?? json['avatar_url'],
      ),
      contactAuthorized: json['contact_authorized'] == true,
      phone: clean(contact['phone']),
      email: clean(contact['email']),
      whatsapp: clean(contact['whatsapp']),
      linkedin: clean(contact['linkedin']),
    );
  }
}

class PeerBusinessInfoModel {
  final String companyName;
  final String companyType;
  final String designation;
  final String shortBio;
  final String experienceSummary;
  final int? experienceYears;
  final int? yearOfEstablishment;
  final int? yearsInBusiness;
  final String industry;
  final String subIndustry;
  final String level4Category;
  final List<String> businessCategories;
  final List<String> industryTags;
  final String productsServicesOffered;
  final String numberOfEmployees;
  final String annualRevenueRange;
  final String website;
  final String businessAddress;
  final String businessCity;
  final String businessState;
  final String businessCountry;
  final String businessPincode;
  final List<String> skills;
  final String superpower;
  final List<String> canHelpWith;
  final List<String> lookingFor;
  final List<String> businessKeywords;
  final List<String> targetRegions;
  final List<String> targetBusinessCategories;
  final List<String> industriesOfInterest;
  final List<String> collaborationGoals;
  final String preferredMeetingFormat;
  final bool willingToMentor;
  final bool openToCrossCityCollaboration;
  final bool openToSpeakingAtEvents;
  final int completenessPercent;

  const PeerBusinessInfoModel({
    this.companyName = '',
    this.companyType = '',
    this.designation = '',
    this.shortBio = '',
    this.experienceSummary = '',
    this.experienceYears,
    this.yearOfEstablishment,
    this.yearsInBusiness,
    this.industry = '',
    this.subIndustry = '',
    this.level4Category = '',
    this.businessCategories = const [],
    this.industryTags = const [],
    this.productsServicesOffered = '',
    this.numberOfEmployees = '',
    this.annualRevenueRange = '',
    this.website = '',
    this.businessAddress = '',
    this.businessCity = '',
    this.businessState = '',
    this.businessCountry = '',
    this.businessPincode = '',
    this.skills = const [],
    this.superpower = '',
    this.canHelpWith = const [],
    this.lookingFor = const [],
    this.businessKeywords = const [],
    this.targetRegions = const [],
    this.targetBusinessCategories = const [],
    this.industriesOfInterest = const [],
    this.collaborationGoals = const [],
    this.preferredMeetingFormat = '',
    this.willingToMentor = false,
    this.openToCrossCityCollaboration = false,
    this.openToSpeakingAtEvents = false,
    this.completenessPercent = 0,
  });

  bool get hasAnyData =>
      companyName.isNotEmpty ||
      shortBio.isNotEmpty ||
      experienceSummary.isNotEmpty ||
      industry.isNotEmpty ||
      subIndustry.isNotEmpty ||
      level4Category.isNotEmpty ||
      productsServicesOffered.isNotEmpty ||
      website.isNotEmpty ||
      businessAddress.isNotEmpty ||
      skills.isNotEmpty ||
      canHelpWith.isNotEmpty ||
      lookingFor.isNotEmpty ||
      targetBusinessCategories.isNotEmpty;

  factory PeerBusinessInfoModel.fromJson(Map<String, dynamic> json) {
    List<String> strList(dynamic v) {
      if (v is List) {
        return v
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty && e != 'null')
            .toList();
      }
      return const [];
    }

    int? parseIntNullable(dynamic v) =>
        v == null ? null : int.tryParse(v.toString());

    return PeerBusinessInfoModel(
      companyName: (json['company_name'] ?? '').toString().trim(),
      companyType: (json['company_type'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      shortBio: (json['short_bio'] ?? '').toString().trim(),
      experienceSummary: (json['experience_summary'] ?? '').toString().trim(),
      experienceYears: parseIntNullable(json['experience_years']),
      yearOfEstablishment: parseIntNullable(json['year_of_establishment']),
      yearsInBusiness: parseIntNullable(json['years_in_business']),
      industry: (json['industry'] ?? '').toString().trim(),
      subIndustry: (json['sub_industry'] ?? '').toString().trim(),
      level4Category: (json['level4_category'] ?? '').toString().trim(),
      businessCategories: strList(json['business_categories']),
      industryTags: strList(json['industry_tags']),
      productsServicesOffered:
          (json['products_services_offered'] ?? '').toString().trim(),
      numberOfEmployees: (json['number_of_employees'] ?? '').toString().trim(),
      annualRevenueRange:
          (json['annual_revenue_range'] ?? '').toString().trim(),
      website: (json['website'] ?? '').toString().trim(),
      businessAddress: (json['business_address'] ?? '').toString().trim(),
      businessCity: (json['business_city'] ?? '').toString().trim(),
      businessState: (json['business_state'] ?? '').toString().trim(),
      businessCountry: (json['business_country'] ?? '').toString().trim(),
      businessPincode: (json['business_pincode'] ?? '').toString().trim(),
      skills: strList(json['skills']),
      superpower: (json['superpower'] ?? '').toString().trim(),
      canHelpWith: strList(json['i_can_help_with']),
      lookingFor: strList(json['i_am_looking_for']),
      businessKeywords: strList(json['business_keywords']),
      targetRegions: strList(json['target_regions']),
      targetBusinessCategories: strList(json['target_business_categories']),
      industriesOfInterest: strList(json['industries_of_interest']),
      collaborationGoals: strList(json['collaboration_goals']),
      preferredMeetingFormat:
          (json['preferred_meeting_format'] ?? '').toString().trim(),
      willingToMentor: json['willing_to_mentor'] == true,
      openToCrossCityCollaboration:
          json['open_to_cross_city_collaboration'] == true,
      openToSpeakingAtEvents: json['open_to_speaking_at_events'] == true,
      completenessPercent:
          int.tryParse((json['completeness_percent'] ?? '0').toString()) ?? 0,
    );
  }
}

class PeerCircleMembershipItem {
  final String circleId;
  final String circleName;
  final String? districtName;
  final String role;
  final String status;
  final String? joinedAt;
  final String? expiresAt;

  const PeerCircleMembershipItem({
    this.circleId = '',
    required this.circleName,
    this.districtName,
    this.role = '',
    this.status = '',
    this.joinedAt,
    this.expiresAt,
  });

  factory PeerCircleMembershipItem.fromJson(Map<String, dynamic> json) {
    return PeerCircleMembershipItem(
      circleId: (json['circle_id'] ?? '').toString(),
      circleName: (json['circle_name'] ?? '').toString(),
      districtName: json['district_name']?.toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      joinedAt: json['joined_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }
}

class PeerAssignedLeaderItem {
  final String roleKey;
  final String roleLabel;
  final String userId;
  final String name;
  final String companyName;

  const PeerAssignedLeaderItem({
    this.roleKey = '',
    required this.roleLabel,
    this.userId = '',
    required this.name,
    this.companyName = '',
  });

  factory PeerAssignedLeaderItem.fromJson(Map<String, dynamic> json) {
    return PeerAssignedLeaderItem(
      roleKey: (json['role_key'] ?? '').toString(),
      roleLabel: (json['role_label'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString(),
    );
  }
}

class PeerOrganizationInfoModel {
  final String country;
  final String state;
  final String districtId;
  final String districtName;
  final String city;
  final String membershipType;
  final String membershipStatus;
  final bool isSponsoredMember;
  final String joiningDate;
  final String circleJoinedAt;
  final String renewalExpiryDate;
  final String primaryCircleId;
  final String primaryCircleName;
  final String primaryCircleStage;
  final String? introducedById;
  final String? introducedByName;
  final String? introducedByCompany;
  final List<PeerCircleMembershipItem> circles;
  final List<PeerAssignedLeaderItem> assignedLeadership;

  const PeerOrganizationInfoModel({
    this.country = '',
    this.state = '',
    this.districtId = '',
    this.districtName = '',
    this.city = '',
    this.membershipType = '',
    this.membershipStatus = '',
    this.isSponsoredMember = false,
    this.joiningDate = '',
    this.circleJoinedAt = '',
    this.renewalExpiryDate = '',
    this.primaryCircleId = '',
    this.primaryCircleName = '',
    this.primaryCircleStage = '',
    this.introducedById,
    this.introducedByName,
    this.introducedByCompany,
    this.circles = const [],
    this.assignedLeadership = const [],
  });

  bool get hasAnyData =>
      country.isNotEmpty ||
      state.isNotEmpty ||
      districtName.isNotEmpty ||
      city.isNotEmpty ||
      primaryCircleName.isNotEmpty ||
      circles.isNotEmpty ||
      assignedLeadership.isNotEmpty;

  factory PeerOrganizationInfoModel.fromJson(Map<String, dynamic> json) {
    final pc = json['primary_circle'] is Map
        ? Map<String, dynamic>.from(json['primary_circle'] as Map)
        : <String, dynamic>{};
    final intro = json['introduced_by'] is Map
        ? Map<String, dynamic>.from(json['introduced_by'] as Map)
        : null;

    return PeerOrganizationInfoModel(
      country: (json['country'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      districtId: (json['district_id'] ?? '').toString().trim(),
      districtName: (json['district_name'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      membershipType: (json['membership_type'] ?? '').toString().trim(),
      membershipStatus: (json['membership_status'] ?? '').toString().trim(),
      isSponsoredMember: json['is_sponsored_member'] == true,
      joiningDate: (json['joining_date'] ?? '').toString().trim(),
      circleJoinedAt: (json['circle_joined_at'] ?? '').toString().trim(),
      renewalExpiryDate: (json['renewal_expiry_date'] ?? '').toString().trim(),
      primaryCircleId: (pc['id'] ?? '').toString().trim(),
      primaryCircleName: (pc['name'] ?? '').toString().trim(),
      primaryCircleStage: (pc['stage'] ?? '').toString().trim(),
      introducedById: intro?['id']?.toString(),
      introducedByName: intro?['name']?.toString(),
      introducedByCompany: intro?['company_name']?.toString(),
      circles: (json['circles'] is List ? (json['circles'] as List) : const [])
          .whereType<Map>()
          .map((e) => PeerCircleMembershipItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      assignedLeadership: (json['assigned_leadership'] is List
              ? (json['assigned_leadership'] as List)
              : const [])
          .whereType<Map>()
          .map((e) => PeerAssignedLeaderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class PeerLeadershipPositionItem {
  final String roleKey;
  final String roleLabel;
  final String scopeType;
  final String circleId;
  final String circleName;
  final String? startedAt;
  final String? endedAt;
  final String status;
  final bool isCurrent;
  final String? removalReason;

  const PeerLeadershipPositionItem({
    this.roleKey = '',
    required this.roleLabel,
    this.scopeType = '',
    this.circleId = '',
    this.circleName = '',
    this.startedAt,
    this.endedAt,
    this.status = '',
    this.isCurrent = true,
    this.removalReason,
  });

  factory PeerLeadershipPositionItem.fromJson(Map<String, dynamic> json) {
    return PeerLeadershipPositionItem(
      roleKey: (json['role_key'] ?? '').toString(),
      roleLabel: (json['role_label'] ?? '').toString(),
      scopeType: (json['scope_type'] ?? '').toString(),
      circleId: (json['circle_id'] ?? '').toString(),
      circleName: (json['circle_name'] ?? '').toString(),
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
      status: (json['status'] ?? '').toString(),
      isCurrent: json['is_current'] == true,
      removalReason: json['removal_reason']?.toString(),
    );
  }
}

class PeerLeadershipReportSummaryItem {
  final String id;
  final String reportType;
  final String period;
  final String circleName;
  final String status;
  final String? submittedAt;

  const PeerLeadershipReportSummaryItem({
    this.id = '',
    required this.reportType,
    this.period = '',
    this.circleName = '',
    this.status = '',
    this.submittedAt,
  });

  factory PeerLeadershipReportSummaryItem.fromJson(Map<String, dynamic> json) {
    return PeerLeadershipReportSummaryItem(
      id: (json['id'] ?? '').toString(),
      reportType: (json['report_type'] ?? 'Report').toString(),
      period: (json['period'] ?? '').toString(),
      circleName: (json['circle_name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      submittedAt: json['submitted_at']?.toString(),
    );
  }
}

class PeerLeadershipHistoryModel {
  final bool hasLeadershipHistory;
  final List<PeerLeadershipPositionItem> currentPositions;
  final List<PeerLeadershipPositionItem> historicalPositions;
  final int reportsSubmittedCount;
  final List<PeerLeadershipReportSummaryItem> recentReports;

  const PeerLeadershipHistoryModel({
    this.hasLeadershipHistory = false,
    this.currentPositions = const [],
    this.historicalPositions = const [],
    this.reportsSubmittedCount = 0,
    this.recentReports = const [],
  });

  bool get hasAnyData =>
      hasLeadershipHistory ||
      currentPositions.isNotEmpty ||
      historicalPositions.isNotEmpty ||
      reportsSubmittedCount > 0;

  factory PeerLeadershipHistoryModel.fromJson(Map<String, dynamic> json) {
    final current = (json['current_positions'] is List
            ? (json['current_positions'] as List)
            : const [])
        .whereType<Map>()
        .map((e) => PeerLeadershipPositionItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final historical = (json['historical_positions'] is List
            ? (json['historical_positions'] as List)
            : const [])
        .whereType<Map>()
        .map((e) => PeerLeadershipPositionItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final reports = (json['recent_reports'] is List
            ? (json['recent_reports'] as List)
            : const [])
        .whereType<Map>()
        .map((e) => PeerLeadershipReportSummaryItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final rCount =
        int.tryParse((json['reports_submitted_count'] ?? '0').toString()) ?? 0;

    return PeerLeadershipHistoryModel(
      hasLeadershipHistory: json['has_leadership_history'] == true ||
          current.isNotEmpty ||
          historical.isNotEmpty ||
          rCount > 0,
      currentPositions: current,
      historicalPositions: historical,
      reportsSubmittedCount: rCount,
      recentReports: reports,
    );
  }
}

class PeerDealSummaryItem {
  final String id;
  final String direction;
  final String counterpartName;
  final String amountFormatted;
  final String businessType;
  final String dealDate;
  final String notes;

  const PeerDealSummaryItem({
    this.id = '',
    this.direction = 'given',
    required this.counterpartName,
    this.amountFormatted = '',
    this.businessType = '',
    this.dealDate = '',
    this.notes = '',
  });

  factory PeerDealSummaryItem.fromJson(Map<String, dynamic> json) {
    return PeerDealSummaryItem(
      id: (json['id'] ?? '').toString(),
      direction: (json['direction'] ?? 'given').toString(),
      counterpartName: (json['counterpart_name'] ?? 'Peer').toString(),
      amountFormatted: (json['amount_formatted'] ?? '').toString(),
      businessType: (json['business_type'] ?? '').toString(),
      dealDate: (json['deal_date'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

class PeerAskSummaryItem {
  final String id;
  final String flowCode;
  final String flowName;
  final String title;
  final String status;
  final String? createdAt;

  const PeerAskSummaryItem({
    this.id = '',
    this.flowCode = '',
    this.flowName = '',
    required this.title,
    this.status = '',
    this.createdAt,
  });

  factory PeerAskSummaryItem.fromJson(Map<String, dynamic> json) {
    return PeerAskSummaryItem(
      id: (json['id'] ?? '').toString(),
      flowCode: (json['flow_code'] ?? '').toString(),
      flowName: (json['flow_name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class PeerCollaborationGrowthModel {
  final int dealsLoggedCount;
  final int dealsGivenCount;
  final int dealsReceivedCount;
  final String dealsGivenValueFormatted;
  final String dealsReceivedValueFormatted;
  final String dealsTotalValueFormatted;
  final int crossCircleDealsCount;
  final int referralsGivenCount;
  final int referralsReceivedCount;
  final int collaborationAsksCount;
  final int referralAsksCount;
  final int helpAsksCount;
  final int requirementsCount;
  final int introducedPeersCount;
  final List<PeerDealSummaryItem> recentDeals;
  final List<PeerAskSummaryItem> recentAsks;

  const PeerCollaborationGrowthModel({
    this.dealsLoggedCount = 0,
    this.dealsGivenCount = 0,
    this.dealsReceivedCount = 0,
    this.dealsGivenValueFormatted = '',
    this.dealsReceivedValueFormatted = '',
    this.dealsTotalValueFormatted = '',
    this.crossCircleDealsCount = 0,
    this.referralsGivenCount = 0,
    this.referralsReceivedCount = 0,
    this.collaborationAsksCount = 0,
    this.referralAsksCount = 0,
    this.helpAsksCount = 0,
    this.requirementsCount = 0,
    this.introducedPeersCount = 0,
    this.recentDeals = const [],
    this.recentAsks = const [],
  });

  int get totalAsksCount =>
      collaborationAsksCount + referralAsksCount + helpAsksCount + requirementsCount;

  bool get hasAnyData =>
      dealsLoggedCount > 0 ||
      referralsGivenCount > 0 ||
      referralsReceivedCount > 0 ||
      totalAsksCount > 0 ||
      introducedPeersCount > 0 ||
      recentDeals.isNotEmpty ||
      recentAsks.isNotEmpty;

  factory PeerCollaborationGrowthModel.fromJson(Map<String, dynamic> json) {
    int pInt(String k) => int.tryParse((json[k] ?? '0').toString()) ?? 0;
    return PeerCollaborationGrowthModel(
      dealsLoggedCount: pInt('deals_logged_count'),
      dealsGivenCount: pInt('deals_given_count'),
      dealsReceivedCount: pInt('deals_received_count'),
      dealsGivenValueFormatted:
          (json['deals_given_value_formatted'] ?? '').toString(),
      dealsReceivedValueFormatted:
          (json['deals_received_value_formatted'] ?? '').toString(),
      dealsTotalValueFormatted:
          (json['deals_total_value_formatted'] ?? '').toString(),
      crossCircleDealsCount: pInt('cross_circle_deals_count'),
      referralsGivenCount: pInt('referrals_given_count'),
      referralsReceivedCount: pInt('referrals_received_count'),
      collaborationAsksCount: pInt('collaboration_asks_count'),
      referralAsksCount: pInt('referral_asks_count'),
      helpAsksCount: pInt('help_asks_count'),
      requirementsCount: pInt('requirements_count'),
      introducedPeersCount: pInt('introduced_peers_count'),
      recentDeals: (json['recent_deals'] is List
              ? (json['recent_deals'] as List)
              : const [])
          .whereType<Map>()
          .map((e) => PeerDealSummaryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      recentAsks: (json['recent_asks'] is List
              ? (json['recent_asks'] as List)
              : const [])
          .whereType<Map>()
          .map((e) => PeerAskSummaryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class PeerLifeImpactSummaryModel {
  final int total;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int totalLivesImpacted;
  final bool canModerateImpacts;
  final List<({String category, int count})> categories;
  final List<LifeImpactDetailModel> submissions;

  const PeerLifeImpactSummaryModel({
    this.total = 0,
    this.pendingCount = 0,
    this.approvedCount = 0,
    this.rejectedCount = 0,
    this.totalLivesImpacted = 0,
    this.canModerateImpacts = false,
    this.categories = const [],
    this.submissions = const [],
  });

  bool get hasAnyData =>
      total > 0 || totalLivesImpacted > 0 || submissions.isNotEmpty;

  factory PeerLifeImpactSummaryModel.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] is Map
        ? Map<String, dynamic>.from(json['counts'] as Map)
        : <String, dynamic>{};
    int cInt(String k) => int.tryParse((counts[k] ?? '0').toString()) ?? 0;

    final cats = (json['categories_breakdown'] is List
            ? (json['categories_breakdown'] as List)
            : const [])
        .whereType<Map>()
        .map((e) => (
              category: (e['category'] ?? '').toString(),
              count: int.tryParse((e['count'] ?? '0').toString()) ?? 0,
            ))
        .where((c) => c.category.isNotEmpty)
        .toList();

    final subs = (json['submissions'] is List
            ? (json['submissions'] as List)
            : const [])
        .whereType<Map>()
        .map((e) => LifeImpactDetailModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PeerLifeImpactSummaryModel(
      total: cInt('total'),
      pendingCount: cInt('pending'),
      approvedCount: cInt('approved'),
      rejectedCount: cInt('rejected'),
      totalLivesImpacted: cInt('total_lives_impacted'),
      canModerateImpacts: json['can_moderate_impacts'] == true,
      categories: cats,
      submissions: subs,
    );
  }
}

class PeerPerformanceInfoModel {
  final int attended;
  final int absent;
  final int lateCount;
  final int excused;
  final int totalAttendanceRecorded;
  final double? attendanceRatePercent;
  final int eventsRegisteredCount;
  final int eventsAttendedCount;
  final int p2pMeetingsCount;
  final int testimonialsGivenCount;
  final int testimonialsReceivedCount;
  final int postsCount;
  final int creativesCount;
  final int reportsSubmittedCount;
  final String? coinMilestoneTitle;
  final String? contributionAwardName;
  final List<Map<String, dynamic>> badges;

  const PeerPerformanceInfoModel({
    this.attended = 0,
    this.absent = 0,
    this.lateCount = 0,
    this.excused = 0,
    this.totalAttendanceRecorded = 0,
    this.attendanceRatePercent,
    this.eventsRegisteredCount = 0,
    this.eventsAttendedCount = 0,
    this.p2pMeetingsCount = 0,
    this.testimonialsGivenCount = 0,
    this.testimonialsReceivedCount = 0,
    this.postsCount = 0,
    this.creativesCount = 0,
    this.reportsSubmittedCount = 0,
    this.coinMilestoneTitle,
    this.contributionAwardName,
    this.badges = const [],
  });

  bool get hasAnyData =>
      totalAttendanceRecorded > 0 ||
      eventsRegisteredCount > 0 ||
      p2pMeetingsCount > 0 ||
      testimonialsGivenCount > 0 ||
      testimonialsReceivedCount > 0 ||
      postsCount > 0 ||
      badges.isNotEmpty;

  factory PeerPerformanceInfoModel.fromJson(Map<String, dynamic> json) {
    final att = json['circle_attendance'] is Map
        ? Map<String, dynamic>.from(json['circle_attendance'] as Map)
        : <String, dynamic>{};
    final ev = json['events'] is Map
        ? Map<String, dynamic>.from(json['events'] as Map)
        : <String, dynamic>{};

    return PeerPerformanceInfoModel(
      attended: int.tryParse((att['attended'] ?? '0').toString()) ?? 0,
      absent: int.tryParse((att['absent'] ?? '0').toString()) ?? 0,
      lateCount: int.tryParse((att['late'] ?? '0').toString()) ?? 0,
      excused: int.tryParse((att['excused'] ?? '0').toString()) ?? 0,
      totalAttendanceRecorded:
          int.tryParse((att['total_recorded'] ?? '0').toString()) ?? 0,
      attendanceRatePercent: att['attendance_rate_percent'] != null
          ? double.tryParse(att['attendance_rate_percent'].toString())
          : null,
      eventsRegisteredCount:
          int.tryParse((ev['registered_count'] ?? '0').toString()) ?? 0,
      eventsAttendedCount:
          int.tryParse((ev['attended_count'] ?? '0').toString()) ?? 0,
      p2pMeetingsCount:
          int.tryParse((json['p2p_meetings_count'] ?? '0').toString()) ?? 0,
      testimonialsGivenCount:
          int.tryParse((json['testimonials_given_count'] ?? '0').toString()) ??
              0,
      testimonialsReceivedCount: int.tryParse(
              (json['testimonials_received_count'] ?? '0').toString()) ??
          0,
      postsCount: int.tryParse((json['posts_count'] ?? '0').toString()) ?? 0,
      creativesCount:
          int.tryParse((json['creatives_count'] ?? '0').toString()) ?? 0,
      reportsSubmittedCount:
          int.tryParse((json['reports_submitted_count'] ?? '0').toString()) ??
              0,
      coinMilestoneTitle: json['coin_milestone_title']?.toString(),
      contributionAwardName: json['contribution_award_name']?.toString(),
      badges: (json['badges'] is List ? (json['badges'] as List) : const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }
}

class PeerComplianceInfoModel {
  final bool isVisible;
  final String accountStatus;
  final String? approvalStatus;
  final String? membershipStatus;
  final String? renewalStatus;
  final String? startsAt;
  final String? expiresAt;
  final int? daysRemaining;
  final List<String> pendingActions;
  final String? adminRemarks;
  final String? planName;
  final String? planPrice;

  const PeerComplianceInfoModel({
    this.isVisible = false,
    this.accountStatus = '',
    this.approvalStatus,
    this.membershipStatus,
    this.renewalStatus,
    this.startsAt,
    this.expiresAt,
    this.daysRemaining,
    this.pendingActions = const [],
    this.adminRemarks,
    this.planName,
    this.planPrice,
  });

  factory PeerComplianceInfoModel.fromJson(Map<String, dynamic> json) {
    final sub = json['subscription_summary'] is Map
        ? Map<String, dynamic>.from(json['subscription_summary'] as Map)
        : <String, dynamic>{};
    return PeerComplianceInfoModel(
      isVisible: json['is_visible'] == true,
      accountStatus: (json['account_status'] ?? '').toString(),
      approvalStatus: json['approval_status']?.toString(),
      membershipStatus: json['membership_status']?.toString(),
      renewalStatus: json['renewal_status']?.toString(),
      startsAt: json['starts_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      daysRemaining: json['days_remaining'] != null
          ? int.tryParse(json['days_remaining'].toString())
          : null,
      pendingActions: (json['pending_actions'] is List
              ? (json['pending_actions'] as List)
              : const [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      adminRemarks: json['admin_remarks']?.toString(),
      planName: sub['plan_name']?.toString(),
      planPrice: sub['price']?.toString(),
    );
  }
}

class PeerTimelineEventModel {
  final String id;
  final String eventType;
  final String title;
  final String subtitle;
  final String status;
  final String date;
  final String? referenceType;
  final String? referenceId;

  const PeerTimelineEventModel({
    this.id = '',
    this.eventType = '',
    required this.title,
    this.subtitle = '',
    this.status = '',
    this.date = '',
    this.referenceType,
    this.referenceId,
  });

  factory PeerTimelineEventModel.fromJson(Map<String, dynamic> json) {
    return PeerTimelineEventModel(
      id: (json['id'] ?? '').toString(),
      eventType: (json['event_type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id']?.toString(),
    );
  }
}

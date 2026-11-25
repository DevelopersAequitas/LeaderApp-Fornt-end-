import '../../leader_activities/model/leader_activity_item_model.dart';
import '../../peers/model/peer_model.dart';

class ImpactAttachmentModel {
  final String id;
  final String url;
  final String title;
  final String mimeType;
  final bool isImage;

  const ImpactAttachmentModel({
    this.id = '',
    required this.url,
    this.title = 'Evidence',
    this.mimeType = '',
    this.isImage = false,
  });

  factory ImpactAttachmentModel.fromJson(Map<String, dynamic> json) {
    final url = (json['url'] ?? json['file_url'] ?? json['path'] ?? '').toString().trim();
    final mime = (json['mime_type'] ?? '').toString().trim();
    final isImg = json['is_image'] == true ||
        mime.toLowerCase().startsWith('image/') ||
        RegExp(r'\.(jpg|jpeg|png|webp|gif)(\?.*)?$', caseSensitive: false).hasMatch(url);
    return ImpactAttachmentModel(
      id: (json['id'] ?? '').toString(),
      url: url,
      title: (json['title'] ?? json['name'] ?? 'Submitted Evidence').toString(),
      mimeType: mime,
      isImage: isImg,
    );
  }
}

class ImpactPeerSummaryModel {
  final String id;
  final String peerCode;
  final String name;
  final String designation;
  final String companyName;
  final String? avatarUrl;
  final String city;
  final String circleName;
  final String districtName;

  const ImpactPeerSummaryModel({
    this.id = '',
    this.peerCode = '',
    this.name = '',
    this.designation = '',
    this.companyName = '',
    this.avatarUrl,
    this.city = '',
    this.circleName = '',
    this.districtName = '',
  });

  factory ImpactPeerSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] ?? json['peer_name'] ?? json['display_name'] ?? '').toString().trim();
    final rawAvatar = (json['profile_image'] ?? json['profile_photo_url'] ?? json['avatar_url'] ?? '').toString().trim();
    return ImpactPeerSummaryModel(
      id: (json['id'] ?? json['user_id'] ?? json['peer_id'] ?? '').toString().trim(),
      peerCode: (json['peer_code'] ?? '').toString().trim(),
      name: rawName,
      designation: (json['designation'] ?? '').toString().trim(),
      companyName: (json['company_name'] ?? json['business_name'] ?? json['company'] ?? '').toString().trim(),
      avatarUrl: rawAvatar.isNotEmpty ? rawAvatar : null,
      city: (json['city'] ?? json['location'] ?? '').toString().trim(),
      circleName: (json['circle_name'] ?? '').toString().trim(),
      districtName: (json['district_name'] ?? '').toString().trim(),
    );
  }

  PeerModel toPeerModel() {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final initials = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.length >= 2 ? name.substring(0, 2).toUpperCase() : (name.isNotEmpty ? name[0].toUpperCase() : 'PR'));
    return PeerModel(
      id: id,
      initials: initials,
      name: name.isNotEmpty ? name : 'Peer',
      avatarUrl: avatarUrl,
      company: companyName,
      circle: circleName,
      location: city,
      tags: '',
      impactCount: 0,
      dealsFormatted: '₹0',
      coins: 0,
      attendance: '',
      status: 'Active',
      designation: designation.isNotEmpty ? designation : null,
    );
  }
}

class ImpactVerificationEventModel {
  final String event;
  final String label;
  final String status;
  final String actorName;
  final String actorRole;
  final String timestamp;
  final String? remarks;

  const ImpactVerificationEventModel({
    this.event = '',
    required this.label,
    this.status = '',
    this.actorName = '',
    this.actorRole = '',
    this.timestamp = '',
    this.remarks,
  });

  factory ImpactVerificationEventModel.fromJson(Map<String, dynamic> json) {
    final rawRemarks = json['remarks']?.toString().trim();
    return ImpactVerificationEventModel(
      event: (json['event'] ?? '').toString(),
      label: (json['label'] ?? 'Verification Update').toString(),
      status: (json['status'] ?? '').toString(),
      actorName: (json['actor_name'] ?? '').toString().trim(),
      actorRole: (json['actor_role'] ?? '').toString().trim(),
      timestamp: (json['timestamp'] ?? '').toString().trim(),
      remarks: rawRemarks != null && rawRemarks.isNotEmpty ? rawRemarks : null,
    );
  }
}

class LifeImpactDetailModel {
  final String id;
  final String title;
  final String impactCategory;
  final String description;
  final String storyToShare;
  final String additionalRemarks;
  final int livesImpacted;
  final String status;
  final String statusLabel;
  final String impactDate;
  final String submittedAt;
  final String location;
  final String organizationName;
  final String circleId;
  final String circleName;
  final String districtId;
  final String districtName;
  final String peerCode;
  final ImpactPeerSummaryModel submittedBy;
  final ImpactPeerSummaryModel? beneficiary;
  final List<ImpactAttachmentModel> attachments;
  final String? approvedByName;
  final String? approvedAt;
  final String? rejectedByName;
  final String? rejectedAt;
  final String? reviewRemarks;
  final List<ImpactVerificationEventModel> verificationHistory;
  final bool? canApprove;
  final bool? canReject;
  final String? deniedReason;

  const LifeImpactDetailModel({
    required this.id,
    required this.title,
    this.impactCategory = '',
    this.description = '',
    this.storyToShare = '',
    this.additionalRemarks = '',
    this.livesImpacted = 1,
    this.status = 'pending',
    this.statusLabel = 'Pending',
    this.impactDate = '',
    this.submittedAt = '',
    this.location = '',
    this.organizationName = '',
    this.circleId = '',
    this.circleName = '',
    this.districtId = '',
    this.districtName = '',
    this.peerCode = '',
    this.submittedBy = const ImpactPeerSummaryModel(),
    this.beneficiary,
    this.attachments = const [],
    this.approvedByName,
    this.approvedAt,
    this.rejectedByName,
    this.rejectedAt,
    this.reviewRemarks,
    this.verificationHistory = const [],
    this.canApprove,
    this.canReject,
    this.deniedReason,
  });

  bool get isPending => status.trim().toLowerCase() == 'pending';
  bool get isApproved => status.trim().toLowerCase() == 'approved';
  bool get isRejected => status.trim().toLowerCase() == 'rejected';

  factory LifeImpactDetailModel.fromJson(Map<String, dynamic> json) {
    final verification = json['verification'] is Map
        ? Map<String, dynamic>.from(json['verification'] as Map)
        : <String, dynamic>{};
    final permissions = json['permissions'] is Map
        ? Map<String, dynamic>.from(json['permissions'] as Map)
        : <String, dynamic>{};

    final submittedByRaw = json['submitted_by'] ?? json['from_peer'] ?? json['peer'];
    final submittedBy = submittedByRaw is Map
        ? ImpactPeerSummaryModel.fromJson(Map<String, dynamic>.from(submittedByRaw))
        : ImpactPeerSummaryModel(
            id: (json['peer_id'] ?? json['user_id'] ?? json['peer_user_id'] ?? '').toString(),
            peerCode: (json['peer_code'] ?? '').toString(),
            name: (json['peer_name'] ?? json['name'] ?? '').toString(),
            avatarUrl: json['profile_image']?.toString(),
            city: (json['city'] ?? json['location'] ?? '').toString(),
            companyName: (json['company_name'] ?? json['business_name'] ?? '').toString(),
            circleName: (json['circle_name'] ?? '').toString(),
            districtName: (json['district_name'] ?? '').toString(),
          );

    final beneficiaryRaw = json['beneficiary'] ?? json['impacted_peer'] ?? json['to_peer'];
    final beneficiary = beneficiaryRaw is Map && beneficiaryRaw.isNotEmpty
        ? ImpactPeerSummaryModel.fromJson(Map<String, dynamic>.from(beneficiaryRaw))
        : null;

    final rawAttachments = json['attachments'] is List ? (json['attachments'] as List) : const [];
    final attachments = rawAttachments
        .whereType<Map>()
        .map((e) => ImpactAttachmentModel.fromJson(Map<String, dynamic>.from(e)))
        .where((a) => a.url.isNotEmpty)
        .toList();

    final rawHistory = json['verification_history'] is List ? (json['verification_history'] as List) : const [];
    final history = rawHistory
        .whereType<Map>()
        .map((e) => ImpactVerificationEventModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final rawStatus = (json['status'] ?? verification['status'] ?? 'pending').toString().trim().toLowerCase();
    final rawStatusLabel = (json['status_label'] ?? verification['status_label'] ?? '').toString().trim();
    final statusLabel = rawStatusLabel.isNotEmpty
        ? rawStatusLabel
        : (rawStatus.isNotEmpty ? '${rawStatus[0].toUpperCase()}${rawStatus.substring(1)}' : 'Pending');

    final lives = int.tryParse((json['life_impacted'] ?? json['lives_impacted'] ?? '1').toString()) ?? 1;

    return LifeImpactDetailModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['action'] ?? json['impact_category'] ?? 'Life Impact').toString(),
      impactCategory: (json['impact_category'] ?? json['action'] ?? '').toString(),
      description: (json['description'] ?? json['story'] ?? json['story_to_share'] ?? '').toString(),
      storyToShare: (json['story_to_share'] ?? json['story'] ?? '').toString(),
      additionalRemarks: (json['additional_remarks'] ?? '').toString(),
      livesImpacted: lives > 0 ? lives : 1,
      status: rawStatus,
      statusLabel: statusLabel,
      impactDate: (json['impact_date'] ?? json['date'] ?? '').toString(),
      submittedAt: (json['submitted_at'] ?? json['created_at'] ?? '').toString(),
      location: (json['location'] ?? json['city'] ?? submittedBy.city).toString(),
      organizationName: (json['organization_name'] ?? json['company_name'] ?? json['business_name'] ?? submittedBy.companyName).toString(),
      circleId: (json['circle_id'] ?? '').toString(),
      circleName: (json['circle_name'] ?? submittedBy.circleName).toString(),
      districtId: (json['district_id'] ?? '').toString(),
      districtName: (json['district_name'] ?? submittedBy.districtName).toString(),
      peerCode: (json['peer_code'] ?? submittedBy.peerCode).toString(),
      submittedBy: submittedBy,
      beneficiary: (beneficiary != null && (beneficiary.name.isNotEmpty || beneficiary.id.isNotEmpty)) ? beneficiary : null,
      attachments: attachments,
      approvedByName: verification['approved_by_name']?.toString(),
      approvedAt: verification['approved_at']?.toString(),
      rejectedByName: verification['rejected_by_name']?.toString(),
      rejectedAt: verification['rejected_at']?.toString(),
      reviewRemarks: verification['review_remarks']?.toString(),
      verificationHistory: history,
      canApprove: permissions['can_approve'] as bool? ?? json['can_review'] as bool?,
      canReject: permissions['can_reject'] as bool? ?? json['can_review'] as bool?,
      deniedReason: permissions['denied_reason']?.toString(),
    );
  }

  factory LifeImpactDetailModel.fromActivityItem(LeaderActivityItemModel item) {
    final normStatus = item.status.trim().toLowerCase();
    return LifeImpactDetailModel(
      id: item.id,
      title: item.title,
      impactCategory: item.badgeLabel ?? item.subtitle,
      description: item.description,
      storyToShare: item.description,
      livesImpacted: item.livesImpacted ?? 1,
      status: normStatus,
      statusLabel: normStatus.isNotEmpty
          ? '${normStatus[0].toUpperCase()}${normStatus.substring(1)}'
          : 'Pending',
      impactDate: item.date,
      submittedAt: item.submittedAt ?? item.date,
      location: item.city,
      organizationName: item.company,
      circleName: item.circleName,
      districtName: item.districtName ?? '',
      peerCode: item.peerCode ?? '',
      submittedBy: ImpactPeerSummaryModel(
        id: item.peerId,
        peerCode: item.peerCode ?? '',
        name: item.peerName,
        designation: item.designation,
        companyName: item.company,
        avatarUrl: item.avatarUrl,
        city: item.city,
        circleName: item.circleName,
        districtName: item.districtName ?? '',
      ),
      beneficiary: (item.targetPeerName != null && item.targetPeerName!.trim().isNotEmpty)
          ? ImpactPeerSummaryModel(
              name: item.targetPeerName!,
              companyName: item.targetPeerCompany ?? '',
            )
          : null,
      reviewRemarks: item.reviewRemarks,
      canApprove: item.canReview,
      canReject: item.canReview,
    );
  }
}

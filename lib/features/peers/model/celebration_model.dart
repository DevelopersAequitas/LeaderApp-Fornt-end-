import 'peer_model.dart';

/// Model representing a celebration (birthday or anniversary) for a peer.
class CelebrationModel {
  final String id;
  final String peerId;
  final String peerName;
  final String? firstName;
  final String? lastName;
  final String company;
  final String? designation;
  final String? circleName;
  final String? circleId;
  final String? profilePhotoUrl;
  final String date;
  final String? day;
  final String? month;
  final String type; // "birthday" or "anniversary"
  final String? milestone;
  final bool isToday;
  final bool wished;

  const CelebrationModel({
    this.id = '',
    this.peerId = '',
    required this.peerName,
    this.firstName,
    this.lastName,
    required this.company,
    this.designation,
    this.circleName,
    this.circleId,
    this.profilePhotoUrl,
    required this.date,
    this.day,
    this.month,
    required this.type,
    this.milestone,
    this.isToday = false,
    this.wished = false,
  });

  factory CelebrationModel.fromJson(Map<dynamic, dynamic> json, String type) {
    final rawName = (json['name'] as String? ?? json['peer_name'] as String? ?? '').trim();
    final fName = json['first_name'] as String?;
    final lName = json['last_name'] as String?;
    final resolvedName = rawName.isNotEmpty
        ? rawName
        : ([fName ?? '', lName ?? ''].join(' ').trim().isNotEmpty
            ? [fName ?? '', lName ?? ''].join(' ').trim()
            : 'Peer');

    return CelebrationModel(
      id: json['id']?.toString() ?? '',
      peerId: json['peer_id']?.toString() ?? json['id']?.toString() ?? '',
      peerName: resolvedName,
      firstName: fName,
      lastName: lName,
      company: (json['company_name'] ?? json['company'] ?? '').toString().trim(),
      designation: json['designation'] as String?,
      circleName: (json['circle_name'] ?? json['circle'])?.toString().trim(),
      circleId: json['circle_id']?.toString(),
      profilePhotoUrl: (json['profile_photo_url'] ?? json['avatar_url'])?.toString(),
      date: (json['date_formatted'] ?? json['date'] ?? '').toString().trim(),
      day: json['day']?.toString(),
      month: json['month']?.toString(),
      type: type,
      milestone: json['milestone'] as String?,
      isToday: json['is_today'] as bool? ?? false,
      wished: json['wished'] as bool? ?? false,
    );
  }

  CelebrationModel copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? firstName,
    String? lastName,
    String? company,
    String? designation,
    String? circleName,
    String? circleId,
    String? profilePhotoUrl,
    String? date,
    String? day,
    String? month,
    String? type,
    String? milestone,
    bool? isToday,
    bool? wished,
  }) {
    return CelebrationModel(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      circleName: circleName ?? this.circleName,
      circleId: circleId ?? this.circleId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      date: date ?? this.date,
      day: day ?? this.day,
      month: month ?? this.month,
      type: type ?? this.type,
      milestone: milestone ?? this.milestone,
      isToday: isToday ?? this.isToday,
      wished: wished ?? this.wished,
    );
  }

  /// Converts the celebration entry into a full PeerModel to support opening PeerProfileView seamlessly.
  PeerModel toPeerModel() {
    String inits = 'P';
    final parts = peerName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      inits = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      inits = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return PeerModel(
      id: peerId.isNotEmpty ? peerId : id,
      initials: inits,
      name: peerName,
      company: company,
      designation: designation,
      circle: circleName ?? '',
      circleId: circleId,
      location: '',
      tags: '',
      impactCount: 0,
      dealsFormatted: '',
      coins: 0,
      attendance: '',
      avatarUrl: profilePhotoUrl,
      status: 'Active',
      birthday: type == 'birthday' ? date : null,
      anniversary: type == 'anniversary' ? date : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'peer_id': peerId,
        'name': peerName,
        'first_name': firstName,
        'last_name': lastName,
        'company_name': company,
        'designation': designation,
        'circle_name': circleName,
        'circle_id': circleId,
        'profile_photo_url': profilePhotoUrl,
        'date_formatted': date,
        'day': day,
        'month': month,
        'type': type,
        'milestone': milestone,
        'is_today': isToday,
        'wished': wished,
      };
}

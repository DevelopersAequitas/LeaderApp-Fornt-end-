/// Model representing a celebration (birthday or anniversary) for a peer.
class CelebrationModel {
  final String peerId;
  final String peerName;
  final String company;
  final String date;
  final String type; // "birthday" or "anniversary"
  final bool isToday;

  const CelebrationModel({
    this.peerId = '',
    required this.peerName,
    required this.company,
    required this.date,
    required this.type,
    this.isToday = false,
  });

  factory CelebrationModel.fromJson(Map<String, dynamic> json, String type) {
    return CelebrationModel(
      peerId: json['peer_id']?.toString() ?? json['id']?.toString() ?? '',
      peerName: json['name'] as String? ?? json['peer_name'] as String? ?? '',
      company: json['company'] as String? ?? '',
      date: json['date_formatted'] as String? ?? json['date'] as String? ?? '',
      type: type,
      isToday: json['is_today'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'peer_id': peerId,
        'name': peerName,
        'company': company,
        'date_formatted': date,
        'type': type,
        'is_today': isToday,
      };
}

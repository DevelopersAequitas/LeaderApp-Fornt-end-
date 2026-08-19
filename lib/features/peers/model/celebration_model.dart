/// Model representing a celebration (birthday or anniversary) for a peer.
class CelebrationModel {
  final String peerName;
  final String company;
  final String date;
  final String type; // "birthday" or "anniversary"

  const CelebrationModel({
    required this.peerName,
    required this.company,
    required this.date,
    required this.type,
  });
}

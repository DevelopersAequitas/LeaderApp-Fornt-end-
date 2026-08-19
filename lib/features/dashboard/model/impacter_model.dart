/// Model representing a top impacter peer in the active circle.
class ImpacterModel {
  /// Rank position (1 to 5).
  final int rank;

  /// Full name of the impacter.
  final String name;

  /// Display initials for avatar.
  final String initials;

  /// Associated company name.
  final String company;

  /// Circle location name.
  final String location;

  /// Count of lives impacted.
  final int lives;

  /// Total coin score.
  final int coins;

  const ImpacterModel({
    required this.rank,
    required this.name,
    required this.initials,
    required this.company,
    required this.location,
    required this.lives,
    required this.coins,
  });
}

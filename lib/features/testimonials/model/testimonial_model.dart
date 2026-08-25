/// Model representing a peer testimonial endorsement.
class TestimonialModel {
  final String id;
  final String fromName;
  final String toName;
  final String fromCompany;
  final String toCompany;
  final String fromInitials;
  final int rating;
  final String content;
  final String date;

  const TestimonialModel({
    required this.id,
    required this.fromName,
    required this.toName,
    required this.fromCompany,
    required this.toCompany,
    required this.fromInitials,
    required this.rating,
    required this.content,
    required this.date,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    final fromName = json['author_name'] as String? ?? json['from_name'] as String? ?? 'Peer';
    final nameParts = fromName.split(' ');
    final fromInitials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : fromName.substring(0, fromName.length >= 2 ? 2 : 1).toUpperCase();

    return TestimonialModel(
      id: json['id']?.toString() ?? '',
      fromName: fromName,
      toName: json['target_peer_name'] as String? ?? json['to_name'] as String? ?? '',
      fromCompany: json['author_role'] as String? ?? json['from_company'] as String? ?? '',
      toCompany: json['circle_name'] as String? ?? json['to_company'] as String? ?? '',
      fromInitials: fromInitials,
      rating: json['rating'] as int? ?? 5,
      content: json['content'] as String? ?? '',
      date: json['date'] as String? ?? json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_name': fromName,
        'target_peer_name': toName,
        'author_role': fromCompany,
        'circle_name': toCompany,
        'rating': rating,
        'content': content,
        'date': date,
      };
}

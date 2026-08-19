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
}

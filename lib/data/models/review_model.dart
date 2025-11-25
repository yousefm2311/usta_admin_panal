class ReviewModel {
  final String text;
  final double rating;
  final String customer;
  final String artisan;
  final DateTime date;

  const ReviewModel({
    required this.text,
    required this.rating,
    required this.customer,
    required this.artisan,
    required this.date,
  });
}

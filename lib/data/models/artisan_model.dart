class ArtisanModel {
  final String name;
  final String category;
  final double rating;
  final String status;
  final int completed;
  final List<String> documents;

  const ArtisanModel({
    required this.name,
    required this.category,
    required this.rating,
    required this.status,
    required this.completed,
    this.documents = const [],
  });
}

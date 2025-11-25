class AdminUserModel {
  final String name;
  final String email;
  final String avatarUrl;

  const AdminUserModel({
    required this.name,
    required this.email,
    this.avatarUrl = '',
  });
}

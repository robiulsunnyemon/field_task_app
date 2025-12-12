
class User {
  final String id;
  final String firstName;
  final String? lastName;

  User({required this.id, required this.firstName, this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'] ?? 'N/A',
      lastName: json['last_name'],
    );
  }

  String get fullName => '$firstName ${lastName != 'null' ? lastName ?? '' : ''}'.trim();
}
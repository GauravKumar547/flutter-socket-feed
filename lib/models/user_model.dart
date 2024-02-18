class User {
  final String id;
  final String username;

  User({
    required this.id,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
    };
  }
}

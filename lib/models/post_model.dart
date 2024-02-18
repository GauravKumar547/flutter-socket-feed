class Post {
  final String userId;
  final String username;
  final String description;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final String id;

  Post(
      {required this.userId,
      required this.username,
      required this.description,
      required this.likes,
      required this.id,
      required this.comments});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['user_id'] as String,
      id: json['_id'] as String,
      username: json['username'] as String,
      description: json['description'] as String,
      likes: json['likes'] as List<dynamic>,
      comments: json['comments'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'username': username,
      'description': description,
      'likes': likes,
      'comments': comments,
    };
  }
}

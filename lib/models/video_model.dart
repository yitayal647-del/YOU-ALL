class Video {
  final String id;
  final String creatorId;
  final String creatorPhone;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int likes;
  final int views;
  final DateTime createdAt;
  bool isLikedByCurrentUser;

  Video({
    required this.id,
    required this.creatorId,
    required this.creatorPhone,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.likes = 0,
    this.views = 0,
    required this.createdAt,
    this.isLikedByCurrentUser = false,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      creatorPhone: json['creatorPhone'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorPhone': creatorPhone,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'likes': likes,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
      'isLikedByCurrentUser': isLikedByCurrentUser,
    };
  }
}

class VendorReview {
  final String id;
  final String vendorId;
  final String userId;
  final String? userName;
  final String? userPhoto;
  final int rating;
  final String comment;
  final DateTime createdAt;

  VendorReview({
    required this.id,
    required this.vendorId,
    required this.userId,
    this.userName,
    this.userPhoto,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory VendorReview.fromJson(Map<String, dynamic> json) {
    return VendorReview(
      id: json['_id'] ?? json['id'] ?? '',
      vendorId: json['vendorId'] ?? json['vendor_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      userName: json['userName'] ?? json['user_name'],
      userPhoto: json['userPhoto'] ?? json['user_photo'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vendorId': vendorId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

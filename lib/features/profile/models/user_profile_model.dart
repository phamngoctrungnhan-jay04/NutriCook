import 'package:cloud_firestore/cloud_firestore.dart';

/// Hồ sơ người dùng, lưu tại `users/{uid}` (DATABASE_DESIGN.md mục 3.1).
class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    required this.email,
    this.name = '',
    this.height,
    this.currentWeight,
    this.targetWeight,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String email;
  final String name;
  final double? height;

  /// Cân nặng hiện tại — khác `targetWeight` (mục tiêu). Bổ sung để tính BMI
  /// chính xác (BMI của mục tiêu không có ý nghĩa như BMI của tình trạng hiện tại).
  final double? currentWeight;
  final double? targetWeight;

  /// Download URL của ảnh đại diện trên Cloud Storage (`avatars/{uid}.jpg`) —
  /// null nghĩa là chưa tải ảnh lên, UI fallback về avatar chữ cái đầu tên.
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// [uid] truyền riêng vì đây là Document ID (= Firebase Auth UID).
  factory UserProfileModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfileModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      height: (map['height'] as num?)?.toDouble(),
      currentWeight: (map['currentWeight'] as num?)?.toDouble(),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      avatarUrl: map['avatarUrl'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'height': height,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserProfileModel copyWith({
    String? name,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}

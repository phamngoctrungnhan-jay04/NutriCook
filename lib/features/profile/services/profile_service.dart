import 'package:cloud_firestore/cloud_firestore.dart';

import '../dtos/update_profile_request_dto.dart';
import '../models/user_profile_model.dart';

/// Service duy nhất chạm Firestore cho dữ liệu Profile (`users/{uid}`). Profile
/// không có Repository riêng — gọi thẳng Service (đúng SYSTEM_ARCHITECTURE.md,
/// Profile chỉ có 1 nguồn dữ liệu, không cần điều phối/Transaction).
class ProfileService {
  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<UserProfileModel?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserProfileModel.fromMap(uid, data);
  }

  Future<void> updateProfile(String uid, UpdateProfileRequestDto request) {
    return _firestore.collection('users').doc(uid).update(request.toMap());
  }
}

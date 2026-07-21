import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Service duy nhất chạm Cloud Storage — upload ảnh đại diện, trả về download URL.
class AvatarStorageService {
  AvatarStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Lưu tại `avatars/{uid}.jpg` — ghi đè ảnh cũ nếu đã có (không tích lũy file rác).
  Future<String> uploadAvatar(String uid, File file) async {
    final ref = _storage.ref().child('avatars').child('$uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}

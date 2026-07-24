import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../dtos/update_profile_request_dto.dart';
import '../models/user_profile_model.dart';
import '../services/avatar_storage_service.dart';
import '../services/profile_service.dart';

/// Pattern trạng thái thống nhất theo SYSTEM_ARCHITECTURE.md mục 9.
enum ProfileStatus { idle, loading, success, error }

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required ProfileService profileService,
    required AvatarStorageService avatarStorageService,
    FirebaseAuth? firebaseAuth,
  })  : _service = profileService,
        _avatarStorageService = avatarStorageService,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final ProfileService _service;
  final AvatarStorageService _avatarStorageService;
  final FirebaseAuth _firebaseAuth;

  ProfileStatus _status = ProfileStatus.idle;
  UserProfileModel? _profile;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  ProfileStatus get status => _status;
  UserProfileModel? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isUploadingAvatar => _isUploadingAvatar;

  /// BMI = cân nặng hiện tại (kg) / chiều cao(m)^2 — null nếu thiếu dữ liệu.
  /// Chỉ mang tính tham khảo chung, không phải tư vấn y tế.
  double? get bmi {
    final height = _profile?.height;
    final weight = _profile?.currentWeight;
    if (height == null || weight == null || height <= 0) return null;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Future<void> loadProfile() async {
    final uid = _uid;
    if (uid == null) return;

    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _service.getProfile(uid);
      if (profile == null) {
        _status = ProfileStatus.error;
        _errorMessage = 'User profile not found.';
        notifyListeners();
        return;
      }
      _profile = profile;
      _status = ProfileStatus.success;
      notifyListeners();
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = 'Failed to load profile, please try again.';
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    double? height,
    double? currentWeight,
    double? targetWeight,
  }) async {
    final uid = _uid;
    if (uid == null) return false;

    final request = UpdateProfileRequestDto(
      name: name,
      height: height,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
    );
    final errors = request.validate();
    if (errors.isNotEmpty) {
      _errorMessage = errors.first;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateProfile(uid, request);
      final current = _profile;
      if (current != null) {
        _profile = current.copyWith(
          name: name,
          height: height,
          currentWeight: currentWeight,
          targetWeight: targetWeight,
          updatedAt: DateTime.now(),
        );
      }
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'Failed to save profile, please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Upload ảnh đại diện mới lên Cloud Storage, rồi lưu download URL vào Firestore.
  Future<bool> uploadAvatar(File file) async {
    final uid = _uid;
    if (uid == null) return false;

    _isUploadingAvatar = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final avatarUrl = await _avatarStorageService.uploadAvatar(uid, file);
      await _service.updateProfile(uid, UpdateProfileRequestDto(avatarUrl: avatarUrl));

      final current = _profile;
      if (current != null) {
        _profile = current.copyWith(avatarUrl: avatarUrl, updatedAt: DateTime.now());
      }
      _isUploadingAvatar = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploadingAvatar = false;
      _errorMessage = 'Failed to upload avatar, please try again.';
      notifyListeners();
      return false;
    }
  }
}

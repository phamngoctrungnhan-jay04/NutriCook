/// Request DTO cho "Update Profile" (API_DESIGN.md mục Profile #2).
///
/// Cả 5 field đều nullable vì API cho phép cập nhật MỘT PHẦN (chỉ gửi field
/// thay đổi) — field null nghĩa là "không đổi", không phải "xóa giá trị".
class UpdateProfileRequestDto {
  const UpdateProfileRequestDto({
    this.name,
    this.height,
    this.currentWeight,
    this.targetWeight,
    this.avatarUrl,
  });

  final String? name;
  final double? height;
  final double? currentWeight;
  final double? targetWeight;
  final String? avatarUrl;

  /// Validation theo BR-04: chiều cao/cân nặng phải là số dương; chỉ validate
  /// field nào thực sự được gửi (khác null).
  List<String> validate() {
    final errors = <String>[];

    if (name != null && name!.trim().isEmpty) {
      errors.add('Tên không được để trống.');
    }
    if (height != null && height! <= 0) {
      errors.add('Chiều cao phải là số dương.');
    }
    if (currentWeight != null && currentWeight! <= 0) {
      errors.add('Cân nặng hiện tại phải là số dương.');
    }
    if (targetWeight != null && targetWeight! <= 0) {
      errors.add('Cân nặng mục tiêu phải là số dương.');
    }

    return errors;
  }

  /// Mapping Rule: chỉ đưa vào map những field khác null, để dùng trực tiếp
  /// cho FirestoreService.update(...) — không ghi đè field không thay đổi.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (height != null) map['height'] = height;
    if (currentWeight != null) map['currentWeight'] = currentWeight;
    if (targetWeight != null) map['targetWeight'] = targetWeight;
    if (avatarUrl != null) map['avatarUrl'] = avatarUrl;
    return map;
  }
}

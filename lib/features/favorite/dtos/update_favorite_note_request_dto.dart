/// Request DTO cho "Update Favorite Note" (API_DESIGN.md mục Favorite #5).
class UpdateFavoriteNoteRequestDto {
  const UpdateFavoriteNoteRequestDto({required this.note});

  final String note;

  /// Giới hạn độ dài theo đề xuất ở BUSINESS_FLOW.md (tránh document Firestore
  /// phình to không cần thiết).
  static const int maxLength = 500;

  List<String> validate() {
    if (note.length > maxLength) {
      return ['Ghi chú không được vượt quá $maxLength ký tự.'];
    }
    return const [];
  }

  /// Mapping Rule: dùng thẳng cho FirestoreService.update({'note': ...}).
  Map<String, dynamic> toMap() => {'note': note};
}

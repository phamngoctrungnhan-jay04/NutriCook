/// Ngưỡng responsive theo UI_UX_GUIDELINES.md mục Grid System / Responsive Strategy.
///
/// MVP chỉ nhắm Mobile — breakpoint dưới đây chỉ để co giãn nhẹ số cột GridView
/// trên các màn hình lớn (ví dụ máy gập), không phục vụ layout Tablet/Desktop riêng.
class AppBreakpoints {
  const AppBreakpoints._();

  /// Ngưỡng chuyển từ điện thoại thông thường sang màn hình lớn.
  static const double compact = 600;

  static bool isCompact(double width) => width < compact;

  /// Số cột GridView món ăn: 2 cột mặc định, 3 cột nếu chiều rộng vượt ngưỡng lớn.
  static int mealGridColumns(double width) => isCompact(width) ? 2 : 3;
}

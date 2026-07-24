# UI_UX_GUIDELINES.md — NutriCook (PRM393)

Tài liệu này quy định ngôn ngữ thiết kế (design language) cho toàn bộ ứng dụng NutriCook, dựa trên `PROJECT_REQUIREMENTS.md` (đặc biệt là Pain Points: "tập trung, không quảng cáo", "tối ưu khi đang nấu bếp", "theo dõi sức khỏe chủ động") và tuân thủ tinh thần MVP/không over-engineering của `PROJECT_GUIDELINES.md`. Không chứa code Flutter — chỉ mô tả quy tắc thiết kế để áp dụng nhất quán khi implement.

---

## Design Style

- **Phong cách tổng thể:** Clean & Modern, tối giản (minimalist), lấy cảm hứng từ Material Design 3 (Material You) — vì đây là ngôn ngữ thiết kế mặc định, dễ triển khai nhất trên Flutter, tài liệu phong phú, phù hợp MVP.
- **Cảm xúc thiết kế cần truyền tải:** ấm áp, ngon miệng, đáng tin cậy (gợi cảm giác thực phẩm tươi/lành mạnh), nhưng vẫn gọn gàng, không rối mắt — đúng với pain point "trải nghiệm tinh gọn, tập trung hoàn toàn vào việc nấu ăn" đã nêu trong yêu cầu dự án.
- **Ưu tiên nội dung hơn trang trí:** hình ảnh món ăn là trọng tâm thị giác chính trên mọi màn hình danh sách; UI chrome (viền, nền, khung) phải lùi lại làm nền cho ảnh món ăn, không cạnh tranh sự chú ý.
- **Nhất quán:** mọi màn hình dùng chung một bộ token thiết kế (màu, spacing, typography, bo góc) định nghĩa trong tài liệu này — không tự sáng tạo giá trị mới ở từng màn hình riêng lẻ.

---

## Color Palette

Palette lấy tông màu ấm, gợi thực phẩm/sức khỏe, có đủ độ tương phản để dùng tốt cả Light/Dark mode.

| Vai trò | Light Mode | Dark Mode | Ghi chú |
|---|---|---|---|
| **Primary** | Cam đất ấm (warm orange, ví dụ tông `#E8622C` – `#FF7A45`) | Cùng tông nhưng giảm độ chói (~10-15%) | Dùng cho nút hành động chính, icon yêu thích khi active, tab đang chọn. Gợi cảm giác "ngon miệng" mà không chọn đỏ (dễ liên tưởng cảnh báo/lỗi). |
| **Secondary** | Xanh lá tự nhiên (fresh green, ví dụ `#4C9A6A`) | Sáng hơn một chút để nổi trên nền tối | Dùng cho biểu tượng liên quan sức khỏe/dinh dưỡng (calo, chỉ số cơ thể), trạng thái thành công. |
| **Background** | Trắng ngà / xám rất nhạt (`#FAFAF7`) | Xám than đậm (`#121212` theo chuẩn Material Dark), không dùng đen tuyệt đối | Đen tuyệt đối gây chói tương phản khó chịu khi dùng lâu trong bếp tối. |
| **Surface (Card/Sheet)** | Trắng thuần (`#FFFFFF`) | Xám đậm hơn nền một bậc (`#1E1E1E`) | Tạo phân lớp (elevation) rõ ràng giữa nền và các khối nội dung. |
| **Error** | Đỏ chuẩn Material (`#BA1A1A`) | Đỏ nhạt hơn để không chói (`#FFB4AB`) | Dùng riêng biệt cho trạng thái lỗi, không trộn với Primary. |
| **Text Primary** | Gần đen (`#1B1B1B`) | Trắng ngà (`#F2F2F2`) | Đảm bảo tỷ lệ tương phản ≥ 4.5:1 theo WCAG AA. |
| **Text Secondary** | Xám trung (`#6B6B6B`) | Xám sáng (`#A8A8A8`) | Dùng cho caption, mô tả phụ, timestamp. |
| **Divider/Border** | Xám rất nhạt (`#E4E4E0`) | Xám đậm (`#2C2C2C`) | Dùng tối thiểu, ưu tiên spacing/elevation hơn đường kẻ. |

**Nguyên tắc dùng màu:**
- Không dùng quá 2 màu chủ đạo (Primary + Secondary) cho hành động; mọi màu khác chỉ đóng vai trò nền/văn bản/trạng thái.
- Màu Error chỉ dùng cho lỗi thật (không dùng đỏ cho mục đích trang trí).
- Icon "Yêu thích" (trái tim) dùng Primary khi active, Text Secondary khi inactive — không dùng đỏ mặc định của hệ thống để tránh xung đột với màu Error.

---

## Typography

- **Font:** dùng font hệ thống mặc định theo nền tảng (Roboto trên Android, San Francisco trên iOS) thông qua theme mặc định của Flutter — không nhúng custom font riêng cho MVP để giảm dung lượng app và độ phức tạp cấu hình (đúng tinh thần KISS).
- **Thang chữ (type scale), theo tinh thần Material 3:**

| Style | Kích thước | Trọng lượng | Dùng cho |
|---|---|---|---|
| Display / Headline | 24–28sp | Bold (700) | Tên món ăn ở Detail Screen, tiêu đề màn hình lớn |
| Title | 18–20sp | SemiBold (600) | Tiêu đề section (ví dụ "Nguyên liệu", "Các bước thực hiện"), tên món trong Card |
| Body | 14–16sp | Regular (400) | Nội dung chính: mô tả, ghi chú, danh sách nguyên liệu |
| Label / Caption | 12sp | Medium (500) | Nhãn phụ, timestamp, số calo nhỏ dưới ảnh |
| Button Text | 14–16sp | SemiBold (600) | Chữ trên nút hành động |

- **Line-height:** tối thiểu 1.4× kích thước chữ cho Body text, đảm bảo dễ đọc khi lướt danh sách công thức dài.
- Không dùng quá 3 cấp độ trọng lượng chữ (Regular/Medium/SemiBold/Bold) trong cùng một màn hình để tránh rối mắt.

---

## Spacing

Dùng hệ thống spacing theo bội số của **4px** (chuẩn phổ biến, dễ tính toán, khớp lưới Material):

| Token | Giá trị | Dùng cho |
|---|---|---|
| `spacing-xs` | 4px | Khoảng cách giữa icon và text sát nhau |
| `spacing-sm` | 8px | Khoảng cách trong nội bộ 1 component nhỏ (icon + label) |
| `spacing-md` | 16px | Padding mặc định cho Card, khoảng cách giữa các thành phần trong 1 section |
| `spacing-lg` | 24px | Khoảng cách giữa các section khác nhau trên cùng màn hình |
| `spacing-xl` | 32px | Padding tổng thể màn hình (top/bottom của scroll content), khoảng cách trước nhóm nội dung lớn |

- Padding ngang mặc định của màn hình: `16px` (đảm bảo nội dung không dính sát mép, phù hợp thao tác một tay trong bếp).
- Không dùng giá trị spacing tùy tiện ngoài bảng trên (ví dụ 13px, 22px) — mọi khoảng cách phải quy về token gần nhất.

---

## Grid System

- Dùng lưới **cột linh hoạt theo breakpoint**, không dùng lưới 12 cột phức tạp kiểu web — vì phạm vi MVP chỉ nhắm Mobile (theo `PROJECT_REQUIREMENTS.md`, Constraints).
- **Danh sách món ăn (Home/Search/Filter):** GridView 2 cột trên điện thoại thông thường (độ rộng màn hình < 600dp), khoảng cách giữa các item = `spacing-md` (16px).
- **Danh sách dạng thẳng (Favorite List):** 1 cột, mỗi item chiếm toàn bộ chiều rộng khả dụng (trừ padding màn hình).
- **Meal Detail:** bố cục 1 cột dọc — ảnh full-width trên cùng, sau đó các section xếp chồng (thông tin cơ bản → nguyên liệu → các bước) theo dạng Tab hoặc Scroll liên tục (theo mô tả "Tab nguyên liệu riêng, Tab các bước riêng" trong `PROJECT_REQUIREMENTS.md`).
- Tỷ lệ ảnh món ăn trong Card: cố định **4:3** hoặc **1:1**, nhất quán trên toàn bộ danh sách để lưới không bị lệch dòng.

---

## Icon Style

- **Bộ icon:** dùng Material Symbols/Icons (outlined style làm mặc định, filled style cho trạng thái active) — có sẵn trong Flutter, không cần thêm icon pack ngoài cho MVP.
- **Kích thước chuẩn:** 24px cho icon trong AppBar/BottomNavigation/nút hành động; 20px cho icon phụ trợ trong text (ví dụ icon đồng hồ cạnh thời gian nấu, icon lửa cạnh calo).
- **Trạng thái:** icon outline = trạng thái mặc định/chưa chọn; icon filled + màu Primary = trạng thái active/đã chọn (ví dụ icon trái tim, icon tab đang chọn ở Bottom Navigation).
- Không trộn lẫn nhiều style icon (line-art từ nguồn khác, icon 3D...) trong cùng ứng dụng — phá vỡ tính nhất quán.

---

## Border Radius

| Component | Bán kính bo góc |
|---|---|
| Button | 12px (bo tròn vừa phải, không bo hoàn toàn thành pill trừ khi là nút dạng Chip) |
| Card (Meal Card, Favorite Item) | 16px |
| TextField | 12px |
| Dialog / Bottom Sheet | 20px (riêng góc trên nếu là Bottom Sheet) |
| Chip (category filter) | Bo tròn hoàn toàn (pill shape, radius = chiều cao/2) |
| Ảnh trong Card | Kế thừa theo radius của Card chứa nó (16px), không bo riêng khác biệt |

Nguyên tắc: bán kính tăng dần theo cấp độ "nổi bật/nổi khối" của component (Dialog nổi nhất → bo lớn nhất); giữ tối đa 3 giá trị radius khác nhau trong toàn app để tránh rối.

---

## Shadow

- Dùng **elevation tối giản** theo tinh thần Material 3 — ưu tiên phân lớp bằng màu Surface khác biệt (xem Color Palette) hơn là đổ bóng đậm.
- **Card (Meal Card, Favorite Item):** shadow rất nhẹ, `blur ~8px`, `opacity ~6-8%`, màu đen trung tính — đủ để tách khỏi nền, không tạo cảm giác nặng nề.
- **AppBar khi cuộn (scrolled):** elevation nhẹ xuất hiện khi nội dung cuộn lên dưới AppBar, biến mất khi ở đầu trang (dynamic elevation) — giúp phân định ranh giới mà không cần đường kẻ cứng.
- **Dialog/Bottom Sheet:** shadow rõ hơn Card một chút (`blur ~16px`, `opacity ~12%`) để nhấn mạnh lớp nổi trên cùng.
- **Dark Mode:** giảm shadow tối đa (gần như không dùng), thay bằng chênh lệch màu Surface — shadow đen trên nền tối gần như vô hình và gây lãng phí hiệu năng.

---

## Button Design

- **Primary Button** (hành động chính: Đăng nhập, Lưu, Đăng ký...): nền màu Primary, chữ trắng, bo góc 12px, chiều cao tối thiểu 48px (đảm bảo vùng chạm ≥ 48dp theo chuẩn accessibility), full-width trong các form quan trọng.
- **Secondary/Outlined Button** (hành động phụ: Hủy, Quay lại): viền màu Primary, nền trong suốt, chữ màu Primary.
- **Text Button** (hành động ít quan trọng nhất: "Quên mật khẩu?", "Chưa có tài khoản? Đăng ký"): không nền, không viền, chỉ có chữ màu Primary.
- **Icon Button** (nút trái tim, nút back, nút search): vùng chạm tối thiểu 44×44dp dù icon hiển thị nhỏ hơn, có hiệu ứng ripple/feedback khi nhấn.
- **Trạng thái Disabled:** giảm opacity nền/chữ xuống ~38%, không đổi màu sang xám riêng biệt (giữ tông Primary nhưng nhạt) — nhất quán với Material 3.
- **Trạng thái Loading trên nút** (ví dụ khi đang submit đăng nhập): thay label bằng spinner nhỏ (kích thước ~20px) căn giữa, giữ nguyên kích thước nút, vô hiệu hóa thao tác lặp lại trong lúc chờ.

---

## TextField Design

- **Kiểu:** Outlined TextField (viền mảnh, không dùng kiểu underline hoặc filled đậm) — rõ ràng, dễ nhận biết vùng nhập trên mọi nền màu.
- **Bo góc:** 12px, viền mặc định màu Divider, viền màu Primary khi focus, viền màu Error khi có lỗi validation.
- **Label:** dùng floating label (label thu nhỏ lên trên viền khi field có nội dung/focus) — tiết kiệm không gian, không cần thêm placeholder trùng lặp.
- **Validation error:** hiển thị message lỗi ngay dưới field bằng màu Error, font Caption (12sp), kèm đổi màu viền field sang Error — người dùng thấy phản hồi tức thời mà không cần chờ submit toàn form.
- **Password field:** luôn có icon toggle ẩn/hiện mật khẩu ở cuối field.
- **Padding nội bộ:** tối thiểu 16px ngang, 12–14px dọc, đảm bảo dễ chạm và dễ đọc.

---

## Card Design

- **Meal Card (Home/Search/Filter):** ảnh món ăn chiếm phần trên (tỷ lệ 4:3 hoặc 1:1), tên món bên dưới (Title style, tối đa 2 dòng, overflow ellipsis), có thể thêm badge nhỏ (calo ước tính) ở góc ảnh nếu dữ liệu sẵn có. Toàn bộ Card có thể nhấn (tap toàn vùng, không chỉ riêng ảnh).
- **Favorite List Item:** dạng hàng ngang — ảnh thumbnail nhỏ bên trái (kích thước cố định, ví dụ 72×72px, bo góc 12px), tên món + ghi chú rút gọn (nếu có) bên phải, hỗ trợ thao tác vuốt để lộ nút xóa (swipe-to-delete).
- **Elevation:** dùng shadow nhẹ theo mục Shadow ở trên; không viền cứng bao quanh Card (border) trừ khi ở trạng thái selected/pressed.
- **Khoảng cách nội dung trong Card:** padding `spacing-md` (16px) giữa mép Card và nội dung text.

---

## Bottom Navigation

- **Số lượng tab:** 3 tab chính, khớp đúng cấu trúc điều hướng MVP: **Home** (bao gồm Search/Filter) — **Favorite** — **Profile**.
- **Kiểu hiển thị:** icon + label text hiển thị đồng thời cho cả tab active lẫn inactive (không ẩn label ở tab chưa chọn) — ưu tiên rõ ràng, dễ dùng hơn là tối giản quá mức, phù hợp người dùng phổ thông.
- **Trạng thái active:** icon dạng filled + màu Primary + label cùng màu; trạng thái inactive: icon outline + màu Text Secondary.
- **Chiều cao:** tuân theo chuẩn Material (khoảng 80px bao gồm safe area dưới), nền dùng màu Surface, có elevation nhẹ tách khỏi nội dung phía trên.

---

## AppBar

- **Chiều cao chuẩn:** theo Material default (56dp), không tùy biến quá cao gây chiếm dụng không gian màn hình nhỏ.
- **Home:** AppBar tối giản, có thể chỉ chứa tên app/logo nhỏ + icon search (điều hướng tới ô tìm kiếm) — tránh nhồi nhét nhiều icon.
- **Meal Detail:** AppBar trong suốt/overlay lên ảnh món ăn ở phần đầu, chuyển thành nền Surface đặc khi người dùng cuộn xuống — tăng diện tích hiển thị ảnh mà vẫn giữ nút back rõ ràng.
- **Favorite/Profile:** AppBar tiêu chuẩn có tiêu đề rõ ràng ("Yêu thích", "Hồ sơ"), căn trái theo chuẩn Material 3 (không căn giữa).
- Không đặt quá 2 icon hành động (actions) bên phải AppBar để tránh rối; nếu cần nhiều hành động hơn, gộp vào menu ba chấm (overflow menu).

---

## Dialog

- Dùng cho các hành động cần xác nhận rõ ràng, có tính phá hủy hoặc quan trọng (ví dụ: xác nhận Đăng xuất). Với thao tác xóa Favorite đơn lẻ, ưu tiên **swipe-to-delete kèm Snackbar Undo** thay vì Dialog xác nhận, để giữ trải nghiệm nhanh gọn khi đang nấu ăn (tránh làm gián đoạn luồng thao tác một tay).
- **Cấu trúc chuẩn:** Tiêu đề ngắn gọn (Title style) → Nội dung mô tả ngắn (Body style, tối đa 2 dòng) → 2 nút hành động (Cancel dạng Text Button bên trái, hành động chính dạng Primary/Outlined Button bên phải).
- **Bo góc:** 20px, nền Surface, shadow theo mục Shadow, có lớp overlay mờ (scrim) phía sau để tập trung sự chú ý vào Dialog.
- Không dùng Dialog cho việc hiển thị lỗi thông thường (dùng Snackbar) — chỉ dùng Dialog khi cần người dùng đưa ra quyết định (Yes/No) trước khi tiếp tục.

---

## Snackbar

- Dùng cho **phản hồi ngắn, không chặn luồng thao tác**: xác nhận "Đã lưu ghi chú", "Đã xóa khỏi yêu thích" (kèm nút Undo), thông báo lỗi mạng nhẹ.
- Vị trí: đáy màn hình, phía trên Bottom Navigation (không bị tab che khuất).
- Thời gian hiển thị mặc định: ~3 giây cho thông báo thường, có thể kéo dài hơn (~5 giây) nếu kèm hành động Undo.
- Snackbar báo lỗi dùng nền màu Error (hoặc icon cảnh báo màu Error trên nền Surface đậm), Snackbar xác nhận thành công dùng nền Surface trung tính kèm icon check màu Secondary — không lạm dụng màu Error cho mọi loại thông báo.
- Không hiển thị chồng nhiều Snackbar cùng lúc — Snackbar mới thay thế Snackbar cũ đang hiển thị.

---

## Loading

- **Loading toàn màn hình (lần đầu vào Home/Detail/Favorite):** dùng Skeleton Loading (khung xám nhấp nháy mô phỏng bố cục Card/List thật) thay vì spinner tròn đơn thuần — giúp người dùng cảm nhận tốc độ tải nhanh hơn và biết trước bố cục sắp hiển thị. Nếu thời gian triển khai MVP eo hẹp, có thể dùng `CircularProgressIndicator` màu Primary căn giữa màn hình như phương án tối giản chấp nhận được.
- **Loading cục bộ** (ví dụ đang lưu ghi chú, đang submit form): dùng spinner nhỏ trên chính nút hành động (xem mục Button Design) thay vì che phủ toàn màn hình.
- **Pull-to-refresh** (nếu áp dụng cho Home): dùng indicator mặc định của nền tảng (Material refresh indicator), màu Primary.
- Không hiển thị nhiều loading indicator chồng lấn cùng lúc trên một màn hình.

---

## Empty State

- Mọi danh sách có khả năng rỗng (Favorite chưa có món nào, Search không ra kết quả) phải có **Empty State thiết kế riêng**, không để trống trắng khó hiểu.
- **Cấu trúc chuẩn:** icon/illustration đơn giản (dùng icon outline lớn, ví dụ icon trái tim rỗng cho Favorite, icon kính lúp cho Search) → tiêu đề ngắn (Title style, ví dụ "Chưa có món ăn yêu thích") → mô tả phụ (Body/Caption, gợi ý hành động tiếp theo, ví dụ "Khám phá món ăn và nhấn ♥ để lưu vào đây").
- Màu sắc Empty State dùng tông trung tính (Text Secondary), không dùng Primary/Error để tránh gây cảm giác đây là lỗi.
- Với Search rỗng, có thể thêm nút "Xóa bộ lọc" hoặc "Quay lại trang chủ" nếu phù hợp ngữ cảnh.

---

## Error State

- Phân biệt rõ 3 cấp độ hiển thị lỗi tùy mức độ nghiêm trọng và phạm vi ảnh hưởng:
  1. **Lỗi toàn màn hình** (không tải được dữ liệu chính, ví dụ mất mạng khi vào Home lần đầu): hiển thị Error View full-content — icon cảnh báo, thông báo ngắn gọn thân thiện (không hiển thị mã lỗi kỹ thuật hay stack trace), kèm nút **"Thử lại"** (Primary/Outlined Button).
  2. **Lỗi cục bộ trên form** (validation input): hiển thị inline ngay dưới field liên quan (xem mục TextField Design), không dùng Dialog/Snackbar cho lỗi loại này.
  3. **Lỗi thao tác tạm thời** (submit thất bại, thêm/xóa favorite lỗi mạng): dùng Snackbar (xem mục Snackbar), không chuyển toàn màn hình sang Error View vì dữ liệu chính vẫn đang hiển thị bình thường.
- Ngôn ngữ thông báo lỗi: luôn dùng câu thân thiện, hướng dẫn hành động tiếp theo (ví dụ "Không thể tải danh sách món ăn. Vui lòng kiểm tra kết nối và thử lại." thay vì "Error: SocketException").

---

## Dark Mode Strategy

- **Hỗ trợ đầy đủ cả Light và Dark Mode** ngay từ MVP, tự động theo cài đặt hệ thống (`ThemeMode.system`) — không cung cấp công tắc chuyển đổi thủ công riêng trong app để giữ đơn giản (có thể bổ sung sau nếu cần).
- Toàn bộ màu sắc phải định nghĩa qua token semantic (Primary, Surface, Background, Text Primary/Secondary...) như bảng ở mục Color Palette — **không hard-code** giá trị màu cụ thể (hex) rải rác trong từng màn hình, để đảm bảo đổi theme tự động đúng.
- Ảnh món ăn (từ TheMealDB) giữ nguyên không chỉnh màu theo theme — chỉ nền/UI chrome xung quanh đổi theo Dark/Light.
- Kiểm tra tương phản text/nền đạt chuẩn WCAG AA (≥4.5:1) ở cả hai chế độ trước khi hoàn thiện từng màn hình.

---

## Animation Guidelines

- **Nguyên tắc:** animation phục vụ chức năng (feedback, định hướng), không phải trang trí thuần túy — giữ tinh thần "tập trung vào nấu ăn", không làm chậm thao tác người dùng.
- **Thời lượng chuẩn:** 150–250ms cho hầu hết transition (chuyển màn hình, mở/đóng Dialog, expand/collapse); tránh animation kéo dài quá 300ms gây cảm giác chậm chạp.
- **Easing:** dùng easing chuẩn của Material (`easeInOut`/`standard curve`), không dùng easing kiểu "nảy" (bounce/elastic) trừ phi có lý do UX cụ thể (ví dụ hiệu ứng nhỏ khi nhấn tim yêu thích có thể dùng scale nảy nhẹ ~1.0 → 1.2 → 1.0 trong ~200ms để tạo cảm giác thỏa mãn khi thao tác).
- **Page transition:** dùng transition mặc định của nền tảng (slide từ phải sang trái trên Android/iOS theo chuẩn) — không tự chế transition phức tạp cho MVP.
- **Skeleton loading, Snackbar, swipe-to-delete:** đều có animation vào/ra mượt mà theo mặc định của widget nền tảng, không cần custom thêm.
- Tuyệt đối tránh animation lặp vô hạn gây xao nhãng (ví dụ icon nhấp nháy liên tục) ở các khu vực không phải trạng thái loading.

---

## Accessibility

- **Kích thước vùng chạm:** tối thiểu 44×44dp cho mọi phần tử có thể tương tác (nút, icon, item trong danh sách) — đặc biệt quan trọng vì use case chính là thao tác một tay trong bếp (có thể tay ướt/bẩn, cần vùng chạm rộng rãi, dễ trúng).
- **Tương phản màu:** tuân thủ WCAG AA (≥4.5:1 cho text thường, ≥3:1 cho text lớn/icon) ở cả Light và Dark Mode, đã nêu ở mục Color Palette/Dark Mode.
- **Không truyền tải thông tin chỉ bằng màu sắc:** ví dụ trạng thái lỗi trên TextField phải có cả đổi màu viền lẫn message text, không chỉ đổi màu (hỗ trợ người dùng mù màu).
- **Hỗ trợ Screen Reader:** mọi icon-only button (ví dụ icon trái tim, icon back) phải có label ngữ nghĩa (semantic label) mô tả đúng hành động ("Thêm vào yêu thích", "Quay lại") để TalkBack/VoiceOver đọc đúng.
- **Font scaling:** UI phải chịu được người dùng phóng to cỡ chữ hệ thống (tối thiểu đến 130%) mà không bị vỡ layout nghiêm trọng (tràn text, chồng chữ) — tránh cố định chiều cao cứng cho các vùng chứa text.
- **Trạng thái focus rõ ràng:** khi điều hướng bằng bàn phím ngoài/switch access (ít phổ biến trên mobile nhưng vẫn nên hỗ trợ cơ bản), phần tử đang focus phải có viền/hiệu ứng nhận biết được.

---

## Responsive Strategy

- **Phạm vi MVP chỉ nhắm Mobile** (theo `PROJECT_REQUIREMENTS.md`, Constraints) — không cần thiết kế riêng cho Tablet/Web/Desktop, nhưng layout nên dùng đơn vị tương đối (không hard-code px cứng theo một kích thước màn hình cụ thể) để tránh vỡ giao diện trên các độ phân giải điện thoại khác nhau (từ màn nhỏ ~360dp đến màn lớn ~430dp+).
- **GridView món ăn:** số cột co giãn nhẹ theo chiều rộng màn hình — mặc định 2 cột cho điện thoại thông thường, có thể tăng lên 3 cột nếu chiều rộng vượt ngưỡng lớn (ví dụ ≥600dp, trường hợp hiếm gặp ở điện thoại nhưng cần dự phòng cho máy màn hình lớn/gập).
- **Safe Area:** mọi màn hình phải tôn trọng notch/status bar/gesture bar của thiết bị (dùng `SafeArea` mặc định), đặc biệt quan trọng cho AppBar và Bottom Navigation.
- **Text overflow:** mọi text có độ dài không kiểm soát (tên món ăn, ghi chú cá nhân) phải có xử lý overflow rõ ràng (ellipsis, giới hạn số dòng) thay vì để tràn layout — đã nêu cụ thể ở mục Card Design.
- **Kiểm thử bắt buộc trên iOS Simulator** trước khi hoàn thiện (môi trường build/test chính thức theo `PROJECT_REQUIREMENTS.md` mục Constraints) để đảm bảo không tràn viền, không lỗi hiển thị, trên đủ các kích thước iPhone Simulator phổ biến (ví dụ iPhone SE — màn nhỏ, và iPhone Pro Max — màn lớn) để bù đắp phần nào cho việc không có thiết bị vật lý thật để kiểm tra cảm ứng/hiệu năng thực tế.

---

## Quy trình khi nhận UI tham khảo từ Internet (áp dụng cho các yêu cầu sau này)

Khi người dùng gửi ảnh/link UI tham khảo từ Internet để áp dụng vào dự án, AI phải tuân thủ quy trình sau:

1. **Phân tích trước khi áp dụng:** bóc tách UI tham khảo thành các thành phần thiết kế (màu chủ đạo, kiểu bố cục, kiểu Card/Button, mật độ thông tin, phong cách icon...) — không áp dụng "nguyên khối" ngay lập tức.
2. **Không copy 100%:** không sao chép y nguyên màu sắc, layout, hoặc thành phần đặc thù thương hiệu của nguồn tham khảo (đặc biệt nếu đó là UI của một sản phẩm thương mại có thể có bản quyền thiết kế) — chỉ rút ra **nguyên lý/phong cách** (ví dụ: "dùng Card bo góc lớn, ảnh full-bleed", "tông màu pastel ấm") để tham chiếu.
3. **Chuyển hóa theo ngôn ngữ thiết kế đã có của NutriCook:** ánh xạ phong cách mới vào đúng hệ token đã định nghĩa trong tài liệu này (Color Palette, Spacing, Border Radius...) — nếu phong cách tham khảo đòi hỏi thay đổi token nền tảng (ví dụ đổi hẳn tông màu chủ đạo), phải cập nhật lại chính tài liệu `UI_UX_GUIDELINES.md` này trước, không áp dụng riêng lẻ cho một màn hình rồi để các màn hình khác lệch pha.
4. **Giữ tính nhất quán toàn ứng dụng:** một thay đổi phong cách áp dụng cho 1 màn hình/module phải được cân nhắc lan tỏa hợp lý sang các màn hình liên quan (ví dụ nếu đổi kiểu Card ở Home, cần xem xét Favorite List có nên đồng bộ theo hay có lý do chính đáng để khác biệt) — tránh tình trạng mỗi màn hình một phong cách rời rạc.
5. **Ưu tiên khả năng triển khai thực tế trong Flutter với effort hợp lý cho MVP:** nếu UI tham khảo dùng hiệu ứng phức tạp (custom shader, animation nặng, illustration 3D...) vượt quá nhu cầu/nguồn lực MVP, AI phải đề xuất phương án đơn giản hóa tương đương thay vì cố sao chép chính xác, và nêu rõ sự đánh đổi đó cho người dùng biết trước khi triển khai.
6. **Báo cáo lại điểm khác biệt:** sau khi áp dụng, AI nên tóm tắt ngắn gọn UI tham khảo đã ảnh hưởng những gì cụ thể (màu, bố cục, component nào) và những gì đã được điều chỉnh/lược bỏ để phù hợp NutriCook, giúp người dùng dễ theo dõi quyết định thiết kế.

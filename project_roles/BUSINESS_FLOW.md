# BUSINESS_FLOW.md — NutriCook (PRM393)

Tài liệu này mô tả luồng nghiệp vụ (business flow) chi tiết cho từng chức năng của NutriCook, dựa trên `PROJECT_REQUIREMENTS.md` và tuân thủ kiến trúc trong `SYSTEM_ARCHITECTURE.md`. Đây là tài liệu tham chiếu nghiệp vụ, không chứa code.

Module **Admin** không được đưa vào tài liệu này vì đã được xác nhận **ngoài phạm vi MVP** (Out of Scope) trong `PROJECT_REQUIREMENTS.md` — không có yêu cầu nghiệp vụ nào cho vai trò này trong đề bài gốc.

---

# 1. Authentication

## Business Goal
Xác thực danh tính người dùng để bảo vệ dữ liệu cá nhân (favorites, profile), đảm bảo mỗi người dùng chỉ truy cập được dữ liệu của chính mình, và duy trì phiên đăng nhập để giảm ma sát khi sử dụng lại ứng dụng.

## Business Flow
1. Người dùng mở ứng dụng → hệ thống kiểm tra Auth State hiện tại.
2. Nếu chưa có phiên đăng nhập → hiển thị màn hình Đăng nhập/Đăng ký.
3. Người dùng chọn Đăng ký (nếu chưa có tài khoản) hoặc Đăng nhập (nếu đã có).
4. Hệ thống validate input → gửi yêu cầu xác thực đến Firebase Authentication.
5. Nếu thành công → (với Đăng ký) tạo document hồ sơ người dùng ban đầu trên Firestore → điều hướng vào Home.
6. Nếu thất bại → hiển thị lỗi thân thiện, giữ người dùng ở màn hình hiện tại để thử lại.
7. Người dùng có thể Đăng xuất từ màn hình Profile bất kỳ lúc nào → quay lại màn hình Đăng nhập.

## Trigger
- Mở ứng dụng lần đầu hoặc sau khi đã đăng xuất (kiểm tra Auth State).
- Người dùng nhấn nút "Đăng ký" / "Đăng nhập" / "Đăng xuất".

## Input
- Email, Password (Đăng ký/Đăng nhập).

## Output
- Trạng thái đăng nhập thành công → điều hướng vào Home.
- Trạng thái lỗi → thông báo hiển thị tại chỗ, không điều hướng.
- (Đăng xuất) → điều hướng về Login, xóa phiên hiện tại.

## Validation
- Email đúng định dạng chuẩn.
- Password tối thiểu 6 ký tự.
- Không được để trống bất kỳ trường bắt buộc nào trước khi submit.

## Exception
- Email đã tồn tại (khi đăng ký).
- Sai email hoặc sai mật khẩu (khi đăng nhập).
- Mất kết nối mạng trong lúc xác thực.
- Tài khoản không tồn tại.

## Business Rules
- BR-05: Email phải đúng định dạng; mật khẩu tối thiểu 6 ký tự.
- BR-06: Người dùng chưa đăng nhập không được truy cập Home, Meal Detail, Favorite, Profile.
- Auth State là nguồn chân lý duy nhất cho toàn bộ điều hướng bảo vệ route trong app.

## State Changes
- `Chưa đăng nhập` → `Đang xác thực (loading)` → `Đã đăng nhập` (thành công) hoặc quay lại `Chưa đăng nhập` kèm lỗi (thất bại).
- `Đã đăng nhập` → `Chưa đăng nhập` khi đăng xuất.

## Notification
- Không có push notification (ngoài phạm vi MVP).
- Thông báo trong app: SnackBar/Dialog hiển thị lỗi xác thực.

## Database Impact
- **Firestore:** Tạo mới document `users/{uid}` khi đăng ký thành công (khởi tạo các field cơ bản: email, name rỗng, height/targetWeight rỗng hoặc mặc định).
- Không có thay đổi Firestore khi đăng nhập/đăng xuất (chỉ thay đổi phiên phía Firebase Auth, không ghi dữ liệu).

---

# 2. Home

## Business Goal
Giúp người dùng có ngay gợi ý món ăn khi mở ứng dụng, giải quyết trực tiếp bài toán "hôm nay ăn gì?" mà không cần thao tác tìm kiếm thủ công.

## Business Flow
1. Người dùng đăng nhập thành công, được điều hướng vào Home.
2. Hệ thống tự động gọi TheMealDB API để lấy danh sách món ăn mặc định.
3. Trong lúc chờ phản hồi, hiển thị trạng thái loading.
4. Khi có dữ liệu → hiển thị danh sách dạng lưới/danh sách kèm hình ảnh, tên món.
5. Nếu lỗi (mất mạng, lỗi API) → hiển thị trạng thái lỗi thân thiện.
6. Người dùng chọn một món ăn → chuyển sang luồng Meal Detail.

## Trigger
- Người dùng vào màn hình Home (sau đăng nhập, hoặc quay lại từ màn hình khác).

## Input
- Không cần input từ người dùng (fetch tự động).

## Output
- Danh sách món ăn hiển thị trên UI.
- Trạng thái loading/error/empty tương ứng.

## Validation
- Không áp dụng (không có input người dùng nhập trực tiếp ở bước này).

## Exception
- Mất kết nối mạng khi fetch dữ liệu.
- TheMealDB trả lỗi hoặc không phản hồi (timeout).
- TheMealDB trả `meals: null` (trường hợp hiếm ở endpoint mặc định, vẫn cần xử lý an toàn).

## Business Rules
- BR-07: Dữ liệu món ăn luôn lấy trực tiếp từ TheMealDB tại thời điểm truy vấn, không cache lâu dài.
- Danh sách mặc định dùng endpoint `search.php?f=b` (đã xác nhận ở `PROJECT_REQUIREMENTS.md`).

## State Changes
- `Idle` → `Loading` → `Success (có danh sách)` hoặc `Error`.

## Notification
- Không áp dụng.

## Database Impact
- Không có (Home chỉ đọc dữ liệu từ TheMealDB, không ghi Firestore).

---

# 3. Search & Filter

## Business Goal
Cho phép người dùng chủ động tìm đúng món ăn mong muốn theo tên hoặc theo danh mục, thay vì chỉ xem danh sách gợi ý cố định — tăng khả năng tìm thấy đúng nhu cầu nấu ăn trong ngày.

## Business Flow
1. Người dùng nhập từ khóa vào thanh Search, hoặc chọn một danh mục từ bộ lọc.
2. Hệ thống gọi TheMealDB API tương ứng (tìm theo tên hoặc lọc theo category).
3. Hiển thị trạng thái loading trong lúc chờ.
4. Khi có kết quả → cập nhật danh sách hiển thị.
5. Khi không có kết quả → hiển thị trạng thái "không tìm thấy món ăn phù hợp".
6. Người dùng có thể xóa từ khóa/bỏ chọn danh mục để quay lại danh sách mặc định của Home.

## Trigger
- Người dùng nhập/submit từ khóa tìm kiếm.
- Người dùng chọn một danh mục lọc.

## Input
- Từ khóa tìm kiếm (chuỗi ký tự, tên món ăn).
- Danh mục được chọn (ví dụ: Seafood, Vegetarian, Beef...).

## Output
- Danh sách món ăn khớp với từ khóa/danh mục.
- Trạng thái rỗng nếu không có kết quả khớp.

## Validation
- Không tìm kiếm với từ khóa rỗng (giữ nguyên danh sách hiện tại hoặc quay về mặc định thay vì gọi API với chuỗi rỗng).

## Exception
- Mất kết nối mạng khi gọi API tìm kiếm/lọc.
- API trả lỗi hoặc timeout.

## Business Rules
- Tìm kiếm và lọc không thể áp dụng đồng thời hai tiêu chí khác nhau trong một lần gọi (theo endpoint TheMealDB, mỗi lần chỉ gọi một trong hai: `search.php?s=` hoặc `filter.php?c=`) — nếu người dùng vừa tìm kiếm vừa lọc, cần xác định rõ hành vi ưu tiên (xem đề xuất bổ sung bên dưới).
- BR-07 áp dụng tương tự Home: dữ liệu luôn lấy trực tiếp, không cache lâu dài.

## State Changes
- `Idle` → `Loading` → `Success (có kết quả)` / `Success (rỗng)` / `Error`.

## Notification
- Không áp dụng.

## Database Impact
- Không có (chỉ đọc dữ liệu từ TheMealDB).

---

# 4. Meal Detail

## Business Goal
Cung cấp đầy đủ thông tin cần thiết (nguyên liệu, các bước thực hiện, calo ước tính) để người dùng có thể thực hiện nấu món ăn đã chọn, đồng thời là điểm quyết định có lưu món này vào danh sách cá nhân hay không.

## Business Flow
1. Người dùng chọn một món ăn từ Home hoặc kết quả Search/Filter.
2. Hệ thống gọi TheMealDB API lấy chi tiết món ăn theo `idMeal`.
3. Đồng thời kiểm tra trong Firestore xem món này đã có trong danh sách yêu thích của người dùng hay chưa, để hiển thị đúng trạng thái icon trái tim.
4. Hiển thị đầy đủ hình ảnh, nguyên liệu, các bước thực hiện, calo ước tính.
5. Người dùng có thể nhấn icon trái tim → chuyển sang luồng Favorite (Create/Delete).

## Trigger
- Người dùng nhấn chọn một món ăn từ danh sách (Home/Search).

## Input
- `idMeal` (ID món ăn được chọn).

## Output
- Thông tin chi tiết món ăn hiển thị đầy đủ trên UI.
- Trạng thái đúng của nút yêu thích (đã lưu / chưa lưu).

## Validation
- Không áp dụng (không có input người dùng nhập trực tiếp).

## Exception
- Mất kết nối mạng khi fetch chi tiết món ăn.
- `idMeal` không còn tồn tại trên TheMealDB (hiếm, nhưng cần xử lý an toàn, ví dụ hiển thị "không tìm thấy món ăn").

## Business Rules
- BR-07: dữ liệu chi tiết luôn lấy trực tiếp từ TheMealDB tại thời điểm xem, không lưu bản sao lâu dài nội dung công thức.

## State Changes
- `Loading` → `Success (có dữ liệu chi tiết)` / `Error`.
- Trạng thái nút yêu thích: `Chưa lưu` ⇄ `Đã lưu` (xem chi tiết ở luồng Favorite).

## Notification
- Không áp dụng.

## Database Impact
- Đọc (Read) từ Firestore để kiểm tra trạng thái yêu thích hiện tại của món ăn đang xem — không ghi dữ liệu ở bước xem chi tiết.

---

# 5. Favorite

## Business Goal
Cho phép người dùng cá nhân hóa và lưu trữ tập trung các món ăn yêu thích kèm ghi chú riêng — giá trị cốt lõi giúp NutriCook khác biệt so với các trang web công thức thông thường.

## Business Flow

### 5.1 Thêm/Bỏ yêu thích (Toggle)
1. Người dùng nhấn icon trái tim tại Meal Detail (hoặc vị trí tương đương).
2. Hệ thống kiểm tra trạng thái hiện tại của món ăn đó trong Firestore.
3. Nếu chưa có → tạo (Create) bản ghi mới trong `users/{uid}/favorites/{idMeal}`.
4. Nếu đã có → xóa (Delete) bản ghi đó (toggle off).
5. UI cập nhật ngay trạng thái icon tương ứng.

### 5.2 Xem danh sách yêu thích
1. Người dùng vào tab Favorite/Menu.
2. Hệ thống lắng nghe (real-time) dữ liệu từ `users/{uid}/favorites`.
3. Hiển thị danh sách món đã lưu, hoặc trạng thái rỗng nếu chưa có món nào.

### 5.3 Thêm/sửa ghi chú cá nhân
1. Người dùng chọn một món trong danh sách yêu thích, mở phần ghi chú.
2. Người dùng nhập/chỉnh sửa nội dung ghi chú và lưu.
3. Hệ thống cập nhật (Update) field `note` trong document tương ứng trên Firestore.

### 5.4 Xóa khỏi danh sách yêu thích
1. Người dùng vuốt (swipe) một món trong danh sách Favorite.
2. Hệ thống xóa (Delete) document tương ứng trên Firestore.
3. Danh sách tự động cập nhật (do đang lắng nghe real-time).

## Trigger
- Nhấn icon trái tim tại Meal Detail.
- Mở tab Favorite/Menu.
- Nhập/lưu ghi chú cho một món đã lưu.
- Vuốt để xóa một món khỏi danh sách.

## Input
- `idMeal`, thông tin tối thiểu để hiển thị nhanh trong list (tên món, ảnh thumbnail).
- Nội dung ghi chú cá nhân (chuỗi văn bản).

## Output
- Trạng thái yêu thích cập nhật (đã lưu/chưa lưu).
- Danh sách Favorite hiển thị đúng, đồng bộ real-time.
- Ghi chú được lưu và hiển thị lại đúng nội dung.

## Validation
- Ghi chú không bắt buộc phải nhập (có thể để trống), nhưng nếu có giới hạn độ dài nên áp dụng để tránh dữ liệu quá lớn (xem đề xuất bổ sung).
- Không cho phép tạo trùng lặp bản ghi cho cùng một `idMeal` của cùng một người dùng.

## Exception
- Mất kết nối mạng khi thêm/xóa/cập nhật.
- Lỗi quyền truy cập Firestore (permission-denied — không đúng chủ sở hữu dữ liệu).
- Lỗi khi Firestore tạm thời không khả dụng (unavailable).

## Business Rules
- BR-01: Mỗi món yêu thích thuộc về đúng một tài khoản, không chia sẻ giữa các user.
- BR-02: Một món ăn chỉ xuất hiện tối đa một lần trong danh sách yêu thích của một người dùng — hành vi toggle.
- BR-03: Ghi chú cá nhân là dữ liệu riêng tư, không hiển thị cho người dùng khác.
- BR-05 (liên quan định danh): Document ID của favorite dùng chính `idMeal`.

## State Changes
- Trạng thái món ăn: `Chưa lưu` ⇄ `Đã lưu` (toggle qua Create/Delete).
- Trạng thái danh sách Favorite: `Loading` (lần đầu lắng nghe) → `Success (có dữ liệu)` / `Success (rỗng)` / `Error` (nếu listener lỗi).
- Trạng thái ghi chú: `Chưa chỉnh sửa` → `Đang lưu` → `Đã lưu` / `Lỗi lưu`.

## Notification
- Không có push notification.
- Có thể hiển thị phản hồi tức thời trong app (ví dụ hiệu ứng icon, SnackBar xác nhận "Đã lưu ghi chú") — mang tính UX, không bắt buộc theo barem.

## Database Impact
- **Create:** thêm document `users/{uid}/favorites/{idMeal}` khi thêm yêu thích.
- **Read:** lắng nghe real-time toàn bộ sub-collection `favorites` khi vào tab Favorite; đọc đơn lẻ 1 document khi kiểm tra trạng thái tại Meal Detail.
- **Update:** cập nhật field `note` (và có thể `updatedAt`) khi chỉnh sửa ghi chú.
- **Delete:** xóa document tương ứng khi bỏ yêu thích hoặc vuốt xóa.

---

# 6. Profile

## Business Goal
Cho phép người dùng duy trì thông tin cá nhân cơ bản phục vụ mục tiêu theo dõi sức khỏe (chiều cao, cân nặng mục tiêu), đồng thời là nơi quản lý phiên đăng nhập (đăng xuất).

## Business Flow
1. Người dùng vào tab Profile.
2. Hệ thống đọc thông tin hiện tại từ Firestore (`users/{uid}`) và hiển thị lên form.
3. Người dùng chỉnh sửa tên, chiều cao, cân nặng mục tiêu.
4. Người dùng nhấn Lưu → hệ thống validate → cập nhật (Update) document trên Firestore.
5. Người dùng có thể nhấn Đăng xuất bất kỳ lúc nào từ màn hình này (xem luồng Authentication).

## Trigger
- Vào tab Profile.
- Nhấn Lưu sau khi chỉnh sửa thông tin.
- Nhấn Đăng xuất.

## Input
- Tên hiển thị (chuỗi văn bản).
- Chiều cao (số).
- Cân nặng mục tiêu (số).

## Output
- Thông tin hồ sơ được cập nhật và phản ánh ngay trên UI.
- Xác nhận lưu thành công hoặc thông báo lỗi validate.

## Validation
- Tên không được để trống.
- Chiều cao, cân nặng mục tiêu phải là số dương (BR-04), không chấp nhận giá trị 0 hoặc âm.
- Không để trống các trường bắt buộc trước khi lưu.

## Exception
- Mất kết nối mạng khi lưu thay đổi.
- Lỗi quyền truy cập Firestore.

## Business Rules
- BR-04: Chiều cao và cân nặng mục tiêu phải là số dương.
- Chỉ chủ tài khoản mới đọc/ghi được document `users/{uid}` của chính mình (đảm bảo qua Firestore Security Rules, không phải business rule ở tầng ứng dụng).

## State Changes
- `Idle` → `Đang tải dữ liệu hồ sơ` → `Hiển thị dữ liệu` → (khi chỉnh sửa) `Đang lưu` → `Đã lưu` / `Lỗi lưu`.

## Notification
- Không có push notification.
- Phản hồi trong app: SnackBar xác nhận "Cập nhật thành công" hoặc thông báo lỗi.

## Database Impact
- **Read:** đọc document `users/{uid}` khi vào màn hình.
- **Update:** cập nhật các field `name`, `height`, `targetWeight` khi người dùng lưu thay đổi.

---

# 7. Admin

**Không áp dụng cho MVP.** Đề bài gốc (`NutriCook_Project_PRM393.txt`) và `PROJECT_REQUIREMENTS.md` không mô tả bất kỳ luồng nghiệp vụ nào cho vai trò quản trị (không có yêu cầu quản lý người dùng, kiểm duyệt nội dung, hay quản trị công thức món ăn — dữ liệu món ăn hoàn toàn đến từ TheMealDB, không do người dùng tạo). Mục này được giữ lại như một placeholder có chủ đích, để dễ bổ sung nếu dự án mở rộng sau khi hoàn thành MVP (ví dụ nếu sau này cho phép người dùng tự đăng công thức, sẽ cần vai trò Admin kiểm duyệt).

---

# Flow Diagram (dạng text)

## 8.1 Luồng tổng quát toàn hệ thống

```
User
 ↓
Open App
 ↓
Check Auth State
 ↓
   ┌─────────────┴─────────────┐
   ↓                           ↓
Chưa đăng nhập              Đã đăng nhập
   ↓                           ↓
Login / Register            Home
   ↓                           ↓
Validate Input              Fetch Default Meals
   ↓                           ↓
   ┌────┴────┐               Display Meal List
   ↓         ↓                  ↓
Success    Failure          Search / Filter
   ↓         ↓                  ↓
 Home    Show Error        Display Result List
   ↓                           ↓
   └─────────────┬─────────────┘
                 ↓
           Select Meal Item
                 ↓
           View Meal Detail
                 ↓
      Check Favorite Status (Firestore)
                 ↓
        ┌────────┴────────┐
        ↓                 ↓
   Tap Favorite Icon   (Không thao tác)
        ↓
   Toggle Favorite
        ↓
   ┌────┴────┐
   ↓         ↓
 Create    Delete
 (chưa lưu → đã lưu)   (đã lưu → chưa lưu)
        ↓
   Update Meal Detail UI
                 ↓
           Go to Favorite Tab
                 ↓
      Listen Realtime Favorite List
                 ↓
        ┌────────┼────────┐
        ↓        ↓        ↓
   View List   Edit Note   Swipe to Delete
        ↓        ↓        ↓
       (Read)  (Update)  (Delete)
                 ↓
           Go to Profile Tab
                 ↓
        Load Current Profile (Read)
                 ↓
        Edit Name / Height / Target Weight
                 ↓
        Validate Input
                 ↓
   ┌─────────────┴─────────────┐
   ↓                           ↓
 Valid                      Invalid
   ↓                           ↓
 Save (Update)          Show Validation Error
   ↓
 Confirm Success
   ↓
 Logout (tùy chọn)
   ↓
 Clear Session
   ↓
 Back to Login
```

## 8.2 Luồng rút gọn theo ví dụ mẫu (đúng định dạng yêu cầu)

```
User
 ↓
Login
 ↓
Validate
 ↓
Success
 ↓
Home
 ↓
Search / Filter
 ↓
Select Item
 ↓
View Detail
 ↓
Favorite (Create / Delete)
 ↓
Favorite List (Read / Update note / Delete)
 ↓
Profile (Read / Update)
 ↓
Logout
```

## 8.3 Luồng lỗi chung (áp dụng cho mọi module có gọi External System)

```
Action (Login / Fetch Meals / Search / Save Favorite / Update Profile...)
 ↓
Call External System (Firebase Auth / TheMealDB / Firestore)
 ↓
   ┌────────────┴────────────┐
   ↓                         ↓
 Success                   Failure
   ↓                         ↓
 Update State (Success)   Map lỗi → Error State
   ↓                         ↓
 Update UI               Show Friendly Error (SnackBar/Dialog)
                              ↓
                         (Tùy chọn) Retry Action
```

---

# Đề xuất bổ sung liên quan đến Business Flow

1. **Ưu tiên giữa Search và Filter khi dùng đồng thời:** TheMealDB chỉ hỗ trợ gọi riêng lẻ `search.php?s=` hoặc `filter.php?c=`, không hỗ trợ kết hợp cả hai trong một request. Đề xuất: quy định rõ hành vi UX — ví dụ khi người dùng chọn category filter thì tự động xóa từ khóa search đang có (và ngược lại), để tránh trạng thái mập mờ "đang áp dụng cả hai" mà hệ thống không thực sự hỗ trợ.
2. **Giới hạn độ dài ghi chú cá nhân (Favorite):** Đề bài không quy định giới hạn. Đề xuất đặt giới hạn hợp lý (ví dụ tối đa 200–500 ký tự) để tránh document Firestore phình to không cần thiết và giữ trải nghiệm UI gọn gàng.
3. **Hành vi khi `idMeal` bị xóa khỏi TheMealDB nhưng vẫn còn trong Favorite của người dùng:** Đề bài chưa đề cập trường hợp này. Đề xuất: khi mở lại một món yêu thích mà API trả về rỗng, hiển thị trạng thái "món ăn không còn khả dụng" thay vì lỗi kỹ thuật, nhưng vẫn giữ nguyên bản ghi favorite (không tự động xóa) để không mất ghi chú của người dùng.

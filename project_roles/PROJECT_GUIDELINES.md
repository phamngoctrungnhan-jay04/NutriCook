# PROJECT_GUIDELINES.md — NutriCook (PRM393)

Tài liệu này quy định cách **AI (Claude Code) và bất kỳ ai** viết code trong dự án NutriCook phải làm việc. Đây là MVP cho đồ án môn học (PRM393 – Flutter Mobile Application Development), ưu tiên **production-ready nhưng đơn giản, dễ học, dễ maintain**, không over-engineering. Mọi quy tắc dưới đây áp dụng cho toàn bộ codebase Flutter/Dart, tích hợp Firebase (Auth, Firestore) và REST API (TheMealDB).

Khi có xung đột giữa "làm cho đúng chuẩn lớn" và "giữ đơn giản cho MVP", **luôn ưu tiên đơn giản**, miễn là không phá vỡ các nguyên tắc nền tảng ở mục 1.

---

## 1. Development Philosophy

### Clean Code
- Code phải tự giải thích qua tên biến/hàm/class rõ ràng, không cần đọc comment mới hiểu.
- Mỗi hàm làm đúng một việc. Nếu một hàm cần "và" để mô tả (ví dụ "fetch data và validate và lưu"), nên tách nhỏ.
- Không để lại code chết (dead code), import thừa, biến không dùng, TODO mơ hồ không có ngữ cảnh.

### SOLID (áp dụng ở mức vừa phải cho quy mô MVP)
- **S — Single Responsibility:** Mỗi class/widget chỉ có một lý do để thay đổi (ví dụ: `MealRepository` chỉ lo việc lấy dữ liệu món ăn, không lo hiển thị UI).
- **O — Open/Closed:** Thiết kế để mở rộng (thêm nguồn dữ liệu mới, thêm màn hình mới) mà không sửa lại code đã chạy ổn định, nhưng **không tạo abstraction cho khả năng mở rộng chưa có nhu cầu thật**.
- **L — Liskov Substitution:** Nếu dùng interface/abstract class (ví dụ để tách repository thật và mock), các implementation phải thay thế nhau được mà không phá logic gọi.
- **I — Interface Segregation:** Không ép một class phải implement những method nó không dùng đến.
- **D — Dependency Inversion:** Các tầng cao (UI, Provider/Controller) phụ thuộc vào abstraction (repository interface) chứ không phụ thuộc trực tiếp vào chi tiết triển khai (Firestore SDK, http client) khi có thể làm đơn giản.

> Lưu ý cho MVP: không bắt buộc phải có interface cho mọi class. Chỉ tách interface khi thực sự có từ 2 implementation trở lên hoặc cần test bằng mock.

### DRY (Don't Repeat Yourself)
- Logic lặp lại từ 3 lần trở lên nên được rút thành hàm/widget dùng chung.
- Không DRY hóa quá sớm: 2 đoạn code giống nhau tình cờ, phục vụ mục đích khác nhau, **không cần** gộp lại nếu việc gộp làm code khó hiểu hơn.

### KISS (Keep It Simple, Stupid)
- Luôn chọn giải pháp đơn giản nhất giải quyết đúng yêu cầu hiện tại.
- Không dùng design pattern, package, hoặc kiến trúc phức tạp chỉ để "cho chuẩn" nếu MVP không cần.
- Nếu phân vân giữa 2 cách làm, chọn cách ít file, ít lớp trừu tượng hơn, miễn vẫn rõ ràng.

### Separation of Concerns
- Tách biệt rõ 3 tầng: **UI (Presentation)** — **State/Logic (Controller/Provider)** — **Data (Repository/Service/Model)**.
- UI không gọi trực tiếp Firebase SDK hay `http` package; luôn đi qua tầng Service/Repository.
- Widget không tự chứa business logic phức tạp (validation nặng, tính toán, gọi API) — logic đó thuộc về Controller/Provider hoặc Service.

### Readability First
- Ưu tiên code dễ đọc hơn code "ngắn gọn khôn khéo". Một sinh viên khác đọc lại phải hiểu trong vài phút.
- Tránh nesting quá 3 cấp (if/for lồng nhau); nếu vượt quá, tách hàm con hoặc early return.

### Maintainability First
- Viết code để 3 tháng sau (hoặc thành viên khác) sửa được mà không cần hỏi lại tác giả.
- Không tối ưu hiệu năng đánh đổi bằng việc code khó hiểu, trừ khi có lý do đo lường được (xem mục 10).

---

## 2. Architecture Rules

- Áp dụng kiến trúc **layered đơn giản** (không bắt buộc Clean Architecture đầy đủ, không cần use-case layer riêng cho MVP):
  1. **Presentation layer** (`views/`, `widgets/`): Screens, Widgets, State Management (Provider/Riverpod/Bloc — chọn 1 và dùng nhất quán toàn dự án).
  2. **Domain/State layer** (`providers/` hoặc `controllers/`): xử lý logic nghiệp vụ, gọi Service, quản lý state expose ra UI.
  3. **Data layer** (`models/`, `services/`, `repositories/`): Model class (`fromJson`/`toJson`), Service gọi REST API (TheMealDB), Service gọi Firebase (Auth, Firestore).
- **Một chiều phụ thuộc:** Presentation → State layer → Data layer. Không cho phép chiều ngược lại (Data layer không được biết đến Widget).
- Mỗi màn hình lớn (Home, Detail, Favorite, Profile, Auth) là một module độc lập, có thư mục riêng chứa screen + các widget con chỉ dùng riêng cho màn đó.
- Widget dùng chung ở nhiều màn hình (button, loading indicator, error view...) đặt trong `widgets/common/`.
- Không tạo thêm tầng trừu tượng (ví dụ: Use Case, Mapper riêng, DI container phức tạp) nếu MVP chưa có nhu cầu — có thể bổ sung khi dự án mở rộng thật sự.
- State management: chọn 1 giải pháp (khuyến nghị `Provider` hoặc `Riverpod` vì đơn giản, dễ học, phù hợp MVP) và dùng xuyên suốt, không trộn nhiều giải pháp state khác nhau trong cùng dự án.
- **Giữ code thuần cross-platform (quan trọng cho kế hoạch bàn giao):** Vì máy phát triển hiện tại là MacBook nên MVP build/test trên iOS Simulator, nhưng codebase sẽ được bàn giao cho thành viên khác build Android sau khi hoàn thành (xem `PROJECT_REQUIREMENTS.md` mục Constraints/điểm 9). Do đó:
  - Chỉ dùng widget Material (`MaterialApp`, `Scaffold`, Material widget set) làm nền tảng UI chính — **không dùng widget Cupertino** (`CupertinoApp`, `CupertinoButton`...) trừ khi có lý do rõ ràng, vì Cupertino là widget style riêng cho iOS, không tự động khớp UI trên Android.
  - Không dùng package/plugin chỉ hỗ trợ iOS (kiểm tra kỹ mục "Platform Support" trên pub.dev trước khi thêm dependency) — mọi package phải hỗ trợ cả Android lẫn iOS.
  - Không hard-code hành vi/giá trị giả định riêng của iOS (ví dụ safe area, gesture, font fallback) — luôn dùng API trung lập nền tảng của Flutter (`SafeArea`, `MediaQuery`...).
  - Không dùng `Platform.isIOS`/`Platform.isAndroid` để rẽ nhánh logic nghiệp vụ trừ khi thực sự cần thiết (ví dụ khác biệt UX bắt buộc) — ưu tiên hành vi đồng nhất trên cả hai nền tảng.

---

## 3. Coding Standards

- Tuân thủ [Effective Dart](https://dart.dev/effective-dart) và các rule trong `analysis_options.yaml` của dự án — không tắt lint rule để né lỗi, phải sửa code cho đúng.
- Bật và tôn trọng `flutter analyze` — code không được có warning/error trước khi coi là hoàn thành.
- Dùng `const` constructor cho widget bất cứ khi nào có thể (giúp performance và là convention chuẩn Flutter).
- Không dùng `dynamic` tùy tiện; luôn khai báo kiểu dữ liệu rõ ràng, đặc biệt với Model và kết quả API.
- Tách UI phức tạp thành nhiều widget nhỏ thay vì 1 hàm `build()` khổng lồ (giới hạn tham khảo: build method không quá ~100 dòng).
- Không hard-code chuỗi UI, URL API, hay magic number lặp lại nhiều nơi — đưa vào hằng số (`constants/`).
- Mỗi file chỉ chứa 1 class chính (trừ các class phụ nhỏ liên quan chặt, ví dụ enum dùng riêng cho class đó).

---

## 4. Naming Convention

- **File & folder:** `snake_case` (ví dụ: `meal_detail_screen.dart`, `auth_service.dart`).
- **Class, Enum, Extension, Typedef:** `UpperCamelCase` (ví dụ: `MealModel`, `AuthService`, `FavoriteProvider`).
- **Biến, hàm, tham số:** `lowerCamelCase` (ví dụ: `fetchMealList()`, `isLoading`).
- **Hằng số:** `lowerCamelCase` với `const`/`static const` (Dart convention hiện tại không dùng `SCREAMING_CASE`), ví dụ: `const apiBaseUrl = '...'`.
- **Private member:** tiền tố `_` (ví dụ: `_isLoading`, `_fetchData()`).
- **Tên Screen/Page:** hậu tố `Screen` (ví dụ: `HomeScreen`, `LoginScreen`).
- **Tên Widget tái sử dụng:** mô tả đúng chức năng, không hậu tố thừa (ví dụ: `MealCard`, `PrimaryButton`).
- **Tên Provider/Controller:** hậu tố `Provider` hoặc `Controller` nhất quán theo state management đã chọn (ví dụ: `AuthProvider`, `FavoriteController`).
- **Tên Service/Repository:** hậu tố `Service` (gọi API bên ngoài trực tiếp) hoặc `Repository` (điều phối nguồn dữ liệu), ví dụ: `MealApiService`, `FavoriteRepository`.
- **Tên biến boolean:** bắt đầu bằng `is`, `has`, `should` (ví dụ: `isLoading`, `hasError`).

---

## 5. Folder Organization Rules

Cấu trúc thư mục `lib/` chuẩn cho dự án (tạo mới khi cần, không tạo thư mục rỗng trước):

```
lib/
├── main.dart
├── app.dart                     # MaterialApp, route, theme setup
├── constants/                   # API base URL, màu sắc, text, key Firestore collection
├── models/                      # Model class + fromJson/toJson (MealModel, UserModel, FavoriteModel...)
├── services/                    # Gọi trực tiếp nguồn dữ liệu bên ngoài (MealApiService, AuthService, FirestoreService)
├── repositories/                # (nếu cần) điều phối / kết hợp nhiều service, cache đơn giản
├── providers/                   # State management (theo giải pháp đã chọn ở mục 2)
├── screens/
│   ├── auth/                    # login, register, forgot password
│   ├── home/
│   ├── meal_detail/
│   ├── favorite/
│   └── profile/
├── widgets/
│   └── common/                  # widget dùng chung nhiều màn hình
└── utils/                       # helper function thuần (validator, formatter...)
```

- Mỗi thư mục con trong `screens/` chứa screen chính + widget riêng của screen đó (không đẩy hết widget riêng vào `widgets/common/`).
- Không tạo file/folder "phòng khi cần sau này" — chỉ tạo khi có tính năng thật sự dùng đến.
- Asset (ảnh, icon) đặt trong `assets/` ở project root theo chuẩn Flutter, khai báo trong `pubspec.yaml`.

---

## 6. Logging Rules

- Không dùng `print()` trong code production — dùng `debugPrint()` cho log khi phát triển (tự động bị lược bỏ ở release build).
- Log phải có ngữ cảnh: nêu rõ đang log ở đâu, việc gì (ví dụ: `debugPrint('[AuthService] Login failed: $e')`).
- Không log dữ liệu nhạy cảm: mật khẩu, token, thông tin cá nhân người dùng.
- Lỗi bắt được trong `try-catch` phải được log lại (ít nhất ở tầng Service), không được "nuốt" lỗi im lặng.
- Đã tích hợp Firebase Crashlytics (theo yêu cầu bổ sung, đảo ngược khuyến nghị ban đầu) để bắt lỗi Flutter/Dart chưa xử lý ở `main.dart` — tắt thu thập khi chạy debug (`kDebugMode`) để không làm nhiễu dashboard. `debugPrint` vẫn là kênh log chính cho lỗi đã được bắt (`try-catch`) trong Service/Provider.

---

## 7. Exception Handling Rules

- Mọi lời gọi bất đồng bộ ra bên ngoài (API, Firebase Auth, Firestore) phải được bọc trong `try-catch` ở tầng Service/Repository.
- Không để exception thô rò rỉ lên UI — Service/Provider phải bắt lỗi và trả về trạng thái rõ ràng (ví dụ enum `Idle / Loading / Success / Error` hoặc kiểu Result đơn giản).
- UI hiển thị lỗi thân thiện với người dùng qua `SnackBar` hoặc `Dialog`, không hiển thị message kỹ thuật thô (stack trace, exception type) trực tiếp cho người dùng cuối.
- Phân loại lỗi tối thiểu cần xử lý theo đúng barem đề bài:
  - Mất mạng / timeout khi gọi REST API.
  - Lỗi từ Firebase Auth (sai email/password, email đã tồn tại...) — map sang thông báo tiếng Việt/Anh dễ hiểu.
  - Lỗi Firestore (permission, network).
  - Trạng thái rỗng (không có dữ liệu) phải phân biệt rõ với trạng thái lỗi.
- Dùng `FutureBuilder`/`StreamBuilder` (hoặc state pattern tương đương trong provider) để xử lý đủ 3 trạng thái: loading, error (`snapshot.hasError`), success.
- Không dùng exception để điều khiển luồng logic thông thường (chỉ dùng cho tình huống thật sự ngoại lệ).

---

## 8. API Rules

- Toàn bộ lời gọi REST API (TheMealDB) tập trung trong `services/meal_api_service.dart` — UI/Provider không tự build URL hay gọi `http`/`dio` trực tiếp.
- Base URL và API key đặt trong `constants/` (ví dụ `constants/api_constants.dart`), không hard-code rải rác trong nhiều file.
- Mọi response JSON phải được parse qua Model class có `fromJson` — không thao tác trực tiếp trên `Map<String, dynamic>` ở tầng UI/Provider.
- Luôn kiểm tra response null/rỗng (TheMealDB trả `null` cho `meals` khi không có kết quả) trước khi parse.
- Timeout hợp lý cho mọi request (ví dụ 10–15s), tránh app treo khi mất mạng.
- Với Firestore, cấu trúc dữ liệu theo đúng schema đã định nghĩa (`users/{uid}`, `users/{uid}/favorites/{mealId}`), thao tác CRUD gói gọn trong `services/firestore_service.dart` hoặc `repositories/favorite_repository.dart`.
- Không gọi Firestore/API trong `build()` của widget — luôn gọi qua Provider/Controller ở lifecycle phù hợp (`initState`, event handler).

---

## 9. Security Rules

- Không commit API key thật, Firebase config nhạy cảm (`google-services.json`, `GoogleService-Info.plist`) lên repository public nếu chứa thông tin nhạy cảm của tài khoản cá nhân — kiểm tra `.gitignore` đã loại trừ đúng.
- Áp dụng **Input Validation** ở mọi form nhập liệu (đăng ký/đăng nhập/profile): email đúng định dạng, password ≥ 6 ký tự, không để trống trường bắt buộc — dùng `FormState`/`TextFormField` validator theo đúng barem đề bài.
- Không lưu password dạng plain text ở bất kỳ đâu trong app (Firebase Auth đã tự xử lý hash, không tự implement lại).
- Thiết lập **Firestore Security Rules** đảm bảo user chỉ đọc/ghi được dữ liệu của chính mình (`request.auth.uid == userId`), không để rule mở `allow read, write: if true` khi nộp bài.
- Không log hoặc hiển thị thông tin nhạy cảm (token, uid đầy đủ không cần thiết) ra UI/log ở bản release.
- Xác thực trạng thái đăng nhập (Auth State) trước khi cho phép truy cập các màn hình cần bảo vệ (Favorite, Profile).

---

## 10. Performance Rules

- Dùng `const` widget để giảm rebuild không cần thiết.
- Dùng `ListView.builder`/`GridView.builder` cho danh sách món ăn thay vì dựng sẵn toàn bộ list (tránh render thừa).
- Tránh gọi lại API/Firestore không cần thiết khi widget rebuild — cache kết quả trong Provider/State, chỉ fetch lại khi cần (pull-to-refresh, thay đổi filter/search).
- Ảnh từ API nên dùng widget có cache ảnh (ví dụ `Image.network` với `cacheWidth` hợp lý, hoặc package cache ảnh nếu dự án đã có) để tránh tải lại ảnh liên tục.
- Không tối ưu performance sớm cho các trường hợp chưa đo lường thấy chậm — với MVP, ưu tiên đúng và rõ ràng trước, chỉ tối ưu khi thấy giật/lag thực tế khi test trên iOS Simulator (môi trường build/test chính thức của dự án, xem `PROJECT_REQUIREMENTS.md` mục Constraints).

---

## 11. AI Coding Workflow Rules

Khi AI (Claude Code) thực hiện task trong dự án này:

1. **Đọc trước khi viết:** Luôn đọc file/folder liên quan hiện có trước khi tạo code mới, tránh trùng lặp hoặc phá vỡ convention đã có.
2. **Task nhỏ, rõ ràng:** Chia công việc theo từng giai đoạn như trong đề bài (Setup → Auth → REST API → Firestore CRUD → Polish), không làm nhảy cóc nhiều tính năng cùng lúc trong 1 lần thay đổi.
3. **Không tự ý đổi kiến trúc/state management** đã chọn giữa chừng dự án nếu không được yêu cầu rõ.
4. **Không thêm package mới** vào `pubspec.yaml` nếu chưa cần thiết hoặc chưa được xác nhận — ưu tiên SDK/package đã có trong dự án.
5. **Giải thích ngắn gọn** thay đổi kiến trúc quan trọng (thêm layer, đổi cấu trúc thư mục) trước khi thực hiện trên diện rộng.
6. **Không generate code khi được yêu cầu chỉ phân tích/tài liệu** (như task hiện tại) — tôn trọng đúng phạm vi được giao.
7. Khi không chắc chắn về yêu cầu nghiệp vụ (ví dụ schema Firestore, luồng UX), hỏi lại thay vì tự suy đoán và implement sai hướng.

---

## 12. AI Coding Behavior Rules

- **Không over-engineering:** không tự thêm design pattern, generic framework, hay abstraction "phòng hờ tương lai" khi đề bài/MVP chưa cần.
- **Không tự ý refactor toàn bộ file** khi task chỉ yêu cầu sửa một phần nhỏ — refactor phạm vi rộng phải được nêu rõ và tách thành việc riêng.
- **Giữ nhất quán với code đã có:** style, naming, cấu trúc phải khớp với phần code hiện tại của dự án, không mang phong cách khác vào.
- **Không giả định thư viện/API không tồn tại:** kiểm tra `pubspec.yaml`, tài liệu package trước khi dùng method/class.
- **Không tự tạo dữ liệu giả (mock/fake) lẫn vào code thật** trừ khi được yêu cầu rõ (ví dụ cho mục đích test).
- **Ưu tiên tính đúng đắn và khớp đề bài** (bám sát các mục ở phần 3 "Phân bổ tính năng khớp Barem điểm") hơn là thêm tính năng ngoài phạm vi MVP.
- **Luôn để lại code chạy được** — không commit code dang dở gây lỗi build.

---

## 13. Refactoring Rules

- Chỉ refactor khi: (a) phát hiện trùng lặp rõ ràng (≥3 chỗ), (b) code đang gây khó hiểu/khó test, hoặc (c) được yêu cầu tường minh.
- Refactor phải giữ nguyên hành vi (behavior-preserving) — không lẫn refactor với thêm tính năng mới trong cùng một lần thay đổi.
- Ưu tiên refactor theo hướng: tách widget nhỏ hơn, rút hàm dùng chung, đưa magic string/number vào constants — đúng như Giai đoạn 5 của đề bài (đóng gói UI trùng lặp thành Reusable Widgets).
- Sau khi refactor, chạy `flutter analyze` và test liên quan (nếu có) để đảm bảo không phá vỡ chức năng.

---

## 14. Documentation Rules

- Không viết docstring/comment dài dòng giải thích "code làm gì" nếu tên hàm/biến đã đủ rõ.
- Chỉ viết comment khi giải thích **lý do (why)** không hiển nhiên: một workaround, một giới hạn của TheMealDB API, một quyết định kiến trúc đặc biệt.
- README.md ở root giữ vai trò hướng dẫn setup dự án (cách chạy, cấu hình Firebase, biến môi trường nếu có) — cập nhật khi quy trình setup thay đổi.
- Không tự tạo thêm file markdown tài liệu (kế hoạch, phân tích...) trừ khi được yêu cầu rõ ràng.
- Model class phức tạp (map JSON lồng nhau từ TheMealDB) có thể có 1 dòng comment mô tả nguồn field nếu tên field API khó hiểu (ví dụ `strMeal` → tên món).

---

## 15. Git Commit Convention

Dùng [Conventional Commits](https://www.conventionalcommits.org/) để lịch sử commit rõ ràng, dễ theo dõi tiến độ theo từng giai đoạn (Sprint) của đề bài:

```
<type>(<phạm vi tùy chọn>): <mô tả ngắn gọn, thì hiện tại>
```

Các `type` sử dụng:
- `feat`: thêm tính năng mới (ví dụ: `feat(auth): add email/password login`)
- `fix`: sửa lỗi
- `refactor`: tái cấu trúc code, không đổi hành vi
- `style`: chỉnh format, không ảnh hưởng logic
- `docs`: thay đổi tài liệu
- `chore`: cấu hình, dependency, build script
- `test`: thêm/sửa test

Quy tắc:
- Mỗi commit nên tương ứng với một đơn vị công việc hoàn chỉnh, có thể build được.
- Không commit thẳng vào nhánh chính nếu dự án có branching strategy (theo Giai đoạn 1 của đề bài) — dùng feature branch + merge/PR.
- Message viết bằng tiếng Anh, ngắn gọn, mô tả đúng thay đổi thực tế.

---

## 16. Code Review Checklist

Trước khi coi một thay đổi là hoàn thành, kiểm tra:

- [ ] `flutter analyze` không còn warning/error.
- [ ] Không có `print()` còn sót lại, không có code debug tạm.
- [ ] UI không gọi trực tiếp Firebase SDK / `http` package — đi qua Service/Repository đúng layer.
- [ ] Mọi lời gọi async ra bên ngoài có xử lý loading/error/empty state.
- [ ] Input form có validation đầy đủ (email, password, trường bắt buộc).
- [ ] Naming tuân đúng convention ở mục 4.
- [ ] Không có logic trùng lặp rõ ràng có thể rút gọn.
- [ ] Không thêm abstraction/pattern không cần thiết cho MVP.
- [ ] Firestore Security Rules không bị nới lỏng quá mức khi thêm tính năng mới liên quan dữ liệu.
- [ ] Đã test thủ công luồng chính (happy path) và ít nhất 1 trường hợp lỗi (mất mạng/sai input).
- [ ] Commit message tuân theo Conventional Commits.

---

## 17. Final Goal

Xây dựng NutriCook thành một ứng dụng Flutter MVP:

- **Đúng và đủ** yêu cầu barem điểm PRM393: Firebase Auth, REST API (TheMealDB), CRUD Firestore, Search/Filter, Input Validation, Exception Handling.
- **Chạy ổn định trên iOS Simulator** (môi trường build/test chính thức của dự án), không crash, không lỗi tràn giao diện, sẵn sàng demo trực tiếp.
- **Code sạch, dễ đọc, dễ bảo trì**, đúng kiến trúc phân tầng đơn giản, không over-engineering — để một sinh viên khác (hoặc chính tác giả sau vài tháng) có thể đọc và mở rộng dự án mà không cần giải thích thêm.
- **Có khả năng mở rộng về sau** (thêm tính năng, đổi nguồn API, tăng quy mô dữ liệu) mà không cần viết lại từ đầu, nhờ việc tách lớp rõ ràng giữa UI — State — Data ngay từ đầu.

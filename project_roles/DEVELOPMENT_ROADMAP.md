# DEVELOPMENT_ROADMAP.md — NutriCook (PRM393)

Tài liệu này chia nhỏ toàn bộ quá trình phát triển NutriCook thành 15 phase tuần tự, tổng hợp từ `PROJECT_REQUIREMENTS.md`, `SYSTEM_ARCHITECTURE.md`, `BUSINESS_FLOW.md`, `DATABASE_DESIGN.md`, `API_DESIGN.md` và `UI_UX_GUIDELINES.md`. Không chứa code — chỉ mô tả kế hoạch triển khai.

Nguyên tắc xuyên suốt roadmap: mỗi phase chỉ tạo file khi thực sự cần (theo `PROJECT_GUIDELINES.md`, mục 5 — không tạo thư mục/file rỗng trước), và không được coi là hoàn thành nếu chưa qua checklist review tương ứng.

---

# Phase 1 — Project Setup

## Mục tiêu
Khởi tạo dự án Flutter, cấu hình Firebase, thiết lập Git repository và các công cụ nền tảng cần thiết trước khi viết bất kỳ dòng logic nghiệp vụ nào.

## Các file sẽ tạo
- `pubspec.yaml` (khai báo dependencies: `provider`, `http` hoặc `dio`, `firebase_core`, `firebase_auth`, `cloud_firestore`).
- File cấu hình Firebase cho iOS (do FlutterFire CLI sinh ra, ví dụ `firebase_options.dart`, `GoogleService-Info.plist` trong `ios/Runner/`).
- `.gitignore` (rà soát, đảm bảo loại trừ file cấu hình nhạy cảm nếu cần).
- `README.md` (cập nhật hướng dẫn setup cơ bản).

## Kiến thức cần học
- Flutter CLI cơ bản (`flutter create`, `flutter pub get`, `flutter run`).
- Firebase Console: tạo project, bật Authentication (Email/Password), tạo Cloud Firestore (chế độ Test Mode tạm thời).
- FlutterFire CLI (`flutterfire configure`) để kết nối Flutter app với Firebase project.
- Git cơ bản: init repository, tạo remote GitHub, cấu hình branching strategy (ví dụ `main` + `develop` hoặc `main` + feature branch trực tiếp).

## Điều kiện hoàn thành
- Ứng dụng Flutter mặc định (`flutter run`) chạy được trên **iOS Simulator** không lỗi.
- Firebase project đã liên kết thành công, `firebase_core` khởi tạo được (`Firebase.initializeApp()` không throw lỗi khi chạy thử tạm thời) trên iOS Simulator.
- Repository GitHub đã tạo, commit đầu tiên đã đẩy lên thành công.

## Phụ thuộc phase nào
- Không phụ thuộc phase nào (phase khởi đầu).

## Checklist review trước khi sang phase tiếp theo
- [ ] `flutter analyze` không lỗi trên project rỗng mặc định.
- [ ] File cấu hình Firebase nhạy cảm không bị commit sai chỗ (kiểm tra `.gitignore`).
- [ ] Đã xác nhận rõ Firebase Authentication (Email/Password) và Cloud Firestore đã được bật trên Console.
- [ ] Branching strategy đã thống nhất và ghi chú lại (kể cả chỉ 1 người phát triển).

---

# Phase 2 — Folder Structure

## Mục tiêu
Thiết lập khung thư mục nền tảng (`core/`) theo đúng kiến trúc đã chốt ở `SYSTEM_ARCHITECTURE.md`, cùng các thành phần dùng chung tối thiểu (constants, theme, error types cơ bản) để các phase sau có nền tảng để xây dựng feature.

## Các file sẽ tạo
- `lib/core/constants/` — `api_constants.dart` (base URL, endpoint TheMealDB theo `API_DESIGN.md`), `firestore_paths.dart` (tên collection theo `DATABASE_DESIGN.md`), `app_strings.dart` (chuỗi text dùng chung).
- `lib/core/theme/` — định nghĩa màu sắc, typography, spacing token theo đúng `UI_UX_GUIDELINES.md`.
- `lib/core/errors/` — định nghĩa các loại Exception chuẩn hóa (`NetworkException`, `ApiException`, `AuthException`, `FirestoreException`, `ValidationException`) và App Status Code enum theo `API_DESIGN.md` (mục Status Code chuẩn hóa).
- `lib/app.dart` (khung `MaterialApp` tối thiểu, áp dụng theme vừa tạo, chưa có route thật).
- Thư mục rỗng có chủ đích cho `lib/features/` (chỉ tạo khi Phase 3+ cần file đầu tiên bên trong, không tạo trước các sub-folder `models/services/providers/screens` nếu chưa có nội dung).

## Kiến thức cần học
- Cấu trúc Theme trong Flutter (`ThemeData`, `ColorScheme`, `TextTheme`) và cách map với Light/Dark Mode.
- Cách tổ chức file constants tránh hard-code rải rác (đúng `PROJECT_GUIDELINES.md` mục API Rules).
- Khái niệm custom Exception class trong Dart.

## Điều kiện hoàn thành
- App chạy được với `MaterialApp` đã áp dụng theme tùy chỉnh (màu Primary/Secondary hiển thị đúng theo `UI_UX_GUIDELINES.md`), cả Light và Dark Mode chuyển đổi được theo hệ thống.
- Các file constants/errors đã sẵn sàng để import ở các phase sau, không còn giá trị "TODO" bỏ trống.

## Phụ thuộc phase nào
- Phase 1 (Project Setup).

## Checklist review trước khi sang phase tiếp theo
- [ ] Không có giá trị màu/spacing hard-code ngoài `core/theme/` khi thử nghiệm 1 màn hình mẫu.
- [ ] Thư mục `core/` khớp đúng với `SYSTEM_ARCHITECTURE.md` mục 4 (Folder Structure).
- [ ] Chưa tạo bất kỳ folder `features/*` nào còn trống không có file.
- [ ] `flutter analyze` không lỗi/warning.

---

# Phase 3 — Models

## Mục tiêu
Xây dựng toàn bộ Model class đại diện cho dữ liệu của hệ thống, đúng theo thiết kế ở `DATABASE_DESIGN.md`, làm nền tảng cho Service layer ở Phase 4.

## Các file sẽ tạo
- `lib/features/home/models/meal_model.dart` — `MealModel` (`fromJson` cho TheMealDB, các field: `idMeal`, `strMeal`, `strMealThumb`, nguyên liệu/hướng dẫn khi cần chi tiết).
- `lib/features/favorite/models/favorite_meal_model.dart` — `FavoriteMealModel` (`fromMap`/`toMap` cho Firestore, khớp field ở `DATABASE_DESIGN.md` mục 3.2: `idMeal`, `mealName`, `mealThumbnail`, `note`, `createdAt`, `updatedAt`).
- `lib/features/profile/models/user_profile_model.dart` — `UserProfileModel` (`fromMap`/`toMap`, khớp `DATABASE_DESIGN.md` mục 3.1: `uid`, `email`, `name`, `height`, `targetWeight`, `createdAt`, `updatedAt`).

## Kiến thức cần học
- Cách viết `fromJson`/`toJson` xử lý dữ liệu JSON lồng nhau và các field có thể `null` (đặc thù TheMealDB).
- Cách viết `fromMap`/`toMap` làm việc với `DocumentSnapshot` của Cloud Firestore, xử lý kiểu `Timestamp`.
- Null-safety trong Dart khi parse dữ liệu từ nguồn ngoài không đảm bảo đầy đủ field.

## Điều kiện hoàn thành
- Mỗi Model có thể khởi tạo từ dữ liệu mẫu (JSON mẫu từ TheMealDB, Map mẫu mô phỏng Firestore) mà không throw lỗi khi test thủ công (in ra console tạm thời, chưa cần gắn UI).
- Model không chứa bất kỳ logic gọi mạng/Firebase nào (chỉ thuần cấu trúc dữ liệu + chuyển đổi).

## Phụ thuộc phase nào
- Phase 2 (Folder Structure — cần `core/constants` để tham chiếu tên field/path nếu áp dụng).

## Checklist review trước khi sang phase tiếp theo
- [ ] Mỗi Model có đúng 1 class chính trong 1 file (đúng `PROJECT_GUIDELINES.md` mục Coding Standards).
- [ ] Đã xử lý trường hợp `meals: null` từ TheMealDB không làm crash khi parse danh sách rỗng.
- [ ] Không có field kiểu `dynamic` tùy tiện trong Model.
- [ ] Naming field khớp đúng bảng thuộc tính ở `DATABASE_DESIGN.md`.

---

# Phase 4 — Services

## Mục tiêu
Xây dựng tầng Service — nơi duy nhất giao tiếp trực tiếp với TheMealDB REST API và Firebase SDK, trả về dữ liệu đã parse thành Model hoặc Exception chuẩn hóa.

## Các file sẽ tạo
- `lib/features/home/services/meal_api_service.dart` — gọi 4 endpoint TheMealDB đã liệt kê ở `API_DESIGN.md` (default list, search, filter, detail).
- `lib/features/auth/services/auth_service.dart` — bọc `FirebaseAuth` (`register`, `login`, `logout`, `authStateChanges` stream), khớp Logical Endpoint mục Authentication trong `API_DESIGN.md`.
- `lib/services/firestore_service.dart` — Service Firestore dùng chung, thao tác trên `users/{uid}` và `users/{uid}/favorites/{idMeal}` theo đúng path ở `DATABASE_DESIGN.md`.
- `lib/core/network/http_client.dart` (tùy chọn) — wrapper cấu hình timeout, base URL chung cho `http`/`dio`.

## Kiến thức cần học
- Package `http` hoặc `dio`: GET request, xử lý timeout, xử lý mã lỗi HTTP.
- Firebase Authentication SDK: `createUserWithEmailAndPassword`, `signInWithEmailAndPassword`, `signOut`, `authStateChanges()`.
- Cloud Firestore SDK: `doc().set()/get()/update()/delete()`, `collection().snapshots()` (Stream), Firestore Transaction cơ bản (dùng cho toggle favorite theo `DATABASE_DESIGN.md` mục 11).
- Cách map exception gốc (`FirebaseAuthException`, `FirebaseException`, `SocketException`, `TimeoutException`) sang Exception chuẩn hóa đã định nghĩa ở Phase 2.

## Điều kiện hoàn thành
- Từng method của mỗi Service có thể gọi thử độc lập (qua test thủ công/console) và trả về đúng Model hoặc ném đúng loại Exception chuẩn hóa khi giả lập lỗi (tắt mạng, sai thông tin).
- Không có Service nào chứa `BuildContext` hoặc bất kỳ tham chiếu nào tới Widget.

## Phụ thuộc phase nào
- Phase 3 (Models), Phase 2 (constants, error types).

## Checklist review trước khi sang phase tiếp theo
- [ ] Mọi lời gọi async ra ngoài đều có `try-catch` map lỗi đúng chuẩn `core/errors/`.
- [ ] Timeout đã được áp dụng cho các request TheMealDB (10–15s theo `SYSTEM_ARCHITECTURE.md`).
- [ ] Document ID Favorite dùng đúng `idMeal` (không dùng auto-ID), đúng `DATABASE_DESIGN.md` mục 4.
- [ ] Không có logic điều phối nghiệp vụ (business logic) nằm trong Service — chỉ có thao tác dữ liệu thô.

---

# Phase 5 — Authentication

## Mục tiêu
Triển khai đầy đủ luồng đăng ký/đăng nhập/đăng xuất và điều hướng dựa trên Auth State, theo đúng `BUSINESS_FLOW.md` mục 1 và `SYSTEM_ARCHITECTURE.md` mục 13.

## Các file sẽ tạo
- `lib/features/auth/providers/auth_provider.dart` — `ChangeNotifier` quản lý trạng thái đăng nhập, lắng nghe `authStateChanges()`.
- `lib/features/auth/screens/splash_screen.dart`.
- `lib/features/auth/screens/login_screen.dart` + widget con (form field theo `UI_UX_GUIDELINES.md` mục TextField Design).
- `lib/features/auth/screens/register_screen.dart` + widget con.
- Cập nhật `app.dart` — cấu hình route/điều hướng dựa trên `AuthProvider` (Splash → Login/Home).

## Kiến thức cần học
- `ChangeNotifier` + `Consumer`/`context.watch` trong package `provider`.
- `StreamBuilder` hoặc lắng nghe Stream thủ công trong Provider để phản ứng với `authStateChanges()`.
- `FormState`/`TextFormField` validator (email regex, độ dài password) theo `PROJECT_REQUIREMENTS.md` FR-AUTH-05/06/07.
- Điều hướng có điều kiện (route guard) trong Flutter Navigator.

## Điều kiện hoàn thành
- Đăng ký tài khoản mới thành công → tạo document `users/{uid}` → vào thẳng Home.
- Đăng nhập đúng/sai thông tin đều phản hồi đúng theo Acceptance Criteria ở `PROJECT_REQUIREMENTS.md` (mục Authentication).
- Mở lại app sau khi đã đăng nhập trước đó → vào thẳng Home, không cần đăng nhập lại (FR-AUTH-02).
- Đăng xuất → quay về Login, state được reset.

## Phụ thuộc phase nào
- Phase 4 (AuthService), Phase 2 (theme cho form UI).

## Checklist review trước khi sang phase tiếp theo
- [ ] Toàn bộ Acceptance Criteria mục Authentication trong `PROJECT_REQUIREMENTS.md` đã pass khi test thủ công.
- [ ] UI/UX form khớp `UI_UX_GUIDELINES.md` (Outlined TextField, Primary Button full-width, validation inline).
- [ ] Không có màn hình nào trong Home/Favorite/Profile truy cập được khi chưa đăng nhập (BR-06).
- [ ] `AuthProvider` không giữ `BuildContext`, không có business logic UI lẫn vào.

---

# Phase 6 — Home

## Mục tiêu
Hiển thị danh sách món ăn mặc định và xây dựng màn hình Meal Detail dạng xem (view-only, chưa có logic yêu thích), theo `BUSINESS_FLOW.md` mục 2 và 4.

## Các file sẽ tạo
- `lib/features/home/providers/meal_provider.dart` — quản lý trạng thái danh sách món ăn (`ViewStatus`: idle/loading/success/error).
- `lib/features/home/screens/home_screen.dart` + `widgets/meal_grid.dart`, `widgets/meal_card.dart` (theo `UI_UX_GUIDELINES.md` mục Card Design, Grid System).
- `lib/features/meal_detail/screens/meal_detail_screen.dart` (view-only ở phase này: ảnh, tên, nguyên liệu, hướng dẫn, calo — chưa có nút yêu thích hoạt động).
- `lib/core/widgets/loading_indicator.dart`, `lib/core/widgets/error_view.dart` (dùng chung, khởi tạo lần đầu ở đây, tái sử dụng cho các phase sau).

## Kiến thức cần học
- `GridView.builder` cho danh sách món ăn (theo `SYSTEM_ARCHITECTURE.md` mục Performance Rules).
- `Image.network` hiển thị ảnh từ URL, xử lý trạng thái loading/lỗi ảnh.
- Truyền dữ liệu giữa màn hình (Navigator, truyền `idMeal` sang Meal Detail).
- Pattern trạng thái thống nhất (`ViewStatus` enum) áp dụng cho Provider — nền tảng dùng lại ở mọi phase sau.

## Điều kiện hoàn thành
- Vào Home tự động fetch và hiển thị đúng danh sách mặc định (`search.php?f=b`) theo FR-HOME-01/02.
- Trạng thái loading/error hiển thị đúng theo `UI_UX_GUIDELINES.md` (Skeleton hoặc spinner, Error View kèm nút Thử lại).
- Chọn 1 món ăn → xem đúng chi tiết đầy đủ (nguyên liệu, hướng dẫn, calo) ở Meal Detail.

## Phụ thuộc phase nào
- Phase 4 (MealApiService), Phase 3 (MealModel), Phase 2 (widget/theme nền tảng).

## Checklist review trước khi sang phase tiếp theo
- [ ] `ListView.builder`/`GridView.builder` được dùng đúng chỗ, không dựng sẵn toàn bộ danh sách.
- [ ] Trạng thái Empty (nếu có) đã phân biệt rõ với Error (dù ở default list hiếm khi rỗng, vẫn cần xử lý an toàn).
- [ ] `LoadingIndicator`/`ErrorView` là widget dùng chung, không viết lặp lại logic hiển thị loading/error ở từng màn hình.
- [ ] UI khớp `UI_UX_GUIDELINES.md` (Meal Card tỷ lệ ảnh nhất quán, AppBar overlay ở Detail).

---

# Phase 7 — Search

## Mục tiêu
Bổ sung chức năng tìm kiếm theo tên và lọc theo danh mục vào màn hình Home, theo `BUSINESS_FLOW.md` mục 3.

## Các file sẽ tạo
- Cập nhật `lib/features/home/providers/meal_provider.dart` — thêm method `searchMeals(keyword)`, `filterByCategory(category)`.
- `lib/features/home/screens/widgets/search_bar_widget.dart`.
- `lib/features/home/screens/widgets/category_filter_widget.dart` (dạng Chip, theo `UI_UX_GUIDELINES.md` mục Border Radius — pill shape).
- Cập nhật `home_screen.dart` để tích hợp thanh Search + bộ lọc danh mục.

## Kiến thức cần học
- Debounce input khi gõ tìm kiếm (tránh gọi API liên tục mỗi ký tự — cân nhắc dùng `Timer` đơn giản, không cần package ngoài).
- Xử lý logic loại trừ lẫn nhau giữa Search và Filter (theo đề xuất ở `BUSINESS_FLOW.md`: chọn category thì xóa từ khóa search và ngược lại).
- Phân biệt trạng thái "kết quả rỗng" và "lỗi" trong UI (theo `API_DESIGN.md` mục Search).

## Điều kiện hoàn thành
- Tìm kiếm theo tên trả đúng kết quả khớp/rỗng theo FR-SEARCH-01/02/03.
- Lọc theo danh mục trả đúng kết quả theo FR-SEARCH-04/05.
- Không thể áp dụng đồng thời Search và Filter gây trạng thái mập mờ (đã xử lý theo đề xuất Business Rule).

## Phụ thuộc phase nào
- Phase 6 (Home — tái sử dụng `MealProvider`, `HomeScreen`, `MealDetailScreen`).

## Checklist review trước khi sang phase tiếp theo
- [ ] Không gọi API khi từ khóa rỗng.
- [ ] Empty State khi tìm kiếm không ra kết quả khớp đúng `UI_UX_GUIDELINES.md` (không dùng chung UI với Error State).
- [ ] Việc chọn Filter tự động xóa Search và ngược lại, đã test thủ công xác nhận.
- [ ] `flutter analyze` sạch, không còn TODO bỏ dở.

---

# Phase 8 — Favorite

## Mục tiêu
Triển khai đầy đủ CRUD danh sách yêu thích (Create/Read/Update/Delete) và bổ sung logic nút yêu thích vào Meal Detail đã xây ở Phase 6, theo `BUSINESS_FLOW.md` mục 4 và 5, `DATABASE_DESIGN.md`, `API_DESIGN.md` mục Favorite.

## Các file sẽ tạo
- `lib/features/favorite/repositories/favorite_repository.dart` — điều phối `FirestoreService`, xử lý toggle (Create/Delete) trong Transaction theo `DATABASE_DESIGN.md` mục 11.
- `lib/features/favorite/providers/favorite_provider.dart` — quản lý danh sách real-time (lắng nghe `snapshots()`), trạng thái toggle, trạng thái ghi chú.
- `lib/features/favorite/screens/favorite_screen.dart` + `widgets/favorite_list_item.dart` (dạng hàng ngang, hỗ trợ swipe-to-delete theo `UI_UX_GUIDELINES.md`).
- `lib/features/favorite/screens/widgets/note_editor.dart` (hoặc Bottom Sheet chỉnh ghi chú).
- Cập nhật `lib/features/meal_detail/screens/meal_detail_screen.dart` — thêm icon trái tim hoạt động, gắn `favorite_provider`.
- Cập nhật `lib/features/meal_detail/providers/meal_detail_provider.dart` (tạo mới nếu chưa có) — quản lý trạng thái đã lưu/chưa lưu của món đang xem.

## Kiến thức cần học
- Firestore real-time listener (`snapshots()`) và cách hủy đăng ký (`dispose`) đúng cách để tránh memory leak.
- Firestore Transaction để đảm bảo toggle favorite an toàn khi có race condition.
- `Dismissible` widget (swipe-to-delete) trong Flutter.
- Snackbar kèm hành động Undo (theo `UI_UX_GUIDELINES.md` mục Snackbar).

## Điều kiện hoàn thành
- Toàn bộ Acceptance Criteria mục Meal Detail/Favorite trong `PROJECT_REQUIREMENTS.md` pass khi test thủ công (toggle, xem danh sách, sửa ghi chú, xóa).
- Danh sách Favorite cập nhật ngay khi có thay đổi mà không cần pull-to-refresh (real-time đúng FR-FAV-06).
- Không tạo được bản ghi trùng lặp cho cùng `idMeal` (BR-02 được thực thi đúng, kể cả khi bấm nhanh liên tục).

## Phụ thuộc phase nào
- Phase 4 (FirestoreService), Phase 5 (cần `uid` từ Auth), Phase 6 (Meal Detail Screen đã có sẵn để bổ sung logic).

## Checklist review trước khi sang phase tiếp theo
- [ ] Toggle favorite đã test race condition (bấm nhanh liên tục nhiều lần) không tạo dữ liệu sai.
- [ ] Listener Firestore được hủy đúng lifecycle (không rò rỉ khi rời màn hình).
- [ ] Ghi chú có giới hạn độ dài theo đề xuất ở `BUSINESS_FLOW.md`.
- [ ] Empty State khi chưa có Favorite nào đúng theo `UI_UX_GUIDELINES.md`.

---

# Phase 9 — Profile

## Mục tiêu
Triển khai xem và cập nhật hồ sơ cá nhân, cùng chức năng đăng xuất, theo `BUSINESS_FLOW.md` mục 6.

## Các file sẽ tạo
- `lib/features/profile/providers/profile_provider.dart`.
- `lib/features/profile/screens/profile_screen.dart` + widget form (tên, chiều cao, cân nặng mục tiêu).
- Cập nhật `lib/app.dart` — hoàn thiện Bottom Navigation 3 tab (Home, Favorite, Profile) theo `UI_UX_GUIDELINES.md`.

## Kiến thức cần học
- `TextFormField` với `TextInputType.number` và validator số dương (BR-04).
- Cập nhật một phần document Firestore (`update()` chỉ field thay đổi) thay vì ghi đè toàn bộ (`set()`).
- `BottomNavigationBar`/`NavigationBar` (Material 3) và quản lý state tab đang chọn.

## Điều kiện hoàn thành
- Đọc đúng thông tin hồ sơ hiện tại khi vào màn hình (FR-PROFILE-01).
- Cập nhật tên/chiều cao/cân nặng thành công, validate đúng theo BR-04 (FR-PROFILE-02–05).
- Đăng xuất từ Profile hoạt động đúng, quay về Login (FR-PROFILE-06, liên kết Phase 5).
- Bottom Navigation hoạt động mượt giữa 3 tab, giữ đúng trạng thái mỗi tab khi chuyển qua lại (tuỳ mức độ, có thể chấp nhận rebuild đơn giản cho MVP).

## Phụ thuộc phase nào
- Phase 4 (FirestoreService), Phase 5 (Auth — logout, uid).

## Checklist review trước khi sang phase tiếp theo
- [ ] Validate chiều cao/cân nặng chặn đúng giá trị 0/âm trước khi gọi Firestore.
- [ ] Cập nhật hồ sơ dùng `update()` một phần, không ghi đè toàn bộ document.
- [ ] Đăng xuất từ Profile dẫn đúng về Login và reset toàn bộ state cá nhân (Favorite, Profile) của phiên trước.
- [ ] Bottom Navigation đúng 3 tab, icon/label khớp `UI_UX_GUIDELINES.md`.

---

# Phase 10 — Firebase/API (Hardening & Integration)

## Mục tiêu
Không phải xây tính năng mới — đây là phase "siết chặt" toàn bộ tích hợp Firebase/API đã xây rải rác ở Phase 4–9: cấu hình Firestore Security Rules chính thức, kiểm tra lại toàn bộ endpoint TheMealDB đang dùng đúng như `API_DESIGN.md`, và xác nhận không còn cấu hình ở chế độ Test Mode.

## Các file sẽ tạo
- Cấu hình Firestore Security Rules trên Firebase Console (hoặc file `firestore.rules` nếu quản lý qua Firebase CLI) — quy định chỉ chủ sở hữu `uid` mới đọc/ghi được `users/{uid}` và `users/{uid}/favorites/**`, theo đúng Authorization đã mô tả ở `API_DESIGN.md`.
- Không tạo thêm file Dart mới ở phase này — đây là phase rà soát/cấu hình, không phải phase code tính năng.

## Kiến thức cần học
- Cú pháp Firestore Security Rules cơ bản (`match`, `request.auth.uid`, `allow read/write`).
- Cách kiểm thử Security Rules (Firebase Console Rules Playground, hoặc thử bằng tài khoản thứ hai để xác nhận không đọc được dữ liệu người khác).
- Cách kiểm tra quota/giới hạn gói miễn phí Firebase (Spark Plan) để tránh vượt hạn mức khi test nhiều lần.

## Điều kiện hoàn thành
- Firestore không còn ở chế độ Test Mode (`allow read, write: if true` đã bị gỡ bỏ hoàn toàn).
- Dùng 2 tài khoản test khác nhau, xác nhận tài khoản A không đọc/ghi được dữ liệu `favorites`/`users` của tài khoản B (test thủ công).
- Toàn bộ 4 endpoint TheMealDB đã dùng đúng URL/tham số như liệt kê ở `API_DESIGN.md`, không còn sai lệch do sao chép/gõ tay trong quá trình code từng phase riêng lẻ.

## Phụ thuộc phase nào
- Phase 5, 6, 7, 8, 9 (toàn bộ feature đã tích hợp Firebase/API phải tồn tại trước để có gì đó để hardening).

## Checklist review trước khi sang phase tiếp theo
- [ ] Security Rules đã áp dụng đúng Business Rule BR-01/BR-03 (dữ liệu cá nhân không rò rỉ chéo user).
- [ ] Đã thử nghiệm với tài khoản thứ hai để xác nhận cách ly dữ liệu.
- [ ] Không còn API key/thông tin nhạy cảm bị commit sai vị trí (rà soát lại `.gitignore` một lần nữa).
- [ ] Ghi chú lại cấu hình Rules vào README hoặc tài liệu nội bộ để không bị quên khi demo.

---

# Phase 11 — Error Handling

## Mục tiêu
Rà soát và chuẩn hóa toàn bộ luồng xử lý lỗi xuyên suốt ứng dụng, đảm bảo khớp hoàn toàn với Error Flow đã thiết kế ở `SYSTEM_ARCHITECTURE.md` mục 11 và App Status Code ở `API_DESIGN.md`.

## Các file sẽ tạo
- Không tạo file hoàn toàn mới — chủ yếu rà soát/hoàn thiện `lib/core/errors/` (đảm bảo đủ mọi loại Exception đã dùng đúng nhất quán ở mọi Service/Provider từ Phase 4–9).
- Có thể bổ sung `lib/core/errors/error_mapper.dart` nếu logic map lỗi đang bị lặp lại rải rác ở nhiều Provider (refactor tập trung).

## Kiến thức cần học
- Kỹ thuật tập trung hóa logic xử lý lỗi (centralized error mapping) để tránh lặp code `try-catch` với nội dung message khác nhau ở mỗi Provider.
- Cách phân biệt lỗi cần hiển thị `SnackBar` (thao tác cục bộ) và lỗi cần hiển thị `ErrorView` toàn màn hình (tải dữ liệu chính thất bại) — theo `UI_UX_GUIDELINES.md` mục Error State.

## Điều kiện hoàn thành
- Test thủ công tắt Wi-Fi/Mobile Data ở từng màn hình (Home, Search, Favorite, Profile, Login) — mọi trường hợp đều hiển thị lỗi thân thiện, không crash, không đứng màn hình trắng.
- Test thủ công các trường hợp lỗi nghiệp vụ cụ thể: sai mật khẩu, email đã tồn tại, `idMeal` không tồn tại (BR liên quan) — message hiển thị đúng, không lộ chi tiết kỹ thuật.
- Không còn bất kỳ nơi nào trong code có `catch (e) {}` bỏ trống không xử lý gì (nuốt lỗi im lặng).

## Phụ thuộc phase nào
- Phase 5, 6, 7, 8, 9 (mọi feature phải tồn tại để có luồng lỗi thật để rà soát).

## Checklist review trước khi sang phase tiếp theo
- [ ] Đã test đủ các kịch bản lỗi liệt kê ở `BUSINESS_FLOW.md` (Exception) cho từng module.
- [ ] Message lỗi hiển thị bằng ngôn ngữ thân thiện, không có thuật ngữ kỹ thuật (theo `UI_UX_GUIDELINES.md` mục Error State).
- [ ] Log lỗi (`debugPrint`) đã có mặt ở mọi nơi bắt exception quan trọng, phục vụ debug (theo `PROJECT_GUIDELINES.md` mục Logging).
- [ ] Không có exception nào rò rỉ lên UI dưới dạng raw (đỏ màn hình debug Flutter khi chạy release/profile mode).

---

# Phase 12 — Loading

## Mục tiêu
Chuẩn hóa và hoàn thiện trạng thái loading trên toàn bộ ứng dụng theo `UI_UX_GUIDELINES.md` mục Loading, đảm bảo trải nghiệm nhất quán giữa các màn hình.

## Các file sẽ tạo
- Không tạo file tính năng mới — rà soát/hoàn thiện `lib/core/widgets/loading_indicator.dart` đã tạo ở Phase 6, đảm bảo được tái sử dụng đúng ở mọi Provider (`ViewStatus.loading`) thay vì mỗi màn hình tự viết loading riêng.
- (Tùy chọn nếu còn thời gian) `lib/core/widgets/skeleton_loader.dart` — nâng cấp từ spinner đơn thuần sang Skeleton Loading cho Home/Favorite theo gợi ý ở `UI_UX_GUIDELINES.md`.

## Kiến thức cần học
- Kỹ thuật Skeleton Loading trong Flutter (dùng `Container` với hiệu ứng shimmer đơn giản, hoặc chấp nhận phương án tối giản `CircularProgressIndicator` nếu thời gian hạn chế — đã ghi rõ là phương án chấp nhận được ở `UI_UX_GUIDELINES.md`).
- Cách tránh hiển thị nhiều loading indicator chồng lấn khi nhiều thao tác async xảy ra gần nhau.

## Điều kiện hoàn thành
- Mọi thao tác async có độ trễ (fetch danh sách, submit form, lưu ghi chú) đều có phản hồi loading rõ ràng, không có khoảng thời gian "im lặng" khiến người dùng tưởng app treo.
- Loading trên nút (Button loading state, theo `UI_UX_GUIDELINES.md` mục Button Design) đã áp dụng cho các nút Submit quan trọng (Login, Register, Save Profile, Save Note).
- Không còn 2 loading indicator hiển thị chồng nhau trong cùng một thao tác.

## Phụ thuộc phase nào
- Phase 6 (LoadingIndicator nền tảng), Phase 5–9 (mọi feature đã có để rà soát áp dụng nhất quán).

## Checklist review trước khi sang phase tiếp theo
- [ ] Danh sách các thao tác async đã kiểm tra đều có loading state (đối chiếu với bảng State Changes ở `BUSINESS_FLOW.md` từng module).
- [ ] Không có thao tác nào cho phép bấm lặp lại trong lúc đang loading (ví dụ bấm Submit nhiều lần liên tục).
- [ ] Giao diện loading nhất quán về màu sắc/kiểu dáng trên toàn app (dùng chung `LoadingIndicator`, không có biến thể tự chế ở từng màn hình).

---

# Phase 13 — Testing

## Mục tiêu
Kiểm thử toàn diện ứng dụng trên **iOS Simulator**, đối chiếu với toàn bộ Acceptance Criteria trong `PROJECT_REQUIREMENTS.md`. Đây là bước kiểm thử trong giai đoạn phát triển MVP trên máy MacBook — việc build APK và kiểm thử trên thiết bị Android thật theo đúng yêu cầu gốc của đề bài (Giai đoạn 5, PRM393) sẽ do một thành viên khác thực hiện ở **bước bàn giao sau Phase 15** (xem `PROJECT_REQUIREMENTS.md` mục Constraints/điểm 9), không nằm trong 15 phase của roadmap này.

## Các file sẽ tạo
- Không bắt buộc tạo file test tự động cho MVP (theo tinh thần KISS, không over-engineering) — tập trung vào kiểm thử thủ công có hệ thống.
- (Tùy chọn nếu có thời gian dư) một số Unit Test cơ bản cho Model (`fromJson`/`fromMap`) trong `test/` — vì đây là phần dễ viết test nhất và giá trị cao (đảm bảo parse dữ liệu đúng), không cần test toàn bộ Widget/Provider cho MVP.
- File checklist kiểm thử thủ công (có thể là 1 bảng trong README hoặc tài liệu nội bộ, không bắt buộc là file `.dart`).

## Kiến thức cần học
- Cách chạy ứng dụng trên iOS Simulator từ Xcode hoặc `flutter run -d <simulator_id>`, cách liệt kê Simulator khả dụng (`xcrun simctl list devices`).
- Cách build bản release cho iOS Simulator (`flutter build ios --simulator`) và các cấu hình Signing/Capabilities cơ bản trong Xcode (dù chạy Simulator không cần chữ ký thật).
- Cách mô phỏng các kích thước màn hình iPhone khác nhau trên Simulator (ví dụ iPhone SE, iPhone 15 Pro Max) để kiểm tra responsive.
- Cách mô phỏng mất mạng trên Simulator (tắt Wi-Fi trên máy Mac chạy Simulator, hoặc dùng Network Link Conditioner) — vì Simulator dùng chung kết nối mạng của máy host, không có network riêng như thiết bị thật.
- (Nếu viết Unit Test) package `flutter_test`, cách viết test case đơn giản cho hàm parse dữ liệu thuần (không cần mock phức tạp).

## Điều kiện hoàn thành
- Ứng dụng chạy ổn định trên iOS Simulator (tối thiểu 1 cấu hình iPhone, khuyến nghị test thêm 1 màn hình nhỏ và 1 màn hình lớn nếu có thời gian).
- Toàn bộ Acceptance Criteria trong `PROJECT_REQUIREMENTS.md` (Authentication, Home/Search/Filter, Meal Detail/Favorite, Profile) đã được kiểm thử thủ công trên iOS Simulator và pass.
- Không phát hiện crash, không tràn viền UI, không lỗi hiển thị nghiêm trọng trong quá trình test.
- Test cả kịch bản mất mạng (mô phỏng trên Simulator) khi đang dùng app.
- **Giới hạn đã biết và chấp nhận cho MVP:** Simulator không kiểm tra được hiệu năng phần cứng thật, cảm ứng đa điểm thật, camera/cảm biến thật — các khía cạnh này không thuộc phạm vi kiểm thử của MVP hiện tại.

## Phụ thuộc phase nào
- Toàn bộ Phase 1–12 (cần ứng dụng hoàn chỉnh về chức năng và error/loading handling trước khi test toàn diện).

## Checklist review trước khi sang phase tiếp theo
- [ ] Đã lập danh sách kiểm thử dựa trên toàn bộ Acceptance Criteria và đánh dấu Pass/Fail cho từng mục.
- [ ] Mọi Fail đã được ghi nhận, sửa, và test lại (không mang bug đã biết sang phase Polish).
- [ ] Đã test trên ít nhất 1 cấu hình iOS Simulator, lý tưởng là thêm 1 cấu hình màn hình khác để kiểm tra responsive.
- [ ] Ứng dụng chạy được từ đầu trên Simulator sạch (đã xóa app cũ/reset Simulator) để loại trừ lỗi do cache/state cũ.

---

# Phase 14 — Polish UI

## Mục tiêu
Áp dụng đầy đủ và nhất quán toàn bộ `UI_UX_GUIDELINES.md` trên mọi màn hình — hoàn thiện chi tiết thị giác sau khi chức năng đã ổn định và được kiểm thử ở Phase 13.

## Các file sẽ tạo
- Không tạo màn hình mới — chỉnh sửa các file Screen/Widget đã có ở Phase 5–9 để khớp chuẩn thiết kế.
- Có thể bổ sung thêm widget dùng chung còn thiếu vào `lib/core/widgets/` (ví dụ `empty_state_view.dart` nếu chưa tách riêng khỏi logic màn hình cụ thể).

## Kiến thức cần học
- Kỹ thuật animation cơ bản trong Flutter (`AnimatedContainer`, `AnimatedScale` cho hiệu ứng nhấn icon trái tim theo `UI_UX_GUIDELINES.md` mục Animation Guidelines).
- Kiểm tra tương phản màu sắc (WCAG AA) bằng công cụ kiểm tra contrast ratio.
- Kiểm thử font scaling (tăng cỡ chữ hệ thống lên 130%) để đảm bảo không vỡ layout, theo `UI_UX_GUIDELINES.md` mục Accessibility.

## Điều kiện hoàn thành
- Toàn bộ màn hình đã áp dụng đúng Color Palette, Typography, Spacing, Border Radius, Shadow theo tài liệu thiết kế — không còn màn hình nào dùng giá trị mặc định chưa tùy biến.
- Dark Mode hoạt động đúng và đẹp trên toàn bộ màn hình, không có vùng bị "lệch tông" (ví dụ nền trắng sót lại trong Dark Mode).
- Empty State và Error State đã có thiết kế riêng biệt, nhất quán trên mọi màn hình áp dụng (không còn màn hình trắng trơn khi rỗng).
- Animation áp dụng đúng mức độ tối giản đã quy định (150–250ms, không lạm dụng).

## Phụ thuộc phase nào
- Phase 13 (Testing — chỉ polish sau khi chức năng đã xác nhận đúng, tránh polish rồi phải sửa lại do bug chức năng).

## Checklist review trước khi sang phase tiếp theo
- [ ] Đối chiếu từng mục trong `UI_UX_GUIDELINES.md` với ứng dụng thật, đánh dấu đã áp dụng đầy đủ.
- [ ] Test Dark Mode trên toàn bộ màn hình chính (Home, Search, Detail, Favorite, Profile, Auth).
- [ ] Test tăng cỡ chữ hệ thống, xác nhận không vỡ layout nghiêm trọng.
- [ ] Vùng chạm các nút/icon quan trọng đã đủ ≥44pt trên iOS (kiểm tra bằng mắt trên iOS Simulator; lưu ý Simulator không mô phỏng chính xác cảm giác chạm thật bằng ngón tay, đây là giới hạn đã chấp nhận cho MVP).

---

# Phase 15 — Refactor

## Mục tiêu
Dọn dẹp và tối ưu code trước khi hoàn thiện dự án — đóng gói các thành phần UI trùng lặp thành Reusable Widget, đảm bảo đạt điểm tối đa tiêu chí kiến trúc theo đề bài gốc (20đ), và rà soát lần cuối theo `PROJECT_GUIDELINES.md`.

## Các file sẽ tạo
- Không tạo file tính năng mới — có thể tạo thêm vài file trong `lib/core/widgets/` nếu phát hiện logic UI lặp lại ≥3 lần cần rút thành widget chung (đúng nguyên tắc DRY ở mức hợp lý, không rút gọn quá sớm).
- Không tạo file mới cho mục đích "làm đẹp kiến trúc" nếu không có duplication thật sự cần giải quyết.

## Kiến thức cần học
- Kỹ thuật refactor an toàn (behavior-preserving): tách widget, rút hàm dùng chung mà không làm thay đổi hành vi ứng dụng.
- Cách dùng `flutter analyze` và đọc cảnh báo lint để dọn code sạch tuyệt đối trước khi nộp bài.
- Kỹ năng đọc lại Code Review Checklist ở `PROJECT_GUIDELINES.md` mục 16 và tự đánh giá khách quan.

## Điều kiện hoàn thành
- Toàn bộ Code Review Checklist ở `PROJECT_GUIDELINES.md` (mục 16) đã được rà soát và đạt.
- Không còn `print()` sót lại, không còn code debug tạm, không còn import thừa/biến không dùng.
- Các đoạn UI lặp lại rõ ràng (≥3 nơi giống hệt nhau) đã được rút thành widget chung, không còn copy-paste lộ liễu.
- `flutter analyze` chạy sạch hoàn toàn (0 warning, 0 error) trên toàn bộ project.
- Build cuối cùng chạy ổn định trên iOS Simulator, sẵn sàng cho buổi báo cáo (Live Demonstration).

## Phụ thuộc phase nào
- Phase 14 (Polish UI — refactor sau khi giao diện đã ổn định, tránh refactor rồi phải sửa lại do thay đổi UI sau đó).

## Checklist review trước khi sang phase tiếp theo
- [ ] Đã chạy qua toàn bộ Code Review Checklist ở `PROJECT_GUIDELINES.md` mục 16, không còn mục nào chưa đạt.
- [ ] Đã build lại lần cuối và test nhanh (smoke test) toàn bộ luồng chính trên iOS Simulator.
- [ ] Đã đối chiếu lần cuối codebase với `SYSTEM_ARCHITECTURE.md` (Dependency Rules) — không có vi phạm chiều phụ thuộc.
- [ ] Repository Git ở trạng thái sạch, commit cuối cùng đã mô tả đúng theo Conventional Commits, sẵn sàng cho buổi báo cáo.

> **Đây là phase cuối cùng của roadmap.** Sau Phase 15, dự án được coi là hoàn thành MVP theo đúng phạm vi đã xác lập ở `PROJECT_REQUIREMENTS.md` (build/test trên iOS Simulator).
>
> **Bước tiếp theo ngoài roadmap này (bàn giao Android):** Codebase hoàn chỉnh sẽ được gửi cho một thành viên khác có môi trường Android để build APK và kiểm thử trên thiết bị Android thật, đáp ứng đúng yêu cầu gốc của đề bài PRM393 (Giai đoạn 5) trước buổi Live Demonstration. Vì codebase đã giữ thuần Flutter/Material xuyên suốt 15 phase (theo `PROJECT_GUIDELINES.md` mục Architecture Rules), bước này về lý thuyết chỉ cần cấu hình lại Firebase cho Android và build, không cần viết lại logic — nhưng vẫn cần chủ động lên lịch sớm, không để sát deadline.

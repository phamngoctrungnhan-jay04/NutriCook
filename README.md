# NutriCook

Ứng dụng Flutter tra cứu công thức nấu ăn từ **TheMealDB API**, quản lý món ăn yêu thích, công thức cá nhân, và hồ sơ sức khỏe — tích hợp **Firebase** (Authentication, Firestore, Storage, Analytics, Crashlytics). Dự án thực hiện trong khuôn khổ môn PRM393.

---

## 1. Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter (Dart), Material 3 |
| State management | [provider](https://pub.dev/packages/provider) (`ChangeNotifier`) |
| Điều hướng | [go_router](https://pub.dev/packages/go_router) — `StatefulShellRoute` (Bottom Navigation giữ trạng thái từng tab) |
| Gọi REST API | [dio](https://pub.dev/packages/dio) + interceptor (log, retry, map lỗi) |
| Nguồn dữ liệu món ăn | [TheMealDB API](https://www.themealdb.com/api.php) (public, API key test `1`) |
| Xác thực | Firebase Authentication (Email/Password) |
| Lưu trữ dữ liệu người dùng | Cloud Firestore |
| Lưu ảnh đại diện | Cloud Storage |
| Theo dõi & báo lỗi | Firebase Analytics, Firebase Crashlytics |
| Chọn ảnh | image_picker |

## 2. Luồng kiến trúc

Phân tầng theo mỗi feature trong `lib/features/<tên_feature>/`:

```
Screen (Widget)  →  Provider (ChangeNotifier)  →  Repository (interface)  →  Service/DataSource (Dio hoặc Firebase SDK)
```

- **Screen**: chỉ render UI theo state, gọi method của Provider qua `context.read<T>()`, lắng nghe qua `context.watch<T>()`.
- **Provider**: giữ state (`idle/loading/success/error`), gọi Repository, không biết gì về Dio/Firestore.
- **Repository**: interface trừu tượng (Dependency Inversion) — cho phép đổi nguồn dữ liệu bên dưới mà không sửa Provider.
- **Service/DataSource**: nơi DUY NHẤT chạm vào Dio (TheMealDB) hoặc Firebase SDK (Auth/Firestore/Storage).

Composition root (nơi khởi tạo & nối toàn bộ Service → Repository → Provider) nằm ở [lib/app.dart](lib/app.dart) — dependency injection thủ công, không dùng DI container.

### Cấu trúc thư mục chính

```
lib/
├── core/                   # Dùng chung: theme, routing, network client, error, widget
└── features/
    ├── auth/               # Đăng ký / đăng nhập / quên mật khẩu (Firebase Auth)
    ├── home/                # Trang chủ: danh sách mặc định, tìm kiếm, lọc nguyên liệu (TheMealDB)
    ├── explore/             # Tab Khám phá: món ngẫu nhiên, lọc theo danh mục/vùng/nguyên liệu
    ├── meal_detail/         # Chi tiết món ăn: nguyên liệu, hướng dẫn, toggle yêu thích
    ├── favorite/            # CRUD món yêu thích + ghi chú cá nhân (Firestore, real-time)
    ├── custom_recipe/       # Công thức tự tạo của người dùng (Firestore, CRUD riêng)
    └── profile/             # Hồ sơ cá nhân, BMI, avatar (Firestore + Storage)
```

### Nguồn dữ liệu món ăn — 2 loại
1. **TheMealDB (REST API thật)** — `MealApiService` ([lib/features/home/services/meal_api_service.dart](lib/features/home/services/meal_api_service.dart)): search, filter theo category/area/ingredient, lookup chi tiết, món ngẫu nhiên, danh sách category/area/ingredient.
2. **Công thức tự tạo (Firestore)** — `CustomRecipeRepository` ([lib/features/custom_recipe/repositories/custom_recipe_repository.dart](lib/features/custom_recipe/repositories/custom_recipe_repository.dart)): lưu tại `users/{uid}/custom_recipes/{idMeal}`, dùng chung `MealModel` với dữ liệu từ TheMealDB nên tái sử dụng được toàn bộ UI (MealCard, MealDetail...).

Khi tìm kiếm/lọc ở Explore, kết quả là **gộp** giữa công thức cá nhân (ưu tiên hiện trước) và kết quả từ TheMealDB.

### Firebase — dữ liệu người dùng (`users/{uid}`)
- `users/{uid}` — hồ sơ (tên, chiều cao, cân nặng, avatar URL).
- `users/{uid}/favorites/{idMeal}` — món yêu thích + ghi chú cá nhân (real-time qua `snapshots()`), toggle bằng Firestore Transaction để tránh trùng khi bấm nhanh.
- `users/{uid}/custom_recipes/{idMeal}` — công thức tự tạo.
- Bảo mật: [firestore.rules](firestore.rules) / [storage.rules](storage.rules) — chỉ chủ tài khoản (`request.auth.uid`) mới đọc/ghi được dữ liệu của chính mình.

### Điều hướng
`AppRouter` ([lib/core/routing/app_router.dart](lib/core/routing/app_router.dart)) dùng `StatefulShellRoute.indexedStack` với 4 nhánh độc lập (Home, Explore, Favorite, Profile) — chuyển tab không mất trạng thái/scroll. Route Guard (`_redirect`) dựa vào `AuthStateNotifier` lắng nghe `FirebaseAuth.authStateChanges()` — chưa đăng nhập sẽ luôn bị đẩy về `/login`.

---

## 3. Yêu cầu môi trường

- Flutter SDK (kênh stable) — kiểm tra bằng `flutter doctor`.
- Một trong: Android Studio (emulator/SDK) hoặc thiết bị Android thật.
- Tài khoản Firebase (project đã cấu hình sẵn trong repo — xem mục 5).

## 4. Cách chạy dự án

```bash
# 1. Cài dependency
flutter pub get

# 2. Kiểm tra thiết bị khả dụng
flutter devices

# 3. Chạy app (thay <device_id> bằng ID lấy từ lệnh trên, ví dụ emulator-5554)
flutter run -d <device_id>
```

Kiểm tra code sạch trước khi commit/build:
```bash
flutter analyze
```

Build file cài đặt Android:
```bash
flutter build apk --debug     # bản debug, cài thử nhanh
flutter build apk --release   # bản release
```

## 5. Cấu hình Firebase

Project **đã được cấu hình sẵn** và commit trong repo (không cần tự tạo lại):
- [lib/firebase_options.dart](lib/firebase_options.dart) — sinh bởi `flutterfire configure`.
- [android/app/google-services.json](android/app/google-services.json) — cấu hình app Android.
- [firestore.rules](firestore.rules), [storage.rules](storage.rules) — Security Rules đã deploy.

> File cấu hình Firebase (`google-services.json`, `firebase_options.dart`) an toàn để commit theo tài liệu chính thức của Firebase — không phải bí mật, được bảo vệ bởi Security Rules ở tầng server.

Nếu bạn muốn kết nối sang Firebase project khác (ví dụ khi bàn giao dự án), cần cài [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) rồi chạy lại:
```bash
flutterfire configure
```

## 6. Tài liệu nghiệp vụ

Xem thư mục [project_roles/](project_roles/) — mô tả đầy đủ requirements, kiến trúc hệ thống, thiết kế database, API, business flow và roadmap phát triển theo từng giai đoạn của môn PRM393.

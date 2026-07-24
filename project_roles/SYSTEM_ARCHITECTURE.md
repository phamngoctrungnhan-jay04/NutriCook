# SYSTEM_ARCHITECTURE.md — NutriCook (PRM393)

Tài liệu này mô tả kiến trúc kỹ thuật toàn hệ thống cho NutriCook, triển khai các yêu cầu trong `PROJECT_REQUIREMENTS.md` và tuân thủ nguyên tắc trong `PROJECT_GUIDELINES.md`. Đây là tài liệu tham chiếu kỹ thuật cho việc triển khai, không chứa code.

---

## 1. Kiến trúc đề xuất

**Feature-first, Layered Architecture (3 tầng đơn giản hóa từ Clean Architecture)**, không dùng Clean Architecture đầy đủ (không có Use Case/Interactor layer riêng biệt, không có Entity tách khỏi Model).

Ba tầng chính:

```
┌─────────────────────────────────────────┐
│  Presentation Layer                      │
│  (Screens, Widgets, State Management)    │
└──────────────────┬────────────────────────┘
                    │ đọc/gọi
┌──────────────────▼────────────────────────┐
│  State / Application Layer                │
│  (Provider, ChangeNotifier, Controller)   │
└──────────────────┬────────────────────────┘
                    │ gọi
┌──────────────────▼────────────────────────┐
│  Data Layer                                │
│  (Service, Repository, Model)             │
└──────────────────┬────────────────────────┘
                    │ giao tiếp
┌──────────────────▼────────────────────────┐
│  External Systems                          │
│  (TheMealDB REST API, Firebase Auth,       │
│   Cloud Firestore)                         │
└─────────────────────────────────────────────┘
```

Ứng dụng client đơn (Flutter, không có backend tự viết) — mọi state phía server nằm ở Firebase (BaaS) và TheMealDB (public API bên thứ ba).

---

## 2. Vì sao chọn kiến trúc này

- **Quy mô dự án là MVP học thuật** với một sinh viên (khả năng thêm vài thành viên) và deadline theo 5 sprint cố định — Clean Architecture đầy đủ (Entity/UseCase/Repository/DTO tách biệt hoàn toàn) sẽ tạo quá nhiều boilerplate so với giá trị mang lại, vi phạm nguyên tắc KISS và "không over-engineering" đã nêu trong `PROJECT_GUIDELINES.md`.
- **Feature-first** (gom theo màn hình/tính năng: `auth/`, `home/`, `favorite/`, `profile/`) giúp dễ định vị code khi làm việc theo sprint (mỗi giai đoạn trong đề bài tương ứng gần như 1-1 với một feature), và dễ phân công nếu nhóm có nhiều hơn 1 thành viên.
- **Layered rõ 3 tầng** vẫn đảm bảo được yêu cầu barem điểm về "kiến trúc" (20đ theo đề bài) — UI tách khỏi logic gọi Firebase/API, dữ liệu tách khỏi trình bày — mà không cần học thêm khái niệm phức tạp (Use Case, Dependency Injection container nặng, Entity mapping 2 chiều).
- **Dễ mở rộng về sau**: khi dự án lớn hơn (ví dụ thêm backend riêng thay vì gọi thẳng Firebase từ client, hoặc thêm nhiều nguồn dữ liệu), ranh giới Data Layer (Service/Repository) đã tồn tại sẵn để thay thế implementation bên trong mà không ảnh hưởng Presentation/State layer — đúng nguyên lý Dependency Inversion ở mức tối thiểu cần thiết.
- **Phù hợp trình độ học tập**: kiến trúc dễ giải thích trong buổi báo cáo, dễ vẽ sơ đồ, giám khảo dễ đánh giá tính đúng đắn của phân tầng.

---

## 3. Layer Structure

### 3.1 Presentation Layer
- **Screens**: mỗi màn hình chính (Login, Register, Home, Search, MealDetail, Favorite, Profile) là một widget `StatelessWidget`/`StatefulWidget` cấp cao, chỉ chịu trách nhiệm bố cục và lắng nghe state.
- **Widgets**: các thành phần UI nhỏ, tái sử dụng được, không chứa business logic (ví dụ `MealCard`, `LoadingIndicator`, `ErrorView`, `EmptyStateView`).
- Presentation layer **không** gọi trực tiếp Firebase SDK hay `http`/`dio` — mọi tương tác dữ liệu đi qua State Layer.

### 3.2 State / Application Layer
- Chứa các class quản lý state (theo giải pháp đã chọn ở mục 9): `AuthProvider`, `MealProvider`, `FavoriteProvider`, `ProfileProvider`.
- Chịu trách nhiệm: gọi Repository/Service tương ứng, chuyển đổi kết quả thành trạng thái UI (`idle / loading / success / error`), expose state cho Presentation layer lắng nghe.
- Là nơi duy nhất chứa business logic điều phối (ví dụ: toggle favorite = kiểm tra đã tồn tại chưa rồi quyết định gọi Create hay Delete).

### 3.3 Data Layer
- **Model**: đại diện cấu trúc dữ liệu, có `fromJson`/`toJson` (cho REST API) và `fromMap`/`toMap` (cho Firestore). Ví dụ: `MealModel`, `UserProfileModel`, `FavoriteMealModel`.
- **Service**: bọc trực tiếp một nguồn dữ liệu ngoài cụ thể — không chứa business logic điều phối. Ví dụ: `MealApiService` (gọi TheMealDB), `AuthService` (gọi Firebase Auth), `FirestoreService` (thao tác Firestore thô).
- **Repository** (tùy chọn, dùng khi cần điều phối nhiều Service hoặc để tách interface phục vụ testing): ví dụ `FavoriteRepository` điều phối `FirestoreService` + logic transform dữ liệu trước khi trả về State layer.
- Data layer không biết gì về Widget hay `BuildContext`.

### 3.4 External Systems (ngoài phạm vi code của dự án, nhưng là một phần kiến trúc)
- TheMealDB REST API (đọc dữ liệu công khai, không xác thực).
- Firebase Authentication (quản lý danh tính người dùng).
- Cloud Firestore (lưu trữ `users`, `favorites`).

---

## 4. Folder Structure

Cấu trúc thư mục `lib/` theo mô hình **feature-first bên trong layered** — mỗi feature có đủ 3 tầng con của riêng nó, phần dùng chung tách ra `core/`:

```
lib/
├── main.dart
├── app.dart                        # MaterialApp, theme, route table
│
├── core/                           # Thành phần dùng chung toàn app
│   ├── constants/                  # api_constants, firestore_paths, app_strings
│   ├── theme/                      # màu sắc, typography
│   ├── errors/                     # custom Exception/Failure types dùng chung
│   ├── network/                    # http client wrapper, network exception mapping
│   └── widgets/                    # LoadingIndicator, ErrorView, EmptyStateView, PrimaryButton...
│
├── features/
│   ├── auth/
│   │   ├── models/                 # (nếu cần, ví dụ AuthResultModel)
│   │   ├── services/               # auth_service.dart (Firebase Auth wrapper)
│   │   ├── providers/              # auth_provider.dart
│   │   └── screens/                # splash_screen, login_screen, register_screen
│   │
│   ├── home/
│   │   ├── models/                 # meal_model.dart
│   │   ├── services/               # meal_api_service.dart
│   │   ├── providers/              # meal_provider.dart (list + search + filter state)
│   │   └── screens/                # home_screen.dart + widget riêng (meal_grid, search_bar, category_filter)
│   │
│   ├── meal_detail/
│   │   ├── providers/              # meal_detail_provider.dart (fetch chi tiết + trạng thái favorite)
│   │   └── screens/                # meal_detail_screen.dart
│   │
│   ├── favorite/
│   │   ├── models/                 # favorite_meal_model.dart
│   │   ├── repositories/           # favorite_repository.dart
│   │   ├── services/               # (dùng chung firestore_service ở core hoặc riêng)
│   │   ├── providers/              # favorite_provider.dart
│   │   └── screens/                # favorite_screen.dart + widget (favorite_list_item, note_editor)
│   │
│   └── profile/
│       ├── models/                 # user_profile_model.dart
│       ├── services/               # (dùng chung firestore_service)
│       ├── providers/              # profile_provider.dart
│       └── screens/                # profile_screen.dart
│
└── services/
    └── firestore_service.dart      # Service Firestore dùng chung (users, favorites) nếu không tách theo feature
```

**Ghi chú:**
- Nếu `FirestoreService` được nhiều feature dùng chung (auth cần tạo user doc, favorite cần đọc/ghi favorites, profile cần đọc/ghi thông tin cá nhân), đặt ở `lib/services/` (dùng chung toàn app) thay vì lặp lại trong từng feature.
- Không tạo sẵn các thư mục rỗng (`models/`, `repositories/`...) cho feature nào chưa cần đến — chỉ tạo khi có file thật.

---

## 5. Module Breakdown

| Module | Trách nhiệm chính | Phụ thuộc vào |
|---|---|---|
| **Auth** | Đăng ký, đăng nhập, đăng xuất, theo dõi Auth State, điều hướng ban đầu | Firebase Authentication |
| **Home** | Fetch danh sách món mặc định, hiển thị grid/list | TheMealDB API (`search.php?f=b`) |
| **Search & Filter** | Tìm kiếm theo tên, lọc theo danh mục (thuộc chung màn Home hoặc tab riêng) | TheMealDB API (`search.php?s=`, `filter.php?c=`) |
| **Meal Detail** | Hiển thị chi tiết món ăn, quản lý trạng thái nút yêu thích | TheMealDB API (`lookup.php?i=`), Favorite module |
| **Favorite** | CRUD danh sách món yêu thích + ghi chú cá nhân | Cloud Firestore (`users/{uid}/favorites`) |
| **Profile** | Xem/cập nhật thông tin cá nhân (tên, chiều cao, cân nặng) | Cloud Firestore (`users/{uid}`) |
| **Core** | Thành phần dùng chung: constants, theme, error handling, widget chung | Không phụ thuộc module khác (là nền tảng) |

Mối quan hệ giữa module: `Meal Detail` phụ thuộc vào dữ liệu trạng thái từ `Favorite` (để biết món hiện tại đã được lưu hay chưa); `Home`/`Search`/`Meal Detail` đều dùng chung `MealModel` từ module Home. Các module không phụ thuộc vòng tròn (circular dependency) lẫn nhau.

---

## 6. Data Flow

Luồng dữ liệu tổng quát tuân theo một chiều: **UI → State Layer → Data Layer → External System**, và kết quả trả ngược lại theo đúng chiều đó.

```
User Action (UI)
   → State Layer (Provider) gọi method tương ứng
      → Data Layer (Service/Repository) thực hiện request/query
         → External System (API/Firebase) xử lý và trả kết quả
      ← Data Layer parse kết quả thành Model, hoặc ném Exception nếu lỗi
   ← State Layer cập nhật trạng thái nội bộ (loading/success/error) + dữ liệu
UI tự động rebuild theo trạng thái mới (thông qua cơ chế listen của State Management)
```

Ví dụ cụ thể — luồng "Xem danh sách món ăn ở Home":
1. `HomeScreen` gọi `context.read<MealProvider>().fetchDefaultMeals()` trong `initState`.
2. `MealProvider` set trạng thái `loading`, gọi `MealApiService.getMealsByFirstLetter('b')`.
3. `MealApiService` gọi HTTP GET đến TheMealDB, nhận JSON, parse thành `List<MealModel>`.
4. `MealProvider` nhận kết quả, set trạng thái `success` kèm danh sách, hoặc `error` nếu exception.
5. `HomeScreen` lắng nghe `MealProvider` qua `Consumer`/`context.watch`, tự động render lại theo trạng thái.

---

## 7. Request Flow

Sơ đồ tuần tự cho một request điển hình ra bên ngoài (áp dụng cho cả REST API và Firestore):

```
[Widget] --(user event: tap/submit)--> [Provider.method()]
   [Provider] --(set state = Loading)--> [notifyListeners()] --> [Widget rebuild: show spinner]
   [Provider] --(call)--> [Service/Repository.action()]
      [Service] --(build request/query)--> [External System]
      [External System] --(response)--> [Service]
      [Service] --(parse JSON/DocumentSnapshot)--> [Model] hoặc throw AppException
   [Provider] --(nhận kết quả)--> [set state = Success(data) | Error(message)]
   [Provider] --(notifyListeners())--> [Widget rebuild: show data | show error UI]
```

Nguyên tắc: **Provider không bao giờ tự parse JSON/DocumentSnapshot thô** — việc đó thuộc về Service/Model. Provider chỉ điều phối trạng thái và gọi đúng thứ tự các bước nghiệp vụ.

---

## 8. Dependency Rules

- **Chiều phụ thuộc chỉ đi một hướng:** `Presentation → State → Data → External`. Không có chiều ngược lại.
- **Presentation layer** chỉ được phép import: State layer (Provider) và Core widget/constants dùng chung. **Không** được import trực tiếp `firebase_auth`, `cloud_firestore`, `http`/`dio` package.
- **State layer** chỉ được phép import: Data layer (Service/Repository/Model) của cùng feature hoặc feature nó phụ thuộc hợp lệ (ví dụ `Meal Detail Provider` được phép đọc `Favorite Repository`). Không import ngược lên Presentation (không giữ `BuildContext` bên trong Provider).
- **Data layer** chỉ được phép import: Model của chính nó và SDK/package bên ngoài (Firebase SDK, `http`). Không import bất cứ thứ gì từ State hay Presentation layer.
- **Core** không phụ thuộc vào bất kỳ feature nào; ngược lại, mọi feature có thể phụ thuộc vào `core/`.
- **Không có phụ thuộc vòng tròn** giữa các feature (ví dụ `Favorite` không được phụ thuộc ngược lại vào `Meal Detail`).
- Việc "khởi tạo và cung cấp" Provider cho cây widget (dependency injection ở mức đơn giản) thực hiện tập trung tại `app.dart` (dùng `MultiProvider` hoặc tương đương), không khởi tạo Provider rải rác trong các Screen.

---

## 9. State Management (Flutter)

- **Giải pháp chọn: `Provider`** (package `provider`), dùng nhất quán cho toàn bộ ứng dụng.
  - Lý do: đơn giản, dễ học, được Flutter team khuyến nghị cho ứng dụng vừa/nhỏ, phù hợp MVP học thuật, tài liệu phong phú, không yêu cầu code generation (khác với Riverpod bản mới hoặc Bloc cần nhiều boilerplate).
- **Mỗi feature có 1 (hoặc vài) ChangeNotifier riêng** tương ứng đúng ranh giới nghiệp vụ:
  - `AuthProvider`: trạng thái đăng nhập hiện tại, loading, lỗi auth.
  - `MealProvider`: danh sách món ăn Home/Search/Filter, trạng thái loading/error/empty.
  - `MealDetailProvider`: chi tiết món ăn đang xem + trạng thái đã yêu thích hay chưa.
  - `FavoriteProvider`: danh sách yêu thích, thao tác thêm/xóa/sửa ghi chú.
  - `ProfileProvider`: thông tin hồ sơ hiện tại, trạng thái lưu.
- **Cách biểu diễn trạng thái async thống nhất**: mỗi Provider dùng chung một pattern trạng thái (ví dụ enum `ViewStatus { idle, loading, success, error }` + field `errorMessage` + field `data`) để toàn bộ app xử lý loading/error nhất quán, tránh mỗi Provider tự sáng tạo cách riêng.
- **Phạm vi cung cấp (scope)**:
  - `AuthProvider` cung cấp ở gốc `app.dart` (toàn app cần biết trạng thái đăng nhập).
  - `MealProvider`, `FavoriteProvider`, `ProfileProvider` có thể cung cấp ở gốc app (đơn giản cho MVP) hoặc ở cấp route tương ứng nếu muốn giải phóng bộ nhớ khi rời màn hình — với quy mô MVP, cung cấp ở gốc là đủ đơn giản và chấp nhận được.
- **Không trộn lẫn nhiều giải pháp state** (ví dụ vừa Provider vừa setState cục bộ cho business state) — `setState` chỉ dùng cho state thuần UI cục bộ không liên quan dữ liệu nghiệp vụ (ví dụ trạng thái ẩn/hiện password, animation).

---

## 10. API Communication

### 10.1 REST API (TheMealDB)
- Toàn bộ giao tiếp qua `MealApiService` (dùng package `http` hoặc `dio`, chọn 1 và dùng nhất quán).
- Base URL và API key (`1`) đặt trong `core/constants/api_constants.dart`.
- Các endpoint sử dụng đúng theo `PROJECT_REQUIREMENTS.md`:
  - Danh sách mặc định: `search.php?f=b`
  - Tìm kiếm: `search.php?s={keyword}`
  - Lọc danh mục: `filter.php?c={category}`
  - Chi tiết món ăn: `lookup.php?i={idMeal}`
- Timeout áp dụng cho mọi request (khuyến nghị 10–15 giây), tự động ném `NetworkException` khi vượt quá.
- Response luôn kiểm tra field `meals` có thể là `null` (đặc thù TheMealDB khi không có kết quả) trước khi parse thành `List<MealModel>`.

### 10.2 Firebase (Auth + Firestore)
- Không giao tiếp qua REST thủ công — dùng trực tiếp Firebase SDK (`firebase_auth`, `cloud_firestore`) bên trong Service layer (`AuthService`, `FirestoreService`).
- Cấu trúc dữ liệu Firestore:
  ```
  users (collection)
    └── {uid} (document)
          ├── name, height, targetWeight, email...
          └── favorites (sub-collection)
                └── {idMeal} (document)
                      ├── mealName, mealThumbnail (cache nhẹ để hiển thị list nhanh)
                      ├── note
                      └── createdAt
  ```
- Document ID của `favorites` dùng chính `idMeal` từ TheMealDB (đã quyết định ở `PROJECT_REQUIREMENTS.md`, Business Rule BR-02/BR-05) để đảm bảo không trùng lặp và tra cứu nhanh trạng thái "đã yêu thích" bằng `doc(idMeal).get()`.

---

## 11. Error Flow

```
[External System lỗi: network timeout / HTTP error / FirebaseException]
   → [Service layer bắt lỗi gốc] → map thành 1 trong các loại lỗi chuẩn hóa của app:
        - NetworkException      (mất mạng, timeout)
        - ApiException          (lỗi từ TheMealDB, mã lỗi HTTP không thành công)
        - AuthException         (sai email/password, email đã tồn tại...)
        - FirestoreException    (permission-denied, unavailable...)
        - ValidationException   (dữ liệu input không hợp lệ, thường chặn ở UI trước khi tới Service)
   → [Provider bắt exception đã chuẩn hóa] → set state = Error(message thân thiện tương ứng)
   → [Widget lắng nghe state Error] → hiển thị SnackBar / Dialog / ErrorView với nút "Thử lại" nếu phù hợp
```

- Toàn bộ mapping từ lỗi kỹ thuật (exception gốc của package) sang message thân thiện được tập trung một chỗ trong `core/errors/` — không rải rác logic dịch lỗi trong nhiều Provider khác nhau.
- Provider **không bao giờ để exception rò rỉ lên UI chưa qua xử lý** — luôn bọc `try-catch` khi gọi Service, đúng nguyên tắc Exception Handling trong `PROJECT_GUIDELINES.md`.
- Trạng thái rỗng (empty result, ví dụ search không ra kết quả) được phân biệt rõ với trạng thái `Error` — không dùng chung một loại state.

---

## 12. Logging Flow

```
[Bất kỳ layer nào bắt được exception]
   → debugPrint('[<TênClass>] <Hành động thất bại>: $error')
   → (Data layer) ném lại dưới dạng Exception đã chuẩn hóa cho layer trên
   → (State layer) log lại lần nữa nếu cần thêm ngữ cảnh nghiệp vụ (ví dụ đang thao tác trên món ăn nào)
```

- Dùng `debugPrint` (tự loại bỏ ở release build), không dùng `print`.
- Log tối thiểu phải có: tên class/nơi phát sinh, hành động đang thực hiện, thông tin lỗi — không log dữ liệu nhạy cảm (mật khẩu, token).
- MVP không tích hợp dịch vụ log tập trung (Crashlytics/Sentry) — có thể bổ sung ở phần mở rộng sau nếu triển khai thực tế ngoài phạm vi đồ án.

---

## 13. Authentication Flow

```
[App khởi động]
   → SplashScreen lắng nghe AuthProvider (được khởi tạo lắng nghe Stream<User?> từ FirebaseAuth.authStateChanges())
   → Nếu có User hiện tại (đã đăng nhập từ trước, session còn hiệu lực)
        → Điều hướng thẳng vào HomeScreen
   → Nếu không có User
        → Điều hướng vào LoginScreen

[Đăng ký]
   RegisterScreen (nhập email, password, validate FormState)
      → AuthProvider.register(email, password)
         → AuthService gọi FirebaseAuth.createUserWithEmailAndPassword
         → Thành công: tạo thêm document users/{uid} khởi tạo trên Firestore (thông qua FirestoreService)
         → Thất bại: map FirebaseAuthException → AuthException → hiển thị lỗi trên UI
      → Thành công toàn bộ → điều hướng vào HomeScreen

[Đăng nhập]
   LoginScreen (nhập email, password, validate FormState)
      → AuthProvider.login(email, password)
         → AuthService gọi FirebaseAuth.signInWithEmailAndPassword
         → Thành công → điều hướng vào HomeScreen
         → Thất bại → map lỗi (user-not-found, wrong-password...) → hiển thị lỗi trên UI

[Đăng xuất]
   ProfileScreen → AuthProvider.logout() → AuthService gọi FirebaseAuth.signOut()
      → AuthProvider state chuyển về "chưa đăng nhập" → toàn app điều hướng lại về LoginScreen
```

- `AuthProvider` là nguồn chân lý duy nhất (single source of truth) cho trạng thái đăng nhập toàn app; mọi route bảo vệ (Home, Favorite, Profile) đều dựa vào state này để quyết định cho phép truy cập hay redirect về Login (đúng Business Rule BR-06 trong `PROJECT_REQUIREMENTS.md`).

---

## 14. File Upload Flow

**Đã triển khai cho Avatar** (quyết định ban đầu "ngoài phạm vi MVP" đã được đảo ngược theo yêu cầu thực tế). Ảnh món ăn vẫn hoàn toàn đến từ URL do TheMealDB cung cấp sẵn (không có upload) — chỉ **avatar cá nhân** là có upload thật.

```
ProfileScreen → bấm icon sửa trên AvatarWidget
   → AvatarPickerSheet.show() → chọn "Chụp ảnh mới" / "Chọn từ thư viện" (image_picker)
   → ProfileProvider.uploadAvatar(file)
      → AvatarStorageService.uploadAvatar(uid, file)
         → Firebase Storage: ref('avatars/{uid}.jpg').putFile(file)
         → Trả về download URL
      → ProfileService.updateProfile(uid, {avatarUrl: url}) — ghi URL vào Firestore users/{uid}
   → UserProfileModel cập nhật avatarUrl → AvatarWidget hiển thị ảnh thật thay vì initials
```

- **External System mới:** Cloud Storage (Firebase Storage) — cần bật trên Firebase Console (khác bước bật Auth/Firestore đã làm), và cấu hình Security Rules riêng để chỉ chủ tài khoản ghi được đúng file `avatars/{uid}.jpg` của mình (chưa triển khai Rules cụ thể, sẽ làm cùng lúc với Firestore Rules ở Phase 10 — `DEVELOPMENT_ROADMAP.md`).
- **Native permissions:** `image_picker` yêu cầu khai báo `NSPhotoLibraryUsageDescription`/`NSCameraUsageDescription` trong `Info.plist` (đã thêm) — thiếu sẽ crash khi mở camera/thư viện trên iOS.
- Ảnh món ăn (TheMealDB) vẫn không lưu trữ, không upload — giữ nguyên đúng BR-07.

---

## 15. Notification Flow

**Không nằm trong phạm vi MVP** — Push Notification đã được liệt kê trong Out of Scope của `PROJECT_REQUIREMENTS.md`.

**Điểm mở rộng trong tương lai**: nếu bổ sung (ví dụ nhắc nấu ăn, gợi ý món mới), sẽ cần tích hợp `Firebase Cloud Messaging` như một External System mới, thêm `NotificationService` ở Data layer để đăng ký token thiết bị và lắng nghe message, không ảnh hưởng đến các module hiện có.

---

## 16. Realtime Flow

Áp dụng cho **module Favorite** — theo yêu cầu FR-FAV-06 ("đồng bộ theo thời gian thực"):

```
FavoriteScreen mount
   → FavoriteProvider gọi FirestoreService.watchFavorites(uid)
      → Firestore trả về Stream<QuerySnapshot> qua collection('users/{uid}/favorites').snapshots()
   → FavoriteProvider lắng nghe Stream, mỗi khi có thay đổi (thêm/sửa/xóa ở bất kỳ đâu, kể cả từ thiết bị khác cùng tài khoản)
      → tự động parse lại thành List<FavoriteMealModel>, cập nhật state, notifyListeners()
   → FavoriteScreen tự động rebuild danh sách mới nhất mà không cần pull-to-refresh thủ công
```

- Việc thêm/xóa/sửa favorite (từ `MealDetailScreen` hoặc `FavoriteScreen`) chỉ cần ghi thẳng vào Firestore (`set`/`update`/`delete`) — không cần tự cập nhật local state thủ công, vì Stream lắng nghe sẽ tự động đẩy thay đổi mới nhất về UI.
- Đây là realtime "đồng bộ dữ liệu cá nhân qua Firestore listener", không phải realtime giao tiếp giữa nhiều người dùng (không có tính năng multiplayer/chat trong MVP).
- Module Home/Search/Meal Detail (dữ liệu từ TheMealDB) **không** có realtime — đây là dữ liệu đọc theo yêu cầu (pull), không có cơ chế đẩy (push) từ TheMealDB.

---

## 17. Deployment Overview

- **Client (giai đoạn phát triển MVP):** Ứng dụng Flutter build và chạy trên **iOS Simulator** (`flutter run` chọn Simulator, hoặc `flutter build ios` qua Xcode), không qua CI/CD phức tạp. Đây là môi trường build/test do máy phát triển hiện tại là MacBook, không có sẵn môi trường Android.
- **Client (giai đoạn bàn giao, sau khi MVP hoàn thành):** Codebase được gửi cho một thành viên khác có môi trường Android để build APK (`flutter build apk`) và kiểm thử trên thiết bị Android thật qua cáp vật lý, đúng yêu cầu gốc của đề bài PRM393 (Giai đoạn 5). Vì kiến trúc đã giữ thuần Flutter/Material ngay từ đầu (không dùng API/package chỉ hỗ trợ iOS — xem `PROJECT_GUIDELINES.md` mục Architecture Rules), bước bàn giao này về lý thuyết không cần viết lại code, chỉ cần cấu hình lại Firebase cho Android (`google-services.json`, `flutterfire configure` lại) và build. Xem `PROJECT_REQUIREMENTS.md` mục Constraints/điểm 9 để biết chi tiết kế hoạch và rủi ro liên quan.
- **Backend-as-a-Service:** Không có server tự triển khai. Toàn bộ backend là Firebase project (gói miễn phí Spark Plan) gồm:
  - Firebase Authentication (bật phương thức Email/Password).
  - Cloud Firestore (ở chế độ Production hoặc Test tùy giai đoạn, kèm Security Rules siết chặt trước khi báo cáo — xem mục Security trong `PROJECT_GUIDELINES.md`).
- **Third-party API:** TheMealDB — không cần deploy, dùng trực tiếp endpoint public có sẵn, không yêu cầu server trung gian (không cần proxy).
- **Version Control:** Repository trên GitHub, có branching strategy cơ bản (ví dụ `main` ổn định + feature branch theo từng sprint/module), phát triển bằng VS Code (đúng công cụ nêu ở Giai đoạn 1 đề bài).
- **Môi trường:** Không phân biệt dev/staging/production phức tạp cho MVP — dùng chung 1 Firebase project trong suốt quá trình phát triển và demo. Nếu mở rộng thành sản phẩm thật, nên tách Firebase project riêng cho dev và production ở giai đoạn sau.
- **CI/CD:** Không bắt buộc cho MVP học thuật; có thể bổ sung GitHub Actions chạy `flutter analyze`/`flutter test` tự động khi mở rộng dự án sau này (không nằm trong phạm vi 5 sprint hiện tại).

# DATABASE_DESIGN.md — NutriCook (PRM393)

Tài liệu này mô tả thiết kế dữ liệu cho NutriCook, dựa trên `PROJECT_REQUIREMENTS.md` và `BUSINESS_FLOW.md`. Không chứa SQL, không chứa định nghĩa Entity/code — chỉ mô tả thiết kế ở mức khái niệm.

**Lưu ý quan trọng về công nghệ lưu trữ:** NutriCook dùng **Cloud Firestore** — một cơ sở dữ liệu NoSQL dạng document, không phải quan hệ (RDBMS). Do đó các khái niệm truyền thống như Foreign Key, JOIN, chuẩn hóa 3NF không được Firestore hỗ trợ/thực thi ở tầng database. Tài liệu này áp dụng các khái niệm đó ở **mức logic/thiết kế** (do tầng ứng dụng đảm bảo), và giải thích rõ điểm khác biệt so với RDBMS ở từng mục liên quan.

---

## 1. Danh sách toàn bộ Entity

| Entity | Loại lưu trữ | Mô tả |
|---|---|---|
| **User** | Lưu trong Firestore (collection `users`) | Thông tin tài khoản và hồ sơ sức khỏe cá nhân của người dùng đã đăng ký. |
| **Favorite** | Lưu trong Firestore (sub-collection `users/{uid}/favorites`) | Bản ghi món ăn được người dùng lưu làm yêu thích, kèm ghi chú cá nhân. |
| **Meal** | **Không lưu trữ trong hệ thống** — Entity ngoài (External Entity), dữ liệu gốc nằm tại TheMealDB | Thông tin món ăn (tên, ảnh, nguyên liệu, hướng dẫn, calo). Chỉ được tham chiếu bằng `idMeal`, không có bản sao đầy đủ lưu lâu dài trong Firestore (đúng Business Rule BR-07 đã xác lập ở `PROJECT_REQUIREMENTS.md`). |

> Chỉ có 2 entity thực sự được ứng dụng lưu trữ và quản lý vòng đời (User, Favorite). Meal là entity tham chiếu tới hệ thống bên ngoài, được liệt kê ở đây vì nó tham gia vào relationship với Favorite.

---

## 2. Bảng dữ liệu

Trong Firestore, "bảng" tương đương với **Collection**, "dòng dữ liệu" tương đương với **Document**.

### 2.1 Collection `users`
- Đường dẫn: `/users/{uid}`
- Mỗi document đại diện cho một tài khoản người dùng đã đăng ký.

### 2.2 Sub-collection `favorites`
- Đường dẫn: `/users/{uid}/favorites/{idMeal}`
- Mỗi document đại diện cho một món ăn được người dùng đó lưu yêu thích.
- Là sub-collection nằm bên trong từng document `users/{uid}` — không phải collection gốc độc lập, đảm bảo dữ liệu yêu thích luôn gắn chặt với đúng một người dùng.

---

## 3. Thuộc tính

### 3.1 `users/{uid}`

| Field | Kiểu dữ liệu | Bắt buộc | Mô tả |
|---|---|---|---|
| `uid` | String | Có (= document ID, không lưu lặp lại trong field trừ khi cần truy vấn) | Định danh người dùng, lấy từ Firebase Authentication. |
| `email` | String | Có | Email đăng ký, đồng bộ với Firebase Auth. |
| `name` | String | Không (mặc định rỗng khi tạo) | Tên hiển thị của người dùng. |
| `height` | Number | Không | Chiều cao (cm), phải là số dương (BR-04). |
| `currentWeight` | Number | Không | Cân nặng hiện tại (kg), phải là số dương (BR-04). Bổ sung ở giai đoạn Profile Module để tính BMI chính xác — tách biệt với `targetWeight` (BMI của mục tiêu không phản ánh đúng tình trạng hiện tại). |
| `targetWeight` | Number | Không | Cân nặng mục tiêu (kg), phải là số dương (BR-04). |
| `avatarUrl` | String | Không | Download URL ảnh đại diện trên Cloud Storage (`avatars/{uid}.jpg`) — null nghĩa là chưa tải ảnh lên, UI fallback về avatar chữ cái đầu tên. Bổ sung khi đảo ngược quyết định "không có File Upload" ở `SYSTEM_ARCHITECTURE.md` mục 14. |
| `createdAt` | Timestamp | Có | Thời điểm tạo tài khoản (audit field). |
| `updatedAt` | Timestamp | Có | Thời điểm cập nhật hồ sơ gần nhất (audit field). |

### 3.2 `users/{uid}/favorites/{idMeal}`

| Field | Kiểu dữ liệu | Bắt buộc | Mô tả |
|---|---|---|---|
| `idMeal` | String | Có (= document ID, đồng thời lưu lặp lại trong field để thuận tiện truy vấn/export nếu cần) | ID món ăn gốc từ TheMealDB, dùng làm khóa liên kết logic tới entity Meal. |
| `mealName` | String | Có | Tên món ăn — **dữ liệu denormalized**, sao chép tại thời điểm lưu để hiển thị nhanh danh sách Favorite mà không cần gọi lại API. |
| `mealThumbnail` | String (URL) | Có | Ảnh đại diện món ăn — denormalized cùng lý do với `mealName`. |
| `note` | String | Không (mặc định rỗng) | Ghi chú cá nhân của người dùng cho món ăn này. |
| `createdAt` | Timestamp | Có | Thời điểm thêm vào danh sách yêu thích (audit field). |
| `updatedAt` | Timestamp | Có | Thời điểm chỉnh sửa ghi chú gần nhất (audit field). |

### 3.3 Meal (External Entity — tham khảo, không lưu trữ)

| Field | Kiểu dữ liệu | Nguồn |
|---|---|---|
| `idMeal` | String | TheMealDB |
| `strMeal` | String | TheMealDB (tên món) |
| `strMealThumb` | String (URL) | TheMealDB (ảnh) |
| `strCategory` | String | TheMealDB (danh mục) |
| `strInstructions` | String | TheMealDB (hướng dẫn) |
| `strIngredientN` / `strMeasureN` | String (nhiều field lặp N=1..20) | TheMealDB (nguyên liệu & định lượng) |

Các field này thuộc sở hữu và kiểm soát của TheMealDB, không nằm trong phạm vi thiết kế database của NutriCook — liệt kê ở đây chỉ để làm rõ nguồn gốc field `mealName`/`mealThumbnail` được sao chép sang Favorite.

---

## 4. Primary Key

Firestore không có khái niệm PK dạng cột như RDBMS — **Document ID chính là Primary Key**, do ứng dụng chủ động chọn giá trị thay vì để hệ thống tự sinh ID ngẫu nhiên (auto-ID), nhằm đảm bảo tính duy nhất có ý nghĩa nghiệp vụ:

| Entity | Primary Key | Giá trị lấy từ |
|---|---|---|
| `users` | `uid` (document ID) | Firebase Authentication UID (đã đảm bảo duy nhất toàn hệ thống) |
| `favorites` | `idMeal` (document ID) | ID món ăn gốc từ TheMealDB |

**Lý do dùng `idMeal` làm PK của Favorite thay vì để Firestore tự sinh ID ngẫu nhiên:** đảm bảo mỗi món ăn chỉ có tối đa một document trong sub-collection của một người dùng (thực thi trực tiếp Business Rule BR-02 — không trùng lặp — mà không cần query kiểm tra tồn tại trước, chỉ cần `doc(idMeal).set()`/`.delete()`).

---

## 5. Foreign Key

Firestore **không hỗ trợ Foreign Key constraint thực sự** (không có ràng buộc toàn vẹn tham chiếu ở tầng database, không tự động cascade, không tự chặn ghi dữ liệu "mồ côi"). Các mối liên kết dưới đây là **Foreign Key logic**, do tầng ứng dụng (Data Layer — xem `SYSTEM_ARCHITECTURE.md`) tự đảm bảo:

| Field liên kết | Từ Entity | Đến Entity | Cơ chế thực thi |
|---|---|---|---|
| Đường dẫn `users/{uid}/...` | `Favorite` | `User` | Ràng buộc **cấu trúc** (structural), không phải field — do Favorite là sub-collection nằm vật lý bên trong document User, nên không thể tồn tại độc lập mà không có `uid` cha. Đây là cách Firestore mô phỏng quan hệ 1-N chặt chẽ nhất có thể mà không cần FK tường minh. |
| `idMeal` | `Favorite` | `Meal` (external) | Không có ràng buộc nào ở tầng lưu trữ — hoàn toàn do tầng ứng dụng đảm bảo tính hợp lệ tại thời điểm ghi (chỉ cho phép tạo Favorite từ một `idMeal` hợp lệ đã fetch được từ TheMealDB). Vì Meal không do hệ thống kiểm soát, **không thể và không nên** cố gắng thực thi ràng buộc toàn vẹn tham chiếu tuyệt đối — chấp nhận rủi ro "tham chiếu treo" nếu TheMealDB xóa món ăn (đã nêu trong đề xuất bổ sung ở `BUSINESS_FLOW.md`). |

---

## 6. Relationships

- **User — Favorite:** Một User có nhiều Favorite (One-to-Many), quan hệ **containment** (Favorite tồn tại bên trong User, không phải liên kết rời rạc qua ID field).
- **Favorite — Meal:** Mỗi Favorite tham chiếu đến đúng một Meal (Many-to-One logic), nhưng đây là tham chiếu **một chiều, đơn hướng** ra ngoài hệ thống — Meal (TheMealDB) không biết và không lưu ngược thông tin có bao nhiêu Favorite đang tham chiếu tới nó.
- Không có quan hệ Many-to-Many nào trong thiết kế hiện tại của MVP (không có tính năng chia sẻ Favorite giữa nhiều User — đúng Business Rule BR-01).

---

## 7. Cardinality

| Quan hệ | Cardinality | Ghi chú |
|---|---|---|
| User → Favorite | 1 : 0..N | Một user có thể có 0 đến nhiều món yêu thích; không giới hạn cứng số lượng ở tầng thiết kế (có thể cân nhắc giới hạn mềm ở tầng ứng dụng nếu cần, xem mục 15). |
| Favorite → User | N : 1 | Mỗi Favorite luôn thuộc về đúng một User (bắt buộc, do cấu trúc sub-collection). |
| Favorite → Meal | N : 1 (logic) | Nhiều Favorite (từ các user khác nhau) có thể cùng tham chiếu đến 1 `idMeal`, nhưng đây là quan hệ logic ngoài hệ thống, không thể truy vấn ngược "Meal này có bao nhiêu người yêu thích" trong MVP (không có yêu cầu này). |
| User → Meal | Không có quan hệ trực tiếp | User chỉ liên kết tới Meal gián tiếp thông qua Favorite. |

---

## 8. Index Strategy

Firestore tự động tạo **single-field index** cho mọi field trong mọi document — không cần khai báo thủ công cho các truy vấn đơn giản (lọc/sắp xếp theo 1 field).

Các truy vấn thực tế trong MVP (theo `BUSINESS_FLOW.md`):
- Đọc toàn bộ `users/{uid}/favorites` (không filter, có thể sắp xếp theo `createdAt`) → dùng single-field auto-index sẵn có, **không cần composite index**.
- Đọc 1 document `users/{uid}/favorites/{idMeal}` để kiểm tra trạng thái yêu thích → truy vấn theo Document ID trực tiếp, không cần index.
- Đọc 1 document `users/{uid}` cho Profile → tương tự, không cần index.

**Kết luận cho MVP:** không cần khai báo composite index thủ công trong `firestore.indexes.json`. Chỉ cần cân nhắc composite index trong tương lai nếu bổ sung truy vấn kết hợp nhiều điều kiện (ví dụ: "lọc favorite theo category VÀ sắp xếp theo ngày thêm" — hiện chưa có trong scope MVP vì `strCategory` không được lưu trong Favorite).

**Khuyến nghị mở rộng:** nếu sau này cần tìm kiếm/lọc trong danh sách Favorite theo tên món hoặc theo category, nên lưu thêm field denormalized tương ứng (ví dụ `mealCategory`) ngay từ đầu khi tạo Favorite, để tránh phải migrate dữ liệu cũ khi bổ sung tính năng.

---

## 9. Audit Fields

Áp dụng thống nhất cho cả hai collection lưu trữ:

| Field | Áp dụng cho | Ý nghĩa |
|---|---|---|
| `createdAt` | `users`, `favorites` | Thời điểm tạo bản ghi, dùng server timestamp (không dùng thời gian client để tránh sai lệch múi giờ/đồng hồ thiết bị). |
| `updatedAt` | `users`, `favorites` | Thời điểm cập nhật gần nhất, ghi đè mỗi lần Update. |

**Không đưa vào MVP** (nhưng cân nhắc cho tương lai nếu cần truy vết chi tiết hơn): `createdBy`/`updatedBy` (không cần thiết vì dữ liệu đã nằm trong đúng phạm vi `uid` của chủ sở hữu — không có khái niệm nhiều actor cùng chỉnh sửa một bản ghi trong MVP), `deletedAt` (xem mục 10).

---

## 10. Soft Delete Strategy

**MVP áp dụng Hard Delete (xóa vật lý)**, không dùng Soft Delete, cho cả hai thao tác xóa trong hệ thống:
- Xóa món khỏi Favorite (vuốt để xóa, hoặc toggle bỏ yêu thích) → xóa hẳn document trong Firestore.
- Không có thao tác xóa User trong phạm vi MVP (không có tính năng "xóa tài khoản").

**Lý do chọn Hard Delete cho MVP:**
- Dữ liệu Favorite không có giá trị lưu trữ lịch sử/audit bắt buộc theo yêu cầu đề bài — người dùng xóa là muốn xóa hẳn khỏi danh sách của họ.
- Soft Delete (thêm field `deletedAt`, luôn phải filter `where deletedAt == null` ở mọi truy vấn) làm tăng độ phức tạp không cần thiết cho một ứng dụng MVP học thuật — vi phạm nguyên tắc KISS trong `PROJECT_GUIDELINES.md`.
- Không có yêu cầu nghiệp vụ nào (trong `PROJECT_REQUIREMENTS.md`) về khôi phục dữ liệu đã xóa hoặc giữ lịch sử thay đổi.

**Khuyến nghị mở rộng tương lai:** nếu sản phẩm phát triển thật (ngoài phạm vi đồ án) và cần tính năng "khôi phục món vừa xóa nhầm" hoặc thống kê hành vi người dùng, có thể bổ sung Soft Delete cho riêng collection `favorites` mà không ảnh hưởng đến `users`.

---

## 11. Transaction Boundaries

Xác định ranh giới các thao tác cần đảm bảo tính toàn vẹn (atomic) khi thực thi trên Firestore:

| Thao tác nghiệp vụ | Cần Transaction/Batch? | Lý do |
|---|---|---|
| Toggle Favorite (kiểm tra tồn tại rồi Create/Delete) | **Có — dùng Firestore Transaction** | Tránh race condition khi người dùng nhấn nhanh liên tục (double-tap) hoặc thao tác đồng thời từ nhiều thiết bị cùng tài khoản, đảm bảo trạng thái "đã lưu/chưa lưu" luôn nhất quán, không tạo ra ghi/xóa chồng chéo sai thứ tự. |
| Cập nhật `note` cho một Favorite đã tồn tại | Không cần — thao tác `update()` trên 1 document đơn lẻ đã atomic sẵn theo bản chất của Firestore. |
| Cập nhật Profile (`name`, `height`, `targetWeight`) | Không cần — thao tác `update()` trên 1 document đơn lẻ, atomic sẵn. |
| Đăng ký tài khoản (tạo user trên Firebase Auth **và** tạo document `users/{uid}` trên Firestore) | **Không thể transaction thật sự** (hai hệ thống khác nhau: Firebase Auth và Firestore không nằm trong cùng một transaction boundary) — cần xử lý theo hướng **hai bước tuần tự có xử lý bù trừ (compensating logic)**: nếu tạo tài khoản Auth thành công nhưng tạo document Firestore thất bại, ứng dụng phải retry việc tạo document (ví dụ ở lần đăng nhập kế tiếp, kiểm tra và tự tạo document nếu chưa tồn tại) thay vì để người dùng rơi vào trạng thái "có tài khoản Auth nhưng không có hồ sơ Firestore". |
| Đọc danh sách Favorite (real-time listener) | Không áp dụng khái niệm transaction (đây là read-only stream, không có write). |

**Nguyên tắc chung:** chỉ dùng Transaction cho thao tác thực sự có nguy cơ race condition (đọc-rồi-ghi dựa trên trạng thái hiện tại). Các thao tác ghi đơn giản (single-document write) không cần bọc transaction vì Firestore đã đảm bảo atomicity ở cấp document.

---

## 12. Naming Convention

| Đối tượng | Convention | Ví dụ |
|---|---|---|
| Tên Collection | Danh từ số nhiều, `lowerCamelCase` hoặc toàn chữ thường nếu 1 từ | `users`, `favorites` |
| Tên Field | `lowerCamelCase` (đồng bộ với Dart/Flutter convention trong `PROJECT_GUIDELINES.md`) | `mealName`, `targetWeight`, `createdAt` |
| Document ID có ý nghĩa nghiệp vụ | Dùng đúng giá trị định danh gốc, không tự sinh chuỗi ngẫu nhiên khi có sẵn khóa tự nhiên | `uid` (từ Firebase Auth), `idMeal` (từ TheMealDB) |
| Field thời gian | Hậu tố `At`, kiểu Timestamp | `createdAt`, `updatedAt` |
| Field boolean (nếu có trong tương lai) | Tiền tố `is`/`has` | ví dụ tương lai: `isActive` |

Convention này nhất quán với quy tắc đặt tên biến/hàm Dart đã quy định ở `PROJECT_GUIDELINES.md` (mục 4), giúp việc map giữa Model class (`fromMap`/`toMap`) và document Firestore trực quan, không cần một bảng chuyển đổi tên riêng.

---

## 13. ERD dạng text

```
┌───────────────────────────┐
│          User              │
│  (collection: users)       │
│─────────────────────────────│
│ PK  uid            String   │
│     email          String   │
│     name           String   │
│     height         Number   │
│     targetWeight   Number   │
│     createdAt      Timestamp│
│     updatedAt      Timestamp│
└──────────────┬──────────────┘
               │ 1
               │
               │ contains (structural FK qua path users/{uid}/favorites)
               │
               │ 0..N
┌──────────────▼──────────────┐
│         Favorite             │
│ (sub-collection: favorites)  │
│───────────────────────────────│
│ PK  idMeal         String     │
│     mealName       String     │  (denormalized từ Meal)
│     mealThumbnail  String     │  (denormalized từ Meal)
│     note           String     │
│     createdAt      Timestamp  │
│     updatedAt      Timestamp  │
└──────────────┬────────────────┘
               │ N
               │
               │ references (logic FK, không ràng buộc DB)
               │
               │ 1
┌──────────────▼────────────────┐
│      Meal (External Entity)    │
│  Nguồn: TheMealDB REST API     │
│  Không lưu trữ trong Firestore │
│─────────────────────────────────│
│ PK  idMeal          String      │
│     strMeal         String      │
│     strMealThumb    String      │
│     strCategory     String      │
│     strInstructions String      │
│     strIngredientN  String[N]   │
│     strMeasureN     String[N]   │
└──────────────────────────────────┘
```

---

## 14. Chuẩn hóa dữ liệu

Vì Firestore là NoSQL document database, các dạng chuẩn hóa (1NF/2NF/3NF) của mô hình quan hệ **không áp dụng trực tiếp**. Thiết kế NoSQL thường **ưu tiên denormalization có chủ đích** để tối ưu tốc độ đọc (read performance) — đánh đổi lấy một phần dư thừa dữ liệu, thay vì tối ưu tránh trùng lặp như RDBMS. NutriCook áp dụng cách tiếp cận lai (hybrid), cụ thể:

**Những gì được "chuẩn hóa" (tách biệt, không trộn lẫn):**
- Dữ liệu Favorite được tách khỏi document User thành sub-collection riêng, thay vì nhồi một mảng `favorites: []` trực tiếp vào document `users/{uid}`. Lý do: Firestore giới hạn kích thước tối đa 1 document (1MB) và không tối ưu cho việc cập nhật từng phần tử trong mảng lớn — tách sub-collection giúp mỗi thao tác Create/Update/Delete Favorite chỉ động vào đúng 1 document nhỏ, không phải đọc/ghi lại toàn bộ danh sách. Đây là nguyên tắc tương đương tinh thần của 1NF (tách nhóm dữ liệu lặp lại thành thực thể riêng).
- Không có dữ liệu User bị trùng lặp ở bất kỳ đâu khác trong hệ thống — mỗi thuộc tính hồ sơ chỉ tồn tại đúng một nơi (`users/{uid}`), tương đương tinh thần 2NF/3NF (không có partial/transitive dependency vì chỉ có một entity chứa các thuộc tính đó).

**Những gì được "denormalize" có chủ đích (đi ngược 3NF, nhưng hợp lý cho NoSQL):**
- Field `mealName` và `mealThumbnail` trong `Favorite` là **bản sao** của dữ liệu gốc từ Meal (TheMealDB) tại thời điểm người dùng thêm yêu thích — vi phạm nguyên tắc "không trùng lặp dữ liệu" của mô hình quan hệ chuẩn.
- **Lý do đánh đổi này hợp lý:** nếu không denormalize, màn hình Favorite (hiển thị danh sách nhiều món) sẽ phải gọi TheMealDB API riêng lẻ cho từng `idMeal` để lấy tên/ảnh hiển thị — vừa chậm (N request cho N món), vừa phụ thuộc vào việc TheMealDB luôn khả dụng và món ăn đó chưa bị xóa khỏi nguồn. Việc lưu sẵn 2 field nhỏ giúp danh sách Favorite hiển thị tức thời chỉ với 1 lần đọc Firestore.
- **Chấp nhận rủi ro dữ liệu lệch (stale data):** nếu TheMealDB đổi tên/ảnh món ăn sau khi người dùng đã lưu, bản sao trong Favorite sẽ không tự cập nhật. Đây là đánh đổi chấp nhận được cho MVP vì tần suất TheMealDB thay đổi dữ liệu món ăn đã có là rất thấp, và không nằm trong yêu cầu nghiệp vụ cần đồng bộ real-time với nguồn gốc.

---

## 15. Giải thích vì sao thiết kế như vậy

- **Bám sát đúng nhu cầu MVP, không thiết kế thừa:** Chỉ có 2 collection thực sự cần lưu trữ (`users`, `favorites`), đúng với phạm vi CRUD được yêu cầu trong `PROJECT_REQUIREMENTS.md` — không tạo thêm collection cho các tính năng chưa có (ví dụ không có collection `mealPlans`, `shoppingLists` vì đó thuộc Future Enhancements, ngoài scope hiện tại).
- **Document ID có ý nghĩa nghiệp vụ (`uid`, `idMeal`) thay vì auto-ID:** giúp thực thi trực tiếp các Business Rule quan trọng (BR-02: không trùng lặp favorite; liên kết 1-1 giữa Firebase Auth user và Firestore profile) mà không cần thêm bước query kiểm tra tồn tại — giảm số lượng round-trip tới database, đơn giản hóa logic tầng Repository (đã mô tả ở `SYSTEM_ARCHITECTURE.md`).
- **Sub-collection thay vì mảng nhúng:** phù hợp với đặc tính truy vấn thực tế của ứng dụng — cần lắng nghe real-time (`snapshots()`) trên toàn bộ danh sách Favorite (FR-FAV-06) và cần cập nhật/xóa từng phần tử độc lập (swipe-to-delete, sửa từng ghi chú) — mảng nhúng trong 1 document sẽ không tối ưu cho các thao tác cập nhật một phần tử đơn lẻ.
- **Denormalize có kiểm soát (chỉ 2 field nhỏ: tên + ảnh):** cân bằng giữa hiệu năng đọc (danh sách Favorite hiển thị tức thời) và rủi ro dữ liệu lệch (chấp nhận được, vì không phải dữ liệu quan trọng về mặt chính xác tuyệt đối như giá tiền hay số lượng tồn kho).
- **Không có Foreign Key/Transaction phức tạp ở tầng database:** phù hợp bản chất Firestore — thay vào đó, các ràng buộc toàn vẹn được đẩy lên tầng ứng dụng (Repository/Service trong `SYSTEM_ARCHITECTURE.md`) và Firestore Security Rules (đã đề cập ở `PROJECT_GUIDELINES.md`, mục Security) để vừa đảm bảo đúng đắn dữ liệu, vừa giữ được sự đơn giản, linh hoạt đặc trưng của NoSQL — đúng tinh thần "production-ready nhưng không over-engineering" mà `PROJECT_GUIDELINES.md` đã đặt ra cho toàn dự án.
- **Hard Delete, không Soft Delete, không audit user phức tạp:** giữ đúng quy mô MVP, tránh thêm độ phức tạp (field `deletedAt`, filter ở mọi query) khi không có yêu cầu nghiệp vụ nào cần đến — nhưng thiết kế vẫn để ngỏ khả năng bổ sung Soft Delete cho riêng `favorites` trong tương lai mà không phải đổi cấu trúc collection hiện có (chỉ cần thêm field mới, tương thích ngược).

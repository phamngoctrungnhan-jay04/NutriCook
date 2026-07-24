# API_DESIGN.md — NutriCook (PRM393)

Tài liệu này mô tả thiết kế API cho NutriCook, dựa trên `PROJECT_REQUIREMENTS.md`, `BUSINESS_FLOW.md`, `SYSTEM_ARCHITECTURE.md` và `DATABASE_DESIGN.md`. Không chứa code, không chứa controller.

---

## 0. Cách tiếp cận & Lưu ý quan trọng

Theo `SYSTEM_ARCHITECTURE.md`, NutriCook **không có backend REST tự viết** cho MVP. Ứng dụng giao tiếp với 2 loại nguồn dữ liệu khác nhau:

1. **External REST API thật** — TheMealDB: là endpoint HTTP thật, do bên thứ ba kiểm soát, ứng dụng chỉ đóng vai trò client tiêu thụ (consumer).
2. **Firebase SDK Operations** — Firebase Authentication & Cloud Firestore: không phải REST endpoint theo nghĩa truyền thống (không có URL/HTTP method do NutriCook định nghĩa), mà là lời gọi hàm qua SDK, được Firebase xử lý nội bộ.

Để tài liệu hóa nhất quán theo đúng khuôn mẫu yêu cầu (Endpoint, HTTP Method, Request, Response, Status Code...), tài liệu này mô tả các thao tác Firebase SDK dưới dạng **"Logical Endpoint"** — một hợp đồng giao diện (API Contract) tương đương REST mà tầng **Service/Repository** (Data Layer, theo `SYSTEM_ARCHITECTURE.md`) đảm nhiệm chuẩn hóa. Đây không phải route HTTP thật, nhưng có 2 lợi ích:
- Chuẩn hóa cách Provider layer gọi và nhận kết quả từ Data Layer, không phụ thuộc trực tiếp cú pháp SDK.
- Nếu tương lai dự án thay Firebase bằng backend REST tự viết (Future Enhancement), hợp đồng logic này gần như giữ nguyên, chỉ đổi phần triển khai bên dưới — đúng nguyên tắc Dependency Inversion đã nêu ở `SYSTEM_ARCHITECTURE.md`.

Ký hiệu dùng trong tài liệu:
- 🌐 **REST thật** — endpoint HTTP thật (TheMealDB).
- 🔥 **Logical (Firebase SDK)** — hợp đồng logic tương đương REST, triển khai thực tế bằng Firebase SDK.

Module **Admin** không được liệt kê — đã xác nhận ngoài phạm vi MVP ở `PROJECT_REQUIREMENTS.md` và `BUSINESS_FLOW.md`, không có API nào cần thiết kế cho vai trò này.

---

## Response Format thống nhất

Vì có 2 nguồn dữ liệu khác nhau (REST thật trả JSON theo cấu trúc riêng của TheMealDB, Firebase SDK trả object/Exception riêng của SDK), tầng Service/Repository chuẩn hóa **mọi kết quả** về cùng một hình dạng (envelope) trước khi đưa lên State Layer, đảm bảo Presentation Layer luôn xử lý theo một cách duy nhất bất kể nguồn dữ liệu gốc là gì:

**Khi thành công:**
```
{
  "success": true,
  "data": { ... }          // object hoặc array, tùy endpoint
}
```

**Khi thất bại:**
```
{
  "success": false,
  "error": {
    "code": "APP_ERROR_CODE",     // mã lỗi chuẩn hóa nội bộ, xem mục "Status Code chuẩn hóa"
    "message": "Thông báo thân thiện hiển thị cho người dùng"
  }
}
```

Envelope này là **hợp đồng nội bộ giữa Data Layer và State Layer** (không phải payload thật gửi qua mạng đối với Firebase SDK) — với TheMealDB, đây là hình dạng mà `MealApiService` map lại từ JSON response gốc trước khi trả về Provider.

---

## Status Code chuẩn hóa (Normalized App Status Code)

Vì Firebase SDK không trả HTTP status code, và TheMealDB REST trả HTTP status thật nhưng không đủ chi tiết cho mọi tình huống nghiệp vụ, hệ thống định nghĩa một bộ **App Status Code** dùng chung cho toàn bộ Response Format ở trên, được Data Layer map từ nguồn lỗi gốc:

| App Status Code | Ý nghĩa | Nguồn gốc tương ứng |
|---|---|---|
| `OK` | Thành công | HTTP 200 (TheMealDB) / Firebase operation thành công |
| `VALIDATION_ERROR` | Input không hợp lệ, bị chặn trước khi gửi request | Kiểm tra ở Presentation/State layer trước khi gọi Data layer |
| `UNAUTHENTICATED` | Chưa đăng nhập nhưng thao tác yêu cầu đăng nhập | Không có Firebase Auth session hợp lệ |
| `UNAUTHORIZED` | Đã đăng nhập nhưng không có quyền trên tài nguyên | Firestore Security Rules từ chối (`permission-denied`) |
| `NOT_FOUND` | Không tìm thấy dữ liệu | HTTP 404 hoặc kết quả rỗng/`null` (TheMealDB) / document không tồn tại (Firestore) |
| `CONFLICT` | Xung đột trạng thái (ví dụ tạo lại tài khoản email đã tồn tại) | `auth/email-already-in-use` (Firebase Auth) |
| `NETWORK_ERROR` | Mất kết nối mạng hoặc timeout | Timeout ở HTTP client / lỗi mạng của Firebase SDK |
| `SERVICE_UNAVAILABLE` | Nguồn dữ liệu tạm thời không phản hồi | HTTP 5xx (TheMealDB) / Firestore `unavailable` |
| `UNKNOWN_ERROR` | Lỗi không xác định, dự phòng | Mọi exception không map được vào nhóm trên |

Bảng này là tài liệu tham chiếu chung; các mục Status Code ở từng endpoint bên dưới chỉ liệt kê các mã có khả năng xảy ra thực tế với endpoint đó.

---

# Module: Authentication

Đăng nhập/đăng ký/đăng xuất là các Logical Endpoint 🔥, triển khai bằng Firebase Authentication SDK.

## 1. Register — Đăng ký tài khoản 🔥

- **Endpoint (logic):** `POST /auth/register`
- **HTTP Method (tương đương):** POST
- **Request:**
  - Body: `{ "email": string, "password": string }`
- **Response (thành công):**
  - `{ "success": true, "data": { "uid": string, "email": string } }`
- **Validation:**
  - Email đúng định dạng chuẩn (regex email).
  - Password ≥ 6 ký tự.
  - Không để trống các trường bắt buộc.
  - (Thực hiện ở Presentation/State layer trước khi gọi, chặn request không hợp lệ từ sớm.)
- **Authentication:** Không yêu cầu (đây là endpoint tạo danh tính mới).
- **Authorization:** Không áp dụng (không có tài nguyên nào bị giới hạn quyền ở bước này).
- **Status Code:** `OK`, `VALIDATION_ERROR`, `CONFLICT` (email đã tồn tại), `NETWORK_ERROR`, `UNKNOWN_ERROR`.
- **Error Response:**
  - `{ "success": false, "error": { "code": "CONFLICT", "message": "Email đã được sử dụng." } }`
- **Business Rules:**
  - BR-05: Email hợp lệ, password ≥ 6 ký tự.
  - Sau khi tạo tài khoản Auth thành công, hệ thống phải tạo kèm document `users/{uid}` trên Firestore (2 bước tuần tự, có compensating logic nếu bước 2 thất bại — xem `DATABASE_DESIGN.md` mục 11 Transaction Boundaries).
- **Pagination / Filter / Sort / Search:** Không áp dụng.
- **Upload / Download:** Không áp dụng.
- **Versioning:** Không áp dụng (không có version cho Firebase Auth SDK do NutriCook kiểm soát).

## 2. Login — Đăng nhập 🔥

- **Endpoint (logic):** `POST /auth/login`
- **Request:** `{ "email": string, "password": string }`
- **Response (thành công):** `{ "success": true, "data": { "uid": string, "email": string } }`
- **Validation:** Email đúng định dạng, không để trống trường nào.
- **Authentication:** Không yêu cầu (đây chính là hành động xác thực).
- **Authorization:** Không áp dụng.
- **Status Code:** `OK`, `VALIDATION_ERROR`, `UNAUTHENTICATED` (sai email/password), `NOT_FOUND` (tài khoản không tồn tại), `NETWORK_ERROR`, `UNKNOWN_ERROR`.
- **Error Response:** `{ "success": false, "error": { "code": "UNAUTHENTICATED", "message": "Email hoặc mật khẩu không đúng." } }`
- **Business Rules:** Không phân biệt rõ "sai email" và "sai mật khẩu" trong message hiển thị (thông lệ bảo mật chuẩn — tránh lộ thông tin email nào đã đăng ký).
- **Pagination / Filter / Sort / Search / Upload / Download / Versioning:** Không áp dụng.

## 3. Logout — Đăng xuất 🔥

- **Endpoint (logic):** `POST /auth/logout`
- **Request:** Không có body (dùng session hiện tại).
- **Response:** `{ "success": true, "data": null }`
- **Validation:** Không áp dụng.
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Không áp dụng (luôn thao tác trên session của chính mình).
- **Status Code:** `OK`, `UNKNOWN_ERROR`.
- **Error Response:** Hiếm khi xảy ra; nếu có, trả `UNKNOWN_ERROR` kèm message chung.
- **Business Rules:** Sau khi đăng xuất, mọi state cục bộ liên quan dữ liệu cá nhân (Favorite, Profile) phải được giải phóng/reset ở State layer.
- **Pagination / Filter / Sort / Search / Upload / Download / Versioning:** Không áp dụng.

## 4. Get Auth Session — Kiểm tra trạng thái đăng nhập hiện tại 🔥

- **Endpoint (logic):** `GET /auth/session`
- **Request:** Không có input.
- **Response:** `{ "success": true, "data": { "isAuthenticated": boolean, "uid": string | null } }`
- **Validation:** Không áp dụng.
- **Authentication:** Không yêu cầu (chính là endpoint để xác định có đang xác thực hay không).
- **Authorization:** Không áp dụng.
- **Status Code:** `OK`.
- **Error Response:** Không áp dụng (endpoint không throw lỗi nghiệp vụ, chỉ trả trạng thái hiện tại).
- **Business Rules:** Đây là endpoint dùng để quyết định điều hướng Splash → Home hoặc Splash → Login (theo `SYSTEM_ARCHITECTURE.md` mục Authentication Flow); thực chất triển khai bằng lắng nghe Stream (`authStateChanges()`), không phải một lần gọi đơn lẻ.
- **Pagination / Filter / Sort / Search / Upload / Download / Versioning:** Không áp dụng.

---

# Module: Home (Meal Discovery)

Toàn bộ endpoint trong module này là REST thật 🌐, do TheMealDB cung cấp, ứng dụng chỉ tiêu thụ.

## 1. Get Default Meals 🌐

- **Endpoint:** `GET https://www.themealdb.com/api/json/v1/1/search.php?f=b`
- **HTTP Method:** GET
- **Request:** Query param `f` cố định = `b` (lấy món bắt đầu bằng chữ 'b', theo quyết định đã xác nhận ở `PROJECT_REQUIREMENTS.md`).
- **Response (thành công):**
  - JSON gốc từ TheMealDB: `{ "meals": [ { "idMeal": ..., "strMeal": ..., "strMealThumb": ..., ... } ] }`
  - Sau khi Data Layer chuẩn hóa: `{ "success": true, "data": [ MealModel, ... ] }`
- **Validation:** Không áp dụng (không có input người dùng).
- **Authentication:** Không yêu cầu (API public), nhưng **màn hình gọi endpoint này yêu cầu người dùng đã đăng nhập** (chặn ở tầng route/Presentation, không phải ở API — theo BR-06).
- **Authorization:** Không áp dụng (dữ liệu công khai, không phân quyền theo user).
- **Status Code:** `OK`, `NOT_FOUND` (trường hợp hiếm, `meals: null`), `NETWORK_ERROR`, `SERVICE_UNAVAILABLE`, `UNKNOWN_ERROR`.
- **Error Response:** `{ "success": false, "error": { "code": "NETWORK_ERROR", "message": "Không thể tải danh sách món ăn, vui lòng kiểm tra kết nối mạng." } }`
- **Business Rules:** BR-07 — dữ liệu luôn lấy trực tiếp tại thời điểm gọi, không cache lâu dài.
- **Pagination:** **Không hỗ trợ** — TheMealDB không cung cấp tham số phân trang cho endpoint này; toàn bộ kết quả (thường vài chục món) trả về trong một lần gọi.
- **Filter / Sort / Search:** Không áp dụng cho endpoint này (đây là danh sách cố định theo chữ cái, xem module Search & Filter cho các endpoint có filter/search thật).
- **Upload / Download:** Không áp dụng.
- **Versioning:** URL đã chứa version `v1` do TheMealDB định nghĩa và kiểm soát — NutriCook không có quyền/khả năng thay đổi versioning của API này.

---

# Module: Search & Filter

Tất cả REST thật 🌐, do TheMealDB cung cấp.

## 1. Search Meal by Name 🌐

- **Endpoint:** `GET https://www.themealdb.com/api/json/v1/1/search.php?s={keyword}`
- **HTTP Method:** GET
- **Request:** Query param `s` = từ khóa tìm kiếm (chuỗi tên món, có thể một phần).
- **Response:** Giống cấu trúc Get Default Meals; `meals: null` nếu không có kết quả khớp.
- **Validation:** Từ khóa không được rỗng trước khi gọi API (chặn ở State layer — nếu rỗng thì không gọi API, giữ nguyên danh sách hiện tại).
- **Authentication:** Không yêu cầu ở API; màn hình chứa chức năng này yêu cầu đã đăng nhập.
- **Authorization:** Không áp dụng.
- **Status Code:** `OK`, `NOT_FOUND` (không có kết quả — phân biệt rõ với lỗi thật, xem `BUSINESS_FLOW.md` mục Search & Filter), `NETWORK_ERROR`, `SERVICE_UNAVAILABLE`.
- **Error Response:** Tương tự Home; riêng trường hợp `meals: null` được map thành trạng thái "danh sách rỗng" (`OK` với `data: []`), **không** map thành lỗi `NOT_FOUND` ở tầng UI (tránh nhầm lẫn giữa "lỗi" và "không có kết quả").
- **Business Rules:** BR-07 áp dụng tương tự Home.
- **Pagination:** Không hỗ trợ (giới hạn từ TheMealDB).
- **Filter:** Không áp dụng cho endpoint này (search theo tên, không kết hợp filter category — xem đề xuất ở mục Business Rules bên dưới).
- **Sort:** TheMealDB không hỗ trợ tham số sort; thứ tự trả về theo mặc định của nguồn dữ liệu.
- **Search:** Đây chính là endpoint search — tìm theo tên món, so khớp một phần (partial match) do TheMealDB xử lý.
- **Upload / Download:** Không áp dụng.
- **Versioning:** Do TheMealDB kiểm soát (`v1`).

## 2. Filter Meal by Category 🌐

- **Endpoint:** `GET https://www.themealdb.com/api/json/v1/1/filter.php?c={category}`
- **HTTP Method:** GET
- **Request:** Query param `c` = tên danh mục (ví dụ `Seafood`, `Vegetarian`).
- **Response:** `{ "meals": [ { "strMeal", "strMealThumb", "idMeal" } ] }` — **lưu ý:** endpoint filter của TheMealDB trả về ít field hơn endpoint search/lookup (không có nguyên liệu/hướng dẫn) — cần gọi thêm Meal Detail nếu người dùng chọn xem chi tiết từ kết quả filter.
- **Validation:** Category phải thuộc danh sách hợp lệ do TheMealDB định nghĩa (khuyến nghị lấy danh sách category qua endpoint `list.php?c=list` thay vì hard-code, để tránh sai lệch nếu TheMealDB cập nhật danh mục).
- **Authentication:** Không yêu cầu ở API; màn hình yêu cầu đã đăng nhập.
- **Authorization:** Không áp dụng.
- **Status Code:** `OK`, `NOT_FOUND` (rỗng), `NETWORK_ERROR`, `SERVICE_UNAVAILABLE`.
- **Error Response:** Tương tự Search by Name.
- **Business Rules:** Theo đề xuất tại `BUSINESS_FLOW.md`, khi người dùng chọn filter category, hệ thống nên tự xóa từ khóa search đang có (và ngược lại) để tránh trạng thái mập mờ — vì TheMealDB không hỗ trợ kết hợp cả hai điều kiện trong một request.
- **Pagination:** Không hỗ trợ.
- **Filter:** Đây chính là endpoint filter theo category.
- **Sort:** Không hỗ trợ tham số sort.
- **Search:** Không áp dụng (không kết hợp tìm theo tên trong cùng request).
- **Upload / Download:** Không áp dụng.
- **Versioning:** Do TheMealDB kiểm soát.

---

# Module: Meal Detail

## 1. Get Meal Detail by ID 🌐

- **Endpoint:** `GET https://www.themealdb.com/api/json/v1/1/lookup.php?i={idMeal}`
- **HTTP Method:** GET
- **Request:** Query param `i` = `idMeal`.
- **Response:** `{ "meals": [ { đầy đủ field: strMeal, strMealThumb, strInstructions, strIngredient1..20, strMeasure1..20, strCategory, ... } ] }` (mảng chỉ chứa 1 phần tử, hoặc `null` nếu không tìm thấy).
- **Validation:** `idMeal` phải là chuỗi hợp lệ (không rỗng) — thường luôn có sẵn vì được truyền từ kết quả danh sách trước đó, hiếm khi người dùng tự nhập.
- **Authentication:** Không yêu cầu ở API; màn hình yêu cầu đã đăng nhập.
- **Authorization:** Không áp dụng (dữ liệu công khai).
- **Status Code:** `OK`, `NOT_FOUND` (món ăn không còn tồn tại trên TheMealDB), `NETWORK_ERROR`, `SERVICE_UNAVAILABLE`.
- **Error Response:** `{ "success": false, "error": { "code": "NOT_FOUND", "message": "Không tìm thấy thông tin món ăn này." } }`
- **Business Rules:** BR-07; đồng thời sau khi lấy chi tiết thành công, ứng dụng gọi tiếp **Get Favorite Status** (module Favorite, mục 3) để xác định trạng thái nút yêu thích — đây là 2 lời gọi độc lập, không gộp chung thành 1 request.
- **Pagination / Filter / Sort / Search:** Không áp dụng (trả về đúng 1 món ăn).
- **Upload / Download:** Không áp dụng.
- **Versioning:** Do TheMealDB kiểm soát.

---

# Module: Favorite

Toàn bộ Logical Endpoint 🔥, triển khai bằng Cloud Firestore SDK, tương ứng thiết kế dữ liệu ở `DATABASE_DESIGN.md`.

## 1. Add Favorite (Create) 🔥

- **Endpoint (logic):** `POST /favorites/{idMeal}`
- **Request:** `{ "idMeal": string, "mealName": string, "mealThumbnail": string }`
- **Response:** `{ "success": true, "data": { "idMeal": string, "createdAt": timestamp } }`
- **Validation:** `idMeal`, `mealName`, `mealThumbnail` không được rỗng (dữ liệu này lấy từ MealModel đã fetch trước đó, không do người dùng gõ tay).
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Chỉ được ghi vào đúng `users/{uid}/favorites` của chính mình — thực thi qua Firestore Security Rules (`request.auth.uid == uid` trong path).
- **Status Code:** `OK`, `UNAUTHENTICATED`, `UNAUTHORIZED`, `NETWORK_ERROR`, `UNKNOWN_ERROR`.
- **Error Response:** `{ "success": false, "error": { "code": "UNAUTHORIZED", "message": "Bạn không có quyền thực hiện thao tác này." } }`
- **Business Rules:** BR-01, BR-02 (idempotent theo `idMeal` — gọi lại nhiều lần không tạo trùng, dùng `set()` thay vì `add()`); nên bọc trong Firestore Transaction khi kết hợp với thao tác kiểm tra tồn tại (xem `DATABASE_DESIGN.md` mục 11).
- **Pagination / Filter / Sort / Search:** Không áp dụng.
- **Upload / Download:** Không áp dụng — ảnh món ăn dùng lại URL có sẵn từ TheMealDB (`mealThumbnail`), không upload file.
- **Versioning:** Không áp dụng.

## 2. Remove Favorite (Delete) 🔥

- **Endpoint (logic):** `DELETE /favorites/{idMeal}`
- **Request:** Không có body, `idMeal` trên path.
- **Response:** `{ "success": true, "data": null }`
- **Validation:** `idMeal` không rỗng.
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Chỉ xóa được document thuộc `users/{uid}` của chính mình.
- **Status Code:** `OK`, `UNAUTHENTICATED`, `UNAUTHORIZED`, `NOT_FOUND` (đã xóa từ trước — coi là thành công, idempotent), `NETWORK_ERROR`.
- **Error Response:** Tương tự Add Favorite.
- **Business Rules:** BR-02 — thao tác idempotent, xóa lần 2 với cùng `idMeal` không gây lỗi.
- **Pagination / Filter / Sort / Search / Upload / Download / Versioning:** Không áp dụng.

## 3. Get Favorite Status (Single) 🔥

- **Endpoint (logic):** `GET /favorites/{idMeal}`
- **Request:** `idMeal` trên path.
- **Response:** `{ "success": true, "data": { "isFavorited": boolean, "note": string | null } }`
- **Validation:** Không áp dụng.
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Chỉ đọc được document thuộc `users/{uid}` của chính mình.
- **Status Code:** `OK`, `UNAUTHENTICATED`, `UNAUTHORIZED`, `NETWORK_ERROR`.
- **Error Response:** `{ "success": false, "error": { "code": "NETWORK_ERROR", "message": "Không thể kiểm tra trạng thái yêu thích." } }`
- **Business Rules:** Dùng ở Meal Detail để hiển thị đúng trạng thái icon trái tim.
- **Pagination / Filter / Sort / Search / Upload / Download / Versioning:** Không áp dụng.

## 4. Get Favorite List (Realtime) 🔥

- **Endpoint (logic):** `GET /favorites` (triển khai thực tế: subscribe qua Firestore `snapshots()`, không phải một lần gọi HTTP đơn thuần)
- **Request:** Không có input bắt buộc.
- **Response:** `{ "success": true, "data": [ { "idMeal", "mealName", "mealThumbnail", "note", "createdAt" }, ... ] }`, cập nhật liên tục mỗi khi dữ liệu thay đổi (push từ Firestore, không cần client tự gọi lại).
- **Validation:** Không áp dụng.
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Chỉ đọc được sub-collection thuộc `users/{uid}` của chính mình.
- **Status Code:** `OK` (mỗi lần có snapshot mới), `UNAUTHENTICATED`, `UNAUTHORIZED`, `NETWORK_ERROR` (listener bị gián đoạn).
- **Error Response:** `{ "success": false, "error": { "code": "NETWORK_ERROR", "message": "Mất kết nối, danh sách yêu thích có thể chưa cập nhật mới nhất." } }`
- **Business Rules:** FR-FAV-06 — đồng bộ thời gian thực.
- **Pagination:** **MVP không phân trang** — toàn bộ danh sách favorite của một user được fetch một lần (số lượng dự kiến nhỏ, phù hợp quy mô cá nhân). Khuyến nghị áp dụng giới hạn an toàn `limit(100)` kèm sắp xếp, và bổ sung cursor-based pagination (`startAfter`) nếu tương lai số lượng tăng lớn (Future Enhancement, không phá vỡ schema hiện tại).
- **Filter:** Không hỗ trợ trong MVP (không lọc favorite theo category — đã ghi nhận là đề xuất mở rộng ở `BUSINESS_FLOW.md`, cần bổ sung field `mealCategory` nếu triển khai).
- **Sort:** Mặc định sắp xếp theo `createdAt` giảm dần (món mới thêm hiện trước).
- **Search:** Không hỗ trợ tìm kiếm trong danh sách favorite ở MVP (danh sách thường nhỏ, không cần thiết).
- **Upload / Download:** Không áp dụng.
- **Versioning:** Không áp dụng.

## 5. Update Favorite Note 🔥

- **Endpoint (logic):** `PATCH /favorites/{idMeal}`
- **Request:** `{ "note": string }`
- **Response:** `{ "success": true, "data": { "idMeal": string, "note": string, "updatedAt": timestamp } }`
- **Validation:** Độ dài ghi chú nên giới hạn (khuyến nghị tối đa 200–500 ký tự, đã đề xuất ở `BUSINESS_FLOW.md`); có thể để trống (xóa ghi chú).
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Chỉ cập nhật được document thuộc `users/{uid}` của chính mình.
- **Status Code:** `OK`, `VALIDATION_ERROR` (vượt giới hạn ký tự), `UNAUTHENTICATED`, `UNAUTHORIZED`, `NOT_FOUND` (favorite đã bị xóa trước đó), `NETWORK_ERROR`.
- **Error Response:** `{ "success": false, "error": { "code": "VALIDATION_ERROR", "message": "Ghi chú không được vượt quá 500 ký tự." } }`
- **Business Rules:** BR-03 — ghi chú là dữ liệu riêng tư, chỉ chủ sở hữu đọc/sửa được.
- **Pagination / Filter / Sort / Search / Upload / Download / Versioning:** Không áp dụng.

---

# Module: Profile

Logical Endpoint 🔥, triển khai bằng Cloud Firestore SDK.

## 1. Get Profile 🔥

- **Endpoint (logic):** `GET /users/{uid}`
- **Request:** `uid` lấy từ session hiện tại (không truyền tay).
- **Response:** `{ "success": true, "data": { "uid", "email", "name", "height", "targetWeight" } }`
- **Validation:** Không áp dụng.
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Chỉ đọc được document `users/{uid}` của chính mình.
- **Status Code:** `OK`, `UNAUTHENTICATED`, `UNAUTHORIZED`, `NOT_FOUND` (trường hợp hiếm — document chưa được tạo do lỗi ở bước Register, xem compensating logic ở module Authentication), `NETWORK_ERROR`.
- **Error Response:** `{ "success": false, "error": { "code": "NOT_FOUND", "message": "Không tìm thấy hồ sơ người dùng." } }`
- **Business Rules:** Không áp dụng thêm ngoài Authorization.
- **Pagination / Filter / Sort / Search / Upload / Download / Versioning:** Không áp dụng.

## 2. Update Profile 🔥

- **Endpoint (logic):** `PATCH /users/{uid}`
- **Request:** `{ "name": string, "height": number, "targetWeight": number }` (cho phép cập nhật một phần, chỉ gửi field thay đổi).
- **Response:** `{ "success": true, "data": { "uid", "name", "height", "targetWeight", "updatedAt" } }`
- **Validation:**
  - `name` không rỗng.
  - `height`, `targetWeight` là số dương (BR-04), không chấp nhận 0 hoặc âm.
- **Authentication:** Yêu cầu đã đăng nhập.
- **Authorization:** Chỉ cập nhật được document `users/{uid}` của chính mình.
- **Status Code:** `OK`, `VALIDATION_ERROR`, `UNAUTHENTICATED`, `UNAUTHORIZED`, `NETWORK_ERROR`.
- **Error Response:** `{ "success": false, "error": { "code": "VALIDATION_ERROR", "message": "Chiều cao phải là số dương." } }`
- **Business Rules:** BR-04.
- **Pagination / Filter / Sort / Search:** Không áp dụng.
- **Upload / Download:** Không áp dụng cho MVP — không có tính năng upload ảnh đại diện (theo Out of Scope ở `PROJECT_REQUIREMENTS.md` và `SYSTEM_ARCHITECTURE.md` mục File Upload Flow).
- **Versioning:** Không áp dụng.

---

# Chính sách chung áp dụng toàn hệ thống

## Pagination
- **TheMealDB (Home, Search, Filter, Detail):** Không hỗ trợ phân trang — giới hạn từ phía nhà cung cấp, ứng dụng chấp nhận nhận toàn bộ kết quả trong một lần gọi (dữ liệu TheMealDB theo từng truy vấn thường không quá lớn, chấp nhận được cho MVP).
- **Favorite List:** Không phân trang trong MVP (dữ liệu cá nhân, quy mô nhỏ theo từng user); có điểm mở rộng bằng Firestore cursor-based pagination (`startAfter(lastDoc)`) nếu cần trong tương lai.
- **Profile:** Không áp dụng (luôn là 1 document).

## Filter
- Chỉ tồn tại ở module Search & Filter (filter theo category qua TheMealDB). Không có filter nào do NutriCook tự xây dựng ở tầng ứng dụng cho MVP.

## Sort
- TheMealDB không hỗ trợ tham số sort — thứ tự do nguồn dữ liệu quyết định.
- Favorite List sắp xếp mặc định theo `createdAt` giảm dần, thực hiện qua Firestore `orderBy('createdAt', descending: true)`.

## Search
- Chức năng search thật duy nhất là "Search Meal by Name" (module Search & Filter), ủy quyền hoàn toàn cho TheMealDB xử lý so khớp.
- Không có search nội bộ trên dữ liệu Firestore (Favorite) trong MVP.

## Upload
- **Không có bất kỳ endpoint upload nào trong MVP.** Toàn bộ hình ảnh hiển thị (món ăn) đến từ URL có sẵn của TheMealDB. Không có avatar người dùng, không có ảnh tự chụp. (Nhất quán với `SYSTEM_ARCHITECTURE.md` mục 14 — File Upload Flow ngoài phạm vi MVP.)

## Download
- Không có endpoint download file trong MVP (không có export dữ liệu, không có tải file đính kèm).

## Versioning
- **TheMealDB:** version API do nhà cung cấp kiểm soát hoàn toàn (hiện tại `v1` trong URL); NutriCook không có khả năng và không cần quản lý version cho API này.
- **Logical Endpoint (Firebase SDK):** không áp dụng versioning kiểu URL (`/v1/...`) vì không phải HTTP endpoint thật. Nếu schema dữ liệu Firestore thay đổi cấu trúc lớn trong tương lai, khuyến nghị bổ sung field `schemaVersion` trong document để hỗ trợ migration dần dần — không cần thiết cho MVP hiện tại.
- **Toàn hệ thống:** nếu tương lai NutriCook chuyển sang có backend REST tự viết (Future Enhancement), khuyến nghị áp dụng versioning qua path prefix (`/api/v1/...`) ngay từ endpoint đầu tiên được xây dựng, để tránh breaking change cho client khi mở rộng.

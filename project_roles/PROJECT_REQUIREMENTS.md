# PROJECT_REQUIREMENTS.md — NutriCook (PRM393)

Tài liệu này đặc tả yêu cầu (requirements) đầy đủ cho dự án NutriCook, dựa trên `NutriCook_Project_PRM393.txt` và tuân thủ nguyên tắc trong `PROJECT_GUIDELINES.md`. Đây là tài liệu tham chiếu để phát triển MVP đúng phạm vi, không thiếu, không thừa.

---

# Project Overview

NutriCook là ứng dụng di động (Flutter, phạm vi build/test chính thức là **iOS Simulator**) giúp người dùng tra cứu công thức nấu ăn từ nguồn dữ liệu công khai (TheMealDB API) và quản lý thực đơn cá nhân của riêng họ. Ứng dụng giải quyết bài toán "hôm nay ăn gì", đóng vai trò như một sổ tay nấu ăn thông minh: người dùng có thể tìm kiếm, lọc món ăn, xem chi tiết nguyên liệu/các bước thực hiện/calo ước tính, lưu món yêu thích kèm ghi chú cá nhân, và quản lý hồ sơ sức khỏe cơ bản (chiều cao, cân nặng).

Dự án được thực hiện trong khuôn khổ đồ án môn học PRM393 (Team Wizards, sinh viên thực hiện: Trung Nhân), với mục tiêu vừa đáp ứng đầy đủ barem điểm kỹ thuật của môn học, vừa là một sản phẩm MVP thực tế có thể demo và mở rộng sau này.

---

# Business Goal

- Cung cấp cho người dùng cuối một công cụ tra cứu công thức nấu ăn tập trung, không quảng cáo, tối ưu cho việc sử dụng ngay trong bếp.
- Cho phép cá nhân hóa trải nghiệm nấu ăn thông qua việc lưu trữ món yêu thích kèm ghi chú riêng — điều các trang web công thức thông thường không hỗ trợ.
- Hỗ trợ người dùng theo dõi sức khỏe một cách chủ động thông qua thông tin dinh dưỡng/calo đi kèm mỗi món ăn.
- Về mặt học thuật: chứng minh năng lực triển khai đầy đủ một ứng dụng Flutter production-ready có tích hợp Firebase (Authentication, Cloud Firestore), REST API bên ngoài, CRUD hoàn chỉnh, input validation và exception handling — đúng theo các tiêu chí chấm điểm của môn PRM393.

---

# Scope của MVP

Phạm vi MVP bao gồm:

1. Đăng ký / Đăng nhập / Đăng xuất bằng Email & Password qua Firebase Authentication.
2. Duy trì phiên đăng nhập (auto-login) và điều hướng dựa trên Auth State.
3. Trang chủ hiển thị danh sách món ăn lấy từ TheMealDB API (mặc định danh sách món bắt đầu bằng ký tự 'b').
4. Tìm kiếm món ăn theo tên (Search) qua TheMealDB API.
5. Lọc món ăn theo danh mục (Filter theo category, ví dụ Seafood, Vegetarian...).
6. Xem chi tiết món ăn: hình ảnh, nguyên liệu, hướng dẫn từng bước, calo ước tính.
7. Đánh dấu / bỏ đánh dấu món ăn yêu thích (Create/Delete trên Firestore).
8. Xem danh sách món ăn yêu thích đã lưu (Read).
9. Thêm/sửa ghi chú cá nhân cho từng món ăn yêu thích (Update).
10. Xóa món khỏi danh sách yêu thích (Delete, thao tác vuốt để xóa).
11. Xem và cập nhật hồ sơ cá nhân: tên, chiều cao, cân nặng mục tiêu (Update).
12. Input validation cho các form: đăng ký, đăng nhập, profile.
13. Xử lý lỗi (exception handling) cho các trường hợp: mất mạng, lỗi API, sai thông tin đăng nhập, hiển thị qua SnackBar/Dialog thân thiện.
14. Build và kiểm thử ứng dụng trên **iOS Simulator** (`flutter run`/`flutter build ios` qua Xcode) trong suốt giai đoạn phát triển MVP hiện tại — do máy phát triển là MacBook, không có sẵn thiết bị/máy Android để build APK. Sau khi hoàn thành MVP, codebase sẽ được **bàn giao cho một thành viên khác** để build APK và kiểm thử trên thiết bị Android thật, đúng yêu cầu gốc của đề bài (xem Constraints để biết chi tiết kế hoạch bàn giao).

---

# Out of Scope

Các hạng mục sau **không** thuộc phạm vi MVP hiện tại (có thể cân nhắc ở giai đoạn mở rộng sau này — xem mục Future Enhancements):

- Đăng nhập bằng mạng xã hội (Google, Facebook Sign-In).
- Đặt lại mật khẩu qua email thực tế (Forgot Password) — dù đề bài Giai đoạn 2 có nhắc thiết kế UI, nhưng logic gửi email khôi phục không nằm trong barem điểm bắt buộc, cần làm rõ trước khi triển khai (xem mục "Nếu phát hiện requirement còn thiếu").
- Vai trò Admin / trang quản trị nội dung (không có yêu cầu quản trị món ăn, quản lý người dùng trong đề bài gốc).
- Tự tạo/chỉnh sửa công thức nấu ăn mới (chỉ tiêu thụ dữ liệu từ TheMealDB, không có CRUD công thức gốc).
- Tính năng lập kế hoạch thực đơn theo tuần/tháng (Meal Planning Calendar).
- Tính năng đi chợ thông minh (gộp nguyên liệu nhiều món thành 1 shopping list).
- Thông báo đẩy (Push Notification).
- Chia sẻ công thức/ghi chú lên mạng xã hội.
- Chế độ offline hoàn toàn (offline-first / local database đầy đủ).
- Đa ngôn ngữ (i18n) — mặc định 1 ngôn ngữ cho MVP.
- Thanh toán / tính năng premium.
- Tính calo tự động chính xác theo khẩu phần cá nhân (chỉ dùng số liệu ước tính từ API hoặc ước lượng đơn giản).

---

# Actors

## 1. Guest (Người dùng chưa đăng nhập)

- **Vai trò:** Người dùng mới truy cập ứng dụng lần đầu, chưa có tài khoản hoặc chưa đăng nhập.
- **Quyền:** Chỉ truy cập màn hình Splash, Login, Register. Không truy cập được Home, Favorite, Profile.
- **Chức năng:**
  - Đăng ký tài khoản mới (Email/Password).
  - Đăng nhập vào ứng dụng.

## 2. Registered User (Người dùng đã đăng ký/đăng nhập)

- **Vai trò:** Người dùng chính của ứng dụng, đã xác thực qua Firebase Auth.
- **Quyền:** Toàn quyền truy cập các tính năng MVP; chỉ đọc/ghi được dữ liệu thuộc về chính tài khoản của mình (favorites, profile) — không truy cập dữ liệu của user khác (được đảm bảo qua Firestore Security Rules).
- **Chức năng:**
  - Xem danh sách món ăn nổi bật/mặc định trên Home.
  - Tìm kiếm món ăn theo tên.
  - Lọc món ăn theo danh mục.
  - Xem chi tiết món ăn (nguyên liệu, hướng dẫn, calo).
  - Thêm/xóa món ăn khỏi danh sách yêu thích.
  - Xem danh sách món yêu thích của riêng mình.
  - Thêm/sửa ghi chú cá nhân cho món yêu thích.
  - Xem và cập nhật thông tin hồ sơ cá nhân (tên, chiều cao, cân nặng mục tiêu).
  - Đăng xuất khỏi ứng dụng.

## 3. System / External Service (không phải actor người dùng, nhưng cần mô tả vì tham gia trực tiếp vào luồng)

- **TheMealDB API (Public REST API):** Cung cấp dữ liệu món ăn (danh sách, tìm kiếm, lọc, chi tiết). Không yêu cầu xác thực người dùng cuối, dùng chung API key public (`1`).
- **Firebase Authentication:** Xác thực và quản lý phiên đăng nhập người dùng.
- **Cloud Firestore:** Lưu trữ dữ liệu cá nhân của người dùng (profile, favorites).

> Ghi chú: Đề bài gốc không đề cập vai trò **Admin**. Mục "Admin" trong khung yêu cầu của người dùng được liệt kê như một module ví dụ tham khảo, nhưng không có yêu cầu nghiệp vụ nào trong tài liệu gốc mô tả chức năng quản trị. Xem phần "Nếu phát hiện requirement còn thiếu" để biết đề xuất.

---

# Functional Requirements

## Module: Authentication

- FR-AUTH-01: Hệ thống hiển thị màn hình Splash khi khởi động ứng dụng.
- FR-AUTH-02: Hệ thống tự động kiểm tra Auth State; nếu đã đăng nhập trước đó, điều hướng thẳng vào Home; nếu chưa, điều hướng vào Login.
- FR-AUTH-03: Người dùng có thể đăng ký tài khoản mới bằng Email & Password.
- FR-AUTH-04: Người dùng có thể đăng nhập bằng Email & Password đã đăng ký.
- FR-AUTH-05: Hệ thống validate định dạng Email hợp lệ trước khi submit.
- FR-AUTH-06: Hệ thống validate Password tối thiểu 6 ký tự.
- FR-AUTH-07: Hệ thống không cho phép submit form khi còn trường bắt buộc bị bỏ trống.
- FR-AUTH-08: Hệ thống hiển thị thông báo lỗi thân thiện khi đăng nhập/đăng ký thất bại (sai mật khẩu, email đã tồn tại, email không hợp lệ...).
- FR-AUTH-09: Người dùng có thể đăng xuất khỏi ứng dụng từ màn hình Profile.

## Module: Home

- FR-HOME-01: Hệ thống tự động fetch và hiển thị danh sách món ăn mặc định khi vào Home (ví dụ các món bắt đầu bằng ký tự 'b').
- FR-HOME-02: Danh sách món ăn hiển thị dạng lưới hoặc danh sách (GridView/ListView) kèm hình ảnh và tên món.
- FR-HOME-03: Hệ thống hiển thị trạng thái loading khi đang tải dữ liệu.
- FR-HOME-04: Hệ thống hiển thị trạng thái lỗi thân thiện khi fetch dữ liệu thất bại (mất mạng, lỗi API).
- FR-HOME-05: Người dùng có thể nhấn vào một món ăn để chuyển sang màn hình chi tiết.

## Module: Search & Filter

- FR-SEARCH-01: Người dùng có thể nhập từ khóa vào thanh Search để tìm món ăn theo tên.
- FR-SEARCH-02: Hệ thống gọi API tìm kiếm và cập nhật danh sách kết quả tương ứng.
- FR-SEARCH-03: Hệ thống hiển thị trạng thái "không có kết quả" khi tìm kiếm không trả về món ăn nào.
- FR-SEARCH-04: Người dùng có thể chọn bộ lọc theo danh mục món ăn (ví dụ: thịt bò, hải sản, món chay).
- FR-SEARCH-05: Hệ thống cập nhật danh sách món ăn theo danh mục đã chọn.

## Module: Meal Detail

- FR-DETAIL-01: Hệ thống hiển thị đầy đủ thông tin chi tiết món ăn: hình ảnh, tên món, danh sách nguyên liệu, các bước thực hiện.
- FR-DETAIL-02: Hệ thống hiển thị thông tin calo ước tính của món ăn.
- FR-DETAIL-03: Màn hình chi tiết có nút "Yêu thích" (biểu tượng trái tim) để thêm/bỏ món khỏi danh sách yêu thích.
- FR-DETAIL-04: Trạng thái nút "Yêu thích" phản ánh đúng việc món ăn hiện có nằm trong danh sách yêu thích của người dùng hay không.

## Module: Favorite

- FR-FAV-01: Khi người dùng nhấn "Yêu thích", hệ thống tạo (Create) một bản ghi món ăn trong Firestore gắn với tài khoản người dùng hiện tại.
- FR-FAV-02: Người dùng có thể xem (Read) toàn bộ danh sách món ăn đã lưu trong tab Favorite/Menu.
- FR-FAV-03: Người dùng có thể vuốt để xóa (Delete) một món khỏi danh sách yêu thích.
- FR-FAV-04: Người dùng có thể thêm hoặc chỉnh sửa (Update) ghi chú cá nhân cho từng món ăn đã lưu (ví dụ: "Cần giảm nửa lượng đường").
- FR-FAV-05: Hệ thống hiển thị trạng thái rỗng thân thiện khi danh sách yêu thích chưa có món nào.
- FR-FAV-06: Dữ liệu yêu thích đồng bộ theo thời gian thực (hoặc cập nhật ngay) sau mỗi thao tác Create/Update/Delete.

## Module: Profile

- FR-PROFILE-01: Người dùng có thể xem thông tin tài khoản hiện tại (tên, email).
- FR-PROFILE-02: Người dùng có thể cập nhật tên hiển thị.
- FR-PROFILE-03: Người dùng có thể cập nhật chiều cao.
- FR-PROFILE-04: Người dùng có thể cập nhật cân nặng mục tiêu.
- FR-PROFILE-05: Hệ thống validate dữ liệu nhập vào (không âm, không để trống các trường bắt buộc, đúng kiểu số cho chiều cao/cân nặng).
- FR-PROFILE-06: Người dùng có thể đăng xuất từ màn hình này (liên kết FR-AUTH-09).

---

# Non-functional Requirements

## Performance
- Thời gian phản hồi khi fetch danh sách món ăn từ TheMealDB API phải hiển thị trạng thái loading nếu vượt quá ~1 giây, tránh cảm giác app đứng.
- Danh sách món ăn dùng `ListView.builder`/`GridView.builder` để tránh render toàn bộ dữ liệu cùng lúc khi danh sách dài.
- Ứng dụng phải phản hồi mượt (không giật, không đứng khung hình) khi thao tác cuộn danh sách hoặc chuyển màn hình trên iOS Simulator.

## Security
- Mật khẩu người dùng không được lưu trữ hoặc xử lý dưới dạng plain text ở phía client (dựa hoàn toàn vào cơ chế hash của Firebase Auth).
- Firestore Security Rules phải giới hạn mỗi người dùng chỉ đọc/ghi được dữ liệu (`favorites`, thông tin `profile`) thuộc chính tài khoản của họ.
- Không để lộ API key, cấu hình Firebase nhạy cảm trong mã nguồn public.
- Toàn bộ input từ người dùng (form đăng ký, đăng nhập, profile, ghi chú) phải được validate trước khi gửi lên Firebase/Firestore.

## Scalability
- Kiến trúc phân tầng (Presentation – State – Data) cho phép mở rộng thêm nguồn dữ liệu (API khác), thêm màn hình, hoặc thêm collection Firestore mà không cần viết lại toàn bộ ứng dụng.
- Schema Firestore (`users/{uid}/favorites/{mealId}`) có khả năng mở rộng thêm field mới (ví dụ tag, rating cá nhân) mà không phá vỡ dữ liệu hiện có.
- MVP không cần thiết kế cho quy mô lớn (hàng triệu người dùng đồng thời) — Firebase (Auth + Firestore) đã đủ đáp ứng quy mô đồ án học thuật và giai đoạn đầu sản phẩm thực tế.

## Maintainability
- Code tuân thủ cấu trúc thư mục và convention đã định nghĩa trong `PROJECT_GUIDELINES.md`.
- Model class tách biệt rõ với logic gọi API/Firestore, giúp dễ thay đổi nguồn dữ liệu trong tương lai.
- Không có logic nghiệp vụ quan trọng nào bị hard-code trực tiếp trong Widget UI.

## Availability
- Ứng dụng phải hoạt động ổn định khi mất kết nối mạng tạm thời: hiển thị thông báo lỗi rõ ràng thay vì crash hoặc treo màn hình.
- Vì TheMealDB là dịch vụ bên thứ ba miễn phí, ứng dụng phải xử lý được trường hợp API tạm thời không phản hồi hoặc trả lỗi mà không ảnh hưởng đến các tính năng khác (Favorite, Profile) vốn không phụ thuộc vào API này.

---

# User Stories

**Authentication**
- As a new user, I want to register an account with my email and password, so that I can access personalized features of the app.
- As a returning user, I want to log in with my email and password, so that I can access my saved data.
- As a logged-in user, I want the app to remember my session, so that I don't have to log in every time I open the app.
- As a user, I want to see clear error messages when login/registration fails, so that I know what went wrong and how to fix it.
- As a user, I want to log out of the app, so that I can protect my account on a shared device.

**Home**
- As a user, I want to see a list of meals as soon as I open the app, so that I can get inspiration for what to cook without searching manually.
- As a user, I want to see a loading indicator while meals are being fetched, so that I know the app is working and not frozen.

**Search & Filter**
- As a user, I want to search meals by name, so that I can quickly find a specific dish I have in mind.
- As a user, I want to filter meals by category (e.g., seafood, vegetarian), so that I can narrow down options based on my dietary preference.

**Meal Detail**
- As a user, I want to view a meal's ingredients, cooking steps, and estimated calories, so that I can decide whether to cook it and prepare accordingly.
- As a user, I want to mark a meal as favorite from the detail screen, so that I can save it for later without leaving the page.

**Favorite**
- As a user, I want to save meals I like to a favorites list, so that I don't lose track of recipes I found across different sessions.
- As a user, I want to view all my saved favorite meals in one place, so that I can quickly revisit them.
- As a user, I want to add a personal note to a saved meal (e.g., "reduce sugar next time"), so that I can remember my own adjustments.
- As a user, I want to remove a meal from my favorites by swiping, so that I can keep my list relevant and clutter-free.

**Profile**
- As a user, I want to update my name, height, and target weight, so that my profile reflects accurate personal health information.
- As a user, I want my profile data to be validated before saving, so that I don't accidentally store invalid information (e.g., negative weight).

---

# Acceptance Criteria

**Authentication**
- Given a valid email and password (≥6 characters), when the user submits the registration form, then a new account is created and the user is navigated to Home.
- Given an already-registered email, when the user attempts to register again with it, then the system shows a friendly error message and does not create a duplicate account.
- Given valid credentials, when the user submits the login form, then the user is authenticated and navigated to Home.
- Given invalid credentials, when the user submits the login form, then the system shows an error message without exposing raw technical details.
- Given an empty required field, when the user attempts to submit any auth form, then the form is blocked with a validation message and no request is sent.
- Given a user has an active Firebase session, when they reopen the app, then they are navigated directly to Home without re-entering credentials.

**Home / Search / Filter**
- Given the app has network access, when the user opens Home, then a default list of meals is fetched and displayed within a reasonable time with a loading indicator shown during the fetch.
- Given no network access, when the user opens Home, then a friendly error state is shown instead of a blank screen or crash.
- Given a search keyword that matches meals, when the user submits a search, then matching meals are displayed.
- Given a search keyword that matches no meals, when the user submits a search, then an empty-state message is shown (not an error).
- Given a category filter is selected, when the filter is applied, then only meals belonging to that category are displayed.

**Meal Detail / Favorite**
- Given a meal is selected from any list, when the user taps it, then the detail screen shows its image, ingredients, steps, and estimated calories.
- Given a meal is not yet favorited, when the user taps the heart icon, then the meal is saved to Firestore under the current user and the icon updates to the "favorited" state.
- Given a meal is already favorited, when the user taps the heart icon again, then the meal is removed from Firestore and the icon updates to the "not favorited" state.
- Given the user is on the Favorite tab, when favorites exist, then all saved meals are listed; when none exist, an empty-state message is shown.
- Given a favorite meal, when the user swipes it, then a delete action is triggered and the meal is removed from the list and Firestore.
- Given a favorite meal, when the user adds/edits a note and saves, then the note is persisted in Firestore and reflected immediately in the UI.

**Profile**
- Given valid values for name, height, and target weight, when the user saves the profile form, then the data is updated in Firestore and reflected in the UI.
- Given an invalid value (e.g., negative height/weight, empty required field), when the user attempts to save, then the form is blocked with a validation message.
- Given the user taps Log out, when confirmed, then the Firebase session ends and the user is navigated to the Login screen.

---

# Business Rules

- BR-01: Mỗi món ăn yêu thích thuộc về đúng một tài khoản người dùng; không có khái niệm chia sẻ/dùng chung danh sách yêu thích giữa các user trong MVP.
- BR-02: Một món ăn (xác định bằng `idMeal` từ TheMealDB) chỉ có thể xuất hiện tối đa một lần trong danh sách yêu thích của một người dùng — nhấn "Yêu thích" lần nữa sẽ bỏ lưu, không tạo bản ghi trùng.
- BR-03: Ghi chú cá nhân là dữ liệu riêng tư gắn với cặp (user, món ăn); không hiển thị cho người dùng khác.
- BR-04: Chiều cao và cân nặng mục tiêu trong Profile phải là số dương; hệ thống không chấp nhận giá trị 0 hoặc âm.
- BR-05: Email phải theo đúng định dạng chuẩn (regex email hợp lệ); mật khẩu tối thiểu 6 ký tự theo yêu cầu Firebase Auth.
- BR-06: Người dùng chưa đăng nhập (Guest) không được phép truy cập Home, Meal Detail, Favorite, hoặc Profile — mọi điều hướng vào các màn hình này phải đi qua kiểm tra Auth State trước.
- BR-07: Dữ liệu món ăn (tên, hình ảnh, nguyên liệu, hướng dẫn, calo) luôn lấy trực tiếp từ TheMealDB tại thời điểm truy vấn — ứng dụng không tự lưu trữ/cache lâu dài nội dung công thức gốc, chỉ lưu tham chiếu (`idMeal`) và dữ liệu cá nhân hóa (ghi chú) trong Firestore.

---

# Constraints

- **Nền tảng:** Chỉ phát triển cho Mobile (Flutter/Dart). Do máy phát triển hiện tại là **MacBook** (không có sẵn thiết bị/môi trường Android), toàn bộ giai đoạn build/test MVP (Phase 1–15 theo `DEVELOPMENT_ROADMAP.md`) thực hiện trên **iOS Simulator**. Đây là **ràng buộc tạm thời của môi trường phát triển, không phải thay đổi phạm vi nền tảng của sản phẩm** — đề bài gốc PRM393 (Giai đoạn 5) vẫn yêu cầu build APK và test trên thiết bị Android thật, và yêu cầu này **sẽ được đáp ứng ở bước bàn giao** (handoff): sau khi MVP hoàn thành trên iOS Simulator, codebase sẽ được gửi cho một thành viên khác (có máy Windows/Linux hoặc thiết bị Android) để build APK và kiểm thử trên thiết bị thật. Vì vậy, codebase phải giữ **thuần Flutter/Material, không dùng API hoặc package chỉ chạy được trên iOS** (xem `PROJECT_GUIDELINES.md` mục Architecture Rules) để việc bàn giao không phát sinh viết lại. Xem thêm mục "Nếu phát hiện requirement còn thiếu" (điểm 9) để biết chi tiết kế hoạch bàn giao và rủi ro liên quan.
- **Nguồn dữ liệu công thức:** Phụ thuộc hoàn toàn vào TheMealDB — một dịch vụ miễn phí, dùng API key public (`1`), không có SLA đảm bảo uptime hay giới hạn rate limit rõ ràng từ nhà cung cấp. Ứng dụng phải chấp nhận rủi ro API bên thứ ba có thể chậm/lỗi/ngừng hoạt động ngoài tầm kiểm soát của dự án.
- **Backend:** Không tự xây dựng backend riêng — toàn bộ phần lưu trữ dữ liệu người dùng dựa vào Firebase (Authentication + Cloud Firestore) trong gói miễn phí (Spark plan), cần lưu ý giới hạn quota miễn phí của Firebase khi test nhiều lần.
- **Thời gian:** Dự án thực hiện trong khuôn khổ một học phần (PRM393), chia thành 5 giai đoạn (sprint) — mọi requirement phải khả thi để hoàn thành trong lộ trình đó.
- **Nhân sự:** Dự án được liệt kê với một sinh viên thực hiện (Trung Nhân) dưới tên nhóm "Team Wizards" — cần làm rõ liệu đây là dự án cá nhân hay có thêm thành viên khác chưa được liệt kê, vì điều này ảnh hưởng đến việc phân chia công việc và chiến lược Git branching.
- **Môi trường phát triển:** VS Code + Git/GitHub, theo đúng công cụ nêu trong đề bài Giai đoạn 1.

---

# Future Enhancements

- Đăng nhập qua Google/Facebook (Social Login) để giảm ma sát khi đăng ký.
- Chức năng "Quên mật khẩu" hoàn chỉnh (gửi email khôi phục qua Firebase Auth) — hiện đề bài chỉ nhắc thiết kế UI, nên làm rõ có triển khai logic thật hay không (xem đề xuất bên dưới).
- Lập kế hoạch thực đơn theo tuần (Meal Planner) dựa trên danh sách yêu thích.
- Tự động gộp nguyên liệu từ nhiều món đã chọn thành một danh sách đi chợ (Shopping List).
- Tính toán calo/dinh dưỡng cá nhân hóa theo khẩu phần ăn và mục tiêu cân nặng của từng người dùng (hiện tại chỉ dùng số liệu ước tính chung).
- Chia sẻ công thức hoặc ghi chú cá nhân với bạn bè/mạng xã hội.
- Chế độ offline (cache công thức đã xem để dùng khi mất mạng).
- Đa ngôn ngữ (Việt/Anh).
- Push Notification nhắc nhở nấu ăn hoặc gợi ý món mới.
- Trang quản trị (Admin) nếu dự án mở rộng thành sản phẩm nhiều người dùng thật, cần kiểm duyệt nội dung do người dùng tự thêm (nếu sau này cho phép user tạo công thức riêng).

---

# Nếu phát hiện requirement còn thiếu hoặc chưa hợp lý — Đề xuất bổ sung/làm rõ

Trong quá trình phân tích, phát hiện một số điểm đề bài gốc chưa mô tả rõ hoặc còn thiếu, cần xác nhận trước khi triển khai:

1. **"Quên mật khẩu" (Forgot Password):** Đề bài Giai đoạn 2 chỉ nói "Thiết kế UI màn hình... Quên mật khẩu" nhưng không đề cập logic xử lý cụ thể, và mục 3 (barem điểm) không liệt kê đây là tiêu chí bắt buộc. Đề xuất: xác nhận có triển khai logic gửi email khôi phục qua Firebase Auth (`sendPasswordResetEmail`) hay chỉ dừng ở UI tĩnh cho MVP.

2. **Định nghĩa "món ăn nổi bật hoặc ngẫu nhiên" ở Home:** Đề bài mô tả 2 khả năng khác nhau ở mục 2.2 ("nổi bật hoặc ngẫu nhiên") nhưng ở mục 4 (endpoint cụ thể) chỉ định nghĩa endpoint `search.php?f=b` (liệt kê theo chữ cái, không phải random). TheMealDB có endpoint riêng cho random (`random.php`). Đề xuất: xác nhận Home dùng danh sách cố định theo chữ cái 'b' (đúng như endpoint đã liệt kê) để tránh nhầm lẫn khi triển khai.

3. **Vai trò Admin:** Không có mô tả nghiệp vụ nào cho Admin trong tài liệu gốc. Đề xuất: loại bỏ hoàn toàn khỏi phạm vi MVP (đã đưa vào Out of Scope) trừ khi được xác nhận cần thiết.

4. **Xử lý trùng lặp món yêu thích:** Đề bài không mô tả rõ hành vi khi người dùng nhấn nút "Yêu thích" một món đã có trong danh sách. Đã bổ sung làm Business Rule (BR-02): coi là hành động "toggle" (bỏ lưu nếu đã lưu).

5. **Định danh bản ghi Favorite:** Đề bài chưa xác định rõ khóa định danh dùng để lưu món yêu thích trên Firestore. Đề xuất: dùng `idMeal` (ID gốc từ TheMealDB) làm document ID trong sub-collection `favorites`, tránh trùng lặp và đơn giản hóa truy vấn.

6. **Giới hạn giá trị hồ sơ sức khỏe (Profile):** Đề bài chỉ nói "cập nhật tên, chiều cao, cân nặng mục tiêu" nhưng không nêu range hợp lệ. Đã bổ sung Business Rule cơ bản (BR-04: phải là số dương). Đề xuất: nếu cần chặt chẽ hơn, xác định thêm khoảng giá trị hợp lý (ví dụ chiều cao 50–250cm, cân nặng 20–300kg) để validation chính xác hơn.

7. **Xử lý khi TheMealDB không khả dụng:** Đề bài yêu cầu "xử lý lỗi API" nhưng chưa mô tả hành vi cụ thể (retry? cache tạm thời? chỉ hiển thị lỗi?). Đề xuất cho MVP: chỉ hiển thị trạng thái lỗi kèm nút "Thử lại" (Retry), không cần cache/offline phức tạp — giữ đúng tinh thần KISS trong `PROJECT_GUIDELINES.md`.

8. **Số lượng thành viên nhóm:** Tài liệu ghi "Đội ngũ phát triển: Team Wizards" nhưng "Sinh viên thực hiện" chỉ liệt kê một người. Nếu có nhiều thành viên, cần bổ sung actor "Team Member" và phân công module rõ ràng trong Git branching strategy (đã nêu ở Giai đoạn 1 của đề bài) để tránh xung đột khi phát triển song song.

9. **Đã xác nhận: môi trường build/test MVP là iOS Simulator (do máy phát triển là MacBook), có kế hoạch bàn giao sang Android sau khi hoàn thành MVP.** Đề bài gốc PRM393 (mục 3 — barem điểm, và Giai đoạn 5) yêu cầu rõ **build APK và kiểm thử trên thiết bị Android thật**. Vì máy phát triển hiện tại không có sẵn môi trường Android, toàn bộ Phase 1–15 trong `DEVELOPMENT_ROADMAP.md` build/test trên **iOS Simulator**. Sau khi MVP hoàn thành (kết thúc Phase 15), codebase sẽ được **gửi cho một thành viên khác** để họ build APK và kiểm thử trên thiết bị Android thật, đáp ứng đúng yêu cầu gốc của đề bài. Đây là kế hoạch **bàn giao (handoff)**, không phải bỏ yêu cầu Android.
   - **Hệ quả cho cách viết code:** để việc bàn giao không phát sinh viết lại, codebase phải giữ thuần Flutter/Material — không dùng widget/API/package chỉ tương thích iOS (ví dụ tránh phụ thuộc cứng vào Cupertino-only widget nếu không cần thiết, tránh code giả định hành vi riêng của iOS như safe area/gesture). Đã bổ sung nguyên tắc này vào `PROJECT_GUIDELINES.md`.
   - **Checklist cấu hình native cần làm lại trên Android (không tự động chuyển từ iOS):**
     - `google-services.json` (tương đương `GoogleService-Info.plist`) — thêm app Android vào cùng Firebase project qua Console hoặc chạy lại `flutterfire configure`.
     - Quyền Camera trong `android/app/src/main/AndroidManifest.xml` (`<uses-permission android:name="android.permission.CAMERA" />`) — tương đương `NSCameraUsageDescription` bên iOS, phục vụ tính năng chụp ảnh đại diện.
     - Quyền đọc thư viện ảnh: không cần khai báo thủ công nếu target Android 13+ (dùng Photo Picker hệ thống qua `image_picker`); cần `READ_MEDIA_IMAGES`/`READ_EXTERNAL_STORAGE` nếu hỗ trợ Android cũ hơn.
     - Không cần sửa code Dart/Flutter — toàn bộ Provider/Service/Widget đã viết thuần cross-platform, chạy nguyên vẹn trên Android.
   - **Rủi ro cần lưu ý:** người bàn giao (bạn của người thực hiện) cần có đủ thời gian và môi trường Android (máy Windows/Linux hoặc Android Studio + thiết bị/emulator Android) để hoàn tất bước build APK + test thiết bị thật **trước** buổi báo cáo/nộp bài — nên lên lịch bàn giao sớm, không để sát deadline. Ngoài ra, một số hành vi chỉ có thể quan sát trên thiết bị Android thật (ví dụ khác biệt về Back gesture, notification, quyền truy cập hệ thống) sẽ không được kiểm thử trong giai đoạn MVP trên iOS Simulator, và cần người bàn giao kiểm tra bổ sung.

# Blueprint: Ứng dụng học viết chữ Hán

## Tổng quan

Xây dựng một ứng dụng Flutter đa nền tảng (Android, iOS, Web) để học viết chữ Hán, với giao diện và luồng học tập lấy cảm hứng từ Duolingo. Ứng dụng sẽ sử dụng Firebase để xác thực người dùng (Google, Anonymous) và lưu trữ tiến trình học tập trên Firestore.

## Các tính năng chính

- **Giao diện hiện đại:** Dark mode, animation và thiết kế bo tròn, thân thiện.
- **Luồng học tập đầy đủ:** Từ giới thiệu chữ, nghe-chọn nghĩa, đến luyện viết và kiểm tra nét.
- **Luyện viết tương tác:** Sử dụng canvas để người dùng tập viết và so khớp với dữ liệu stroke.
- **Lưu trữ tiến trình:** Mọi tiến độ học, điểm XP, và streak đều được đồng bộ lên Firebase.
- **Xác thực người dùng:** Đăng nhập bằng Google hoặc học thử với tài khoản khách.
- **Dữ liệu linh hoạt:** Dữ liệu chữ Hán được nạp từ file JSON.

## Cấu trúc dự án và công nghệ

- **Ngôn ngữ:** Dart
- **Framework:** Flutter
- **Backend:** Firebase (Authentication, Firestore)
- **Quản lý state:** GetX
- **Gói & thư viện:**
  - `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`
  - `hanzi_writer` (cho việc luyện viết)
  - `get` (quản lý state và navigation)
  - `shared_preferences` (lưu trữ cục bộ)
  - `lottie` (animations)
  - `flutter_svg` (để hiển thị SVG)
  - `audioplayers` (để phát âm thanh)

## Kế hoạch thực thi

### Giai đoạn 1: Cài đặt và cấu hình

1.  **Tạo Blueprint:** Ghi lại kế hoạch và các yêu cầu (Đã hoàn thành).
2.  **Cấu hình Firebase:**
    - Thêm config MCP cho Firebase.
    - Thêm các dependency cần thiết vào `pubspec.yaml`.
    - Khởi tạo Firebase trong `main.dart`.
3.  **Thiết kế Theme:**
    - Tạo file theme với màu sắc và font chữ đã định.
    - Áp dụng theme cho toàn bộ ứng dụng.

### Giai đoạn 2: Xây dựng các màn hình (UI)

1.  **Cấu trúc thư mục:** Sắp xếp code theo feature (ví dụ: `screens`, `controllers`, `models`, `services`).
2.  **Màn hình Đăng nhập:** Tạo UI cho việc đăng nhập với Google và chế độ khách.
3.  **Màn hình HomePage:** Xây dựng giao diện dashboard với các tab, section và unit.
4.  **Màn hình ProfilePage:** Thiết kế trang hồ sơ người dùng.
5.  **Các màn hình học tập:**
    - `LessonIntroPage`
    - `ListenChoicePage`
    - `MeaningChoicePage`
    - `WritingCanvasPage`
    - `ResultPage`

### Giai đoạn 3: Tích hợp Logic và Firebase

1.  **Models:** Tạo các lớp Dart `UserModel`, `CharacterModel`, `UnitModel`.
2.  **Firebase Service:** Viết các hàm để tương tác với Firestore (đọc/ghi dữ liệu).
3.  **Authentication Service:** Xử lý logic đăng nhập, đăng xuất, và quản lý session.
4.  **GetX Controllers:** Tạo controller cho từng màn hình để quản lý state và business logic.
5.  **Tích hợp `hanzi_writer`:** Cấu hình canvas luyện viết và logic kiểm tra stroke.
6.  **Nạp dữ liệu:** Viết hàm để đọc dữ liệu từ file JSON trong assets và hiển thị ra UI.

### Giai đoạn 4: Hoàn thiện và kiểm thử

1.  **Animation:** Thêm các hiệu ứng Lottie.
2.  **Âm thanh:** Tích hợp chức năng phát âm cho chữ Hán.
3.  **Responsive:** Đảm bảo UI hoạt động tốt trên cả mobile và web.
4.  **Kiểm tra lỗi:** Rà soát và sửa các lỗi phát sinh trong quá trình phát triển.
5.  **Build và Deploy:** Hướng dẫn cách build ứng dụng cho các nền tảng.

## Khắc phục sự cố

*   **Vấn đề:** Sau khi đổi tên dự án từ `hanzi_writer_app` thành `myapp`, nhiều tệp vẫn còn sử dụng đường dẫn nhập cũ, gây ra lỗi build.
*   **Giải pháp:**
    *   Đã cập nhật `pubspec.yaml` để phản ánh tên gói mới.
    *   Đã sửa các đường dẫn nhập không chính xác trong các tệp sau:
        *   `lib/app/routes/app_pages.dart`
        *   `lib/app/modules/auth/auth_binding.dart`
        *   `lib/app/modules/auth/auth_screen.dart`
        *   `lib/app/modules/home/home_binding.dart`
        *   `lib/app/modules/home/home_screen.dart`
        *   `lib/app/modules/splash/splash_binding.dart`
        *   `lib/app/modules/splash/splash_screen.dart`
        *   `lib/app/modules/auth/auth_controller.dart`
        *   `lib/app/modules/splash/splash_controller.dart`

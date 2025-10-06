# Phân tích log cảnh báo / lỗi Android

Đoạn log dưới đây xuất hiện khi chạy ứng dụng trên thiết bị Android:

```
W/System  ( 9325): Ignoring header X-Firebase-Locale because its value was null.
W/LocalRequestInterceptor( 9325): Error getting App Check token; using placeholder token instead. Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.
I/ScionFrontendAp( 9325): type=1400 audit(0.0:1880): avc: denied { open } for path="/data/local/cfg-nnayn/android7" dev="sdb2" ino=262273 scontext=u:r:untrusted_app:s0:c62,c256,c512,c768 tcontext=u:object_r:system_data_file:s0 tclass=file permissive=1
W/ActivityThread( 9325): handleWindowVisibility: no activity for token android.os.BinderProxy@1718394
E/EGL_emulation( 9325): tid 9432: eglSurfaceAttrib(1493): error 0x3009 (EGL_BAD_MATCH)
W/OpenGLRenderer( 9325): Failed to set EGL_SWAP_BEHAVIOR on surface 0x7638746d2300, error=EGL_BAD_MATCH
...
```

Dưới đây là ý nghĩa của từng nhóm cảnh báo/lỗi và cách xử lý.

## 1. `Ignoring header X-Firebase-Locale because its value was null`
* **Nguyên nhân**: Firebase Auth cho phép gửi header `X-Firebase-Locale` để hiển thị email/OTP theo ngôn ngữ cụ thể. Khi chưa gọi `FirebaseAuth.instance.setLanguageCode(...)`, header bị gửi với giá trị `null` nên Firebase bỏ qua.
* **Tác động**: Chỉ là cảnh báo, không làm ứng dụng crash.
* **Cách khắc phục (tùy chọn)**: Gọi `FirebaseAuth.instance.setLanguageCode('vi');` sau khi khởi tạo Firebase hoặc bỏ qua nếu không cần localization.

## 2. `Error getting App Check token; using placeholder token instead`
* **Nguyên nhân**: Đã bật Firebase App Check trong code nhưng chưa đăng ký provider hợp lệ (Debug/Play Integrity/SafetyNet). SDK phải fallback dùng placeholder token.
* **Tác động**: Nếu App Check bắt buộc trong Firebase console, các request có thể bị từ chối. Nếu ở chế độ debug và App Check chưa enforced, request vẫn chạy.
* **Cách khắc phục**:
  - Đảm bảo đã thêm dependency `firebase_app_check` và gọi `FirebaseAppCheck.instance.activate(...)`.
  - Cấu hình provider phù hợp (ví dụ Debug provider trong `main.dart` cho quá trình phát triển, Play Integrity/SafetyNet cho build phát hành).
  - Hoặc tạm thời vô hiệu hoá App Check trên dự án Firebase nếu chưa cần.

## 3. `avc: denied { open } ...` (SELinux audit)
* **Nguyên nhân**: Thiết bị/emulator sử dụng SELinux ở chế độ `permissive`. Khi ứng dụng (với nhãn bảo mật `untrusted_app`) truy cập file hệ thống, SELinux ghi nhận và log lại.
* **Tác động**: Vì trạng thái là `permissive=1`, hành động vẫn được phép, chỉ là thông báo để debugging. Không gây crash.
* **Cách khắc phục**: Không cần xử lý trong app. Đây là log của hệ thống/emulator.

## 4. `EGL_BAD_MATCH` / `Failed to set EGL_SWAP_BEHAVIOR`
* **Nguyên nhân**: Bộ giả lập hoặc thiết bị có driver đồ hoạ không hỗ trợ thuộc tính swap behavior được Flutter yêu cầu khi kết xuất UI.
* **Tác động**: Log cảnh báo nhưng Flutter vẫn fallback. Không ảnh hưởng tới logic ứng dụng.
* **Cách khắc phục**: Có thể thử:
  - Cập nhật emulator image hoặc GPU driver.
  - Bật `--enable-impeller` trên Flutter ≥3.10 để dùng renderer mới.
  - Trên thiết bị thật thường không xuất hiện.

## 5. `handleWindowVisibility: no activity for token ...`
* **Nguyên nhân**: Android logcat ghi nhận activity đã bị destroy/detach trước khi hiển thị. Thường xuất hiện khi hot reload/hot restart hoặc chuyển activity nhanh.
* **Tác động**: Không gây lỗi, chỉ là cảnh báo của framework.

---
### Kết luận
Các log trên chủ yếu là cảnh báo từ Firebase khi thiếu cấu hình App Check và thông báo của hệ thống/emulator. Chúng không gây crash ngay lập tức, nhưng để loại bỏ cảnh báo App Check cần cấu hình provider hợp lệ hoặc tắt App Check khi phát triển.

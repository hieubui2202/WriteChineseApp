# Hướng dẫn chi tiết ứng dụng Hanzi Writing Trainer (A-Z)

Tài liệu này mô tả toàn bộ kiến trúc, dòng sự kiện và cách quản lý dữ liệu của ứng dụng Hanzi Writing Trainer dựa trên Flutter + Firebase. Nội dung được viết tiếng Việt để đội ngũ phát triển, nội dung và vận hành có thể nắm bắt quy trình triển khai từ đầu tới cuối.

## 1. Mục tiêu và phạm vi

- Ứng dụng học viết chữ Hán kiểu Duolingo: giao diện tối, nút neon, hiệu ứng mượt.
- Hỗ trợ Android, iOS, Web; chạy được offline có đồng bộ khi lên mạng.
- Đăng nhập Firebase Auth (Google & Anonymous), lưu tiến trình trên Firestore, tài nguyên âm thanh/stroke trên Firebase Storage.
- Kịch bản học 5 bước: giới thiệu, nghe, nghĩa, viết, hoàn thiện nét thiếu, kết quả.
- Có trang Dashboard, Review, Profile.
- Cung cấp bộ công cụ import dữ liệu từ Excel lên Firebase.

## 2. Kiến trúc tổng quan (Clean + GetX)

Ứng dụng được tổ chức theo Clean Architecture với ba tầng chính:

1. **domain/**: Khai báo entity, repository interface, use case (business logic thuần).
2. **data/**: DataSource (Firebase, local cache), model để chuyển đổi giữa JSON ↔ entity, repository implementation.
3. **presentation/**: UI Flutter, controller GetX, binding, widget.

Các thư mục hỗ trợ:

- **core/**: dịch vụ chung (AudioService, network, config).
- **assets/**: dữ liệu tĩnh (JSON demo, Lottie, font...).
- **tools/firebase/**: script import dữ liệu (Python).
- **docs/**: tài liệu hướng dẫn (bao gồm file này).

### 2.1 luồng khởi động

1. `main.dart` gọi `WidgetsFlutterBinding.ensureInitialized()`, khởi tạo Firebase và SharedPreferences.
2. Thực hiện App Check (nếu khả dụng), thiết lập ngôn ngữ mặc định cho Firebase Auth.
3. Gọi `runApp()` với `GetMaterialApp`, áp dụng `AppBinding` để inject controller (AuthController, ProgressController...).
4. SplashPage quan sát trạng thái đăng nhập (qua use case `WatchAuthState`).
5. Nếu đã đăng nhập → bootstrap tiến trình (`BootstrapProgress`). Nếu chưa → hiển thị màn hình đăng nhập hoặc cho phép học thử (Anonymous).

### 2.2 Dòng điều hướng (AppRoutes)

- `/splash` → `/auth` hoặc `/home` tùy trạng thái đăng nhập.
- `/home` có nút truy cập Practice (flow 5 bước), Review, Profile.
- Practice flow điều hướng tuần tự qua các trang `LessonIntroPage` → `ListenChoicePage` → `MeaningChoicePage` → `WritingCanvasPage` → `MissingStrokePage` → `ResultPage`.
- Sau Result có thể chọn “Next Word” hoặc quay lại Home.

## 3. Dòng sự kiện tính năng

### 3.1 Đăng nhập

1. Người dùng chọn Google hoặc “Học thử”.
2. Controller gọi use case tương ứng (`SignInWithGoogle`, `SignInAnonymously`).
3. Thành công → cập nhật `AuthController.currentUser`, trigger `ProgressController.bootstrap()` để tải tiến trình từ Firestore.
4. Nếu thất bại → hiển thị snackbar lỗi, giữ nguyên màn hình.

### 3.2 Dashboard (HomePage)

- Lấy danh sách Unit từ `ProgressController.units` (đã được hydrate từ Firestore hoặc sample offline).
- Mỗi ô Unit hiển thị trạng thái: Completed / In-progress / Locked dựa trên dữ liệu `UserProgress`.
- Nhấn “Practice” → `PracticeController.startLesson(unitId)` và điều hướng sang bài học.

### 3.3 Practice Flow 5 bước

1. **LessonIntroPage**
   - Hiển thị chữ Hán, pinyin, nghĩa, nút audio.
   - Sự kiện: `onPlayAudio` → gọi `AudioService.playUrl(ttsUrl)`.
   - Nút “Bắt đầu” → chuyển sang ListenChoice.

2. **ListenChoicePage**
   - Phát audio tự động (nếu `autoPlay=true`).
   - Hiển thị 3 lựa chọn pinyin, người dùng chọn đáp án.
   - Controller chấm điểm, cập nhật `currentResult.listenCorrect`.
   - Nhấn “Tiếp tục” → sang MeaningChoice.

3. **MeaningChoicePage**
   - Tương tự Listen nhưng là nghĩa tiếng Việt.
   - Lưu kết quả vào `currentResult.meaningCorrect`.

4. **WritingCanvasPage**
   - Sử dụng `HanziStrokeCanvas` hiển thị grid, stroke animation.
   - Sự kiện: bắt đầu vẽ, kết thúc vẽ → validate với path chuẩn.
   - Khi đạt ngưỡng chính xác → đánh dấu `writingCorrect=true`.

5. **MissingStrokePage**
   - Hiển thị chữ thiếu nét, yêu cầu vẽ phần còn thiếu.
   - Hệ thống so sánh vector stroke với dữ liệu chuẩn.

6. **ResultPage**
   - Tổng hợp kết quả, hiển thị XP, streak.
   - Gọi use case `RecordLessonResult` → lưu tiến trình (Firestore + cache).
   - Cho phép phát lại audio, xem lộ trình tiếp theo.

### 3.4 Review (Flashcards)

- ReviewController tải danh sách chữ đã học.
- Mỗi thẻ hiển thị chữ/pinyin/nghĩa/nút audio, nút “Replay stroke” dùng `HanziStrokeCanvas` ở chế độ auto-play.
- Có thể đánh dấu “Cần ôn lại” → cập nhật cờ trong Firestore (dùng `ProgressRepository`).

### 3.5 Profile

- Hiển thị avatar, email, streak, tổng XP, số chữ đã học (dựa vào `UserProgress`).
- Nút “Đăng xuất” → `SignOut` use case, dọn cache (`ClearProgressCache`).

## 4. Thiết kế dữ liệu Firebase

### 4.1 Firestore

```
/users/{uid}
  displayName: string
  email: string
  avatarUrl: string
  xp: number
  streakDays: number
  lastActive: Timestamp
  progress: map
    {unitId}:
      {character}:
        completed: bool
        score: number (0-100)
        mistakes: number
        lastReview: Timestamp
/characters/{characterId}
  hanzi: string ("茶")
  pinyin: string
  meaning: string
  unitId: string
  ttsUrl: string
  strokeData:
    width: int
    height: int
    paths: array<string> (SVG path)
/units/{unitId}
  title: string
  description: string
  order: int
  characters: array<string>
  xpReward: int
/settings/{locale}
  audioCdn: string (tùy chọn)
```

### 4.2 Firebase Storage

```
/audio/{characterId}.mp3
/lottie/{name}.json (tùy chọn, có thể build cùng app)
/stroke/{characterId}.json (nếu muốn lưu ngoài Firestore)
```

### 4.3 Đồng bộ offline

- Firestore bật persistence: dữ liệu người dùng được cache.
- ProgressLocalDataSource lưu bản sao tiến trình ở SharedPreferences (`user_progress_cache.json`).
- Khi online lại, `SyncProgress` so sánh `updatedAt` để gửi delta lên Firestore.

## 5. Bộ importer Excel → Firebase

### 5.1 Chuẩn bị

- Tạo file Excel với cột: `character`, `pinyin`, `meaning`, `audioFileName`, `unit`, `strokeData.paths` (dùng ký tự `|` phân tách), `strokeData.width`, `strokeData.height`.
- Upload file âm thanh lên Storage (hoặc chỉ định URL CDN sẵn).
- Cài môi trường Python:
  ```bash
  cd tools/firebase
  python -m venv .venv
  source .venv/bin/activate  # Windows: .venv\Scripts\activate
  pip install -r requirements.txt
  ```

### 5.2 Chạy script

```bash
python import_characters.py \
  --excel datasets/section1.xlsx \
  --firebase-credentials serviceAccount.json \
  --storage-bucket hanziapp.appspot.com \
  --audio-prefix gs://hanziapp.appspot.com/audio/
```

Tác vụ chính của script:

1. Đọc Excel bằng `pandas` → danh sách hàng.
2. Với mỗi hàng:
   - Nếu `audioFileName` là URL tuyệt đối → dùng trực tiếp.
   - Nếu chỉ là tên file → ghép với `audio-prefix`.
   - Parse `strokeData.paths` tách bằng `|`, loại bỏ khoảng trắng.
3. Ghi dữ liệu vào Firestore (`characters/{characterId}`) và cập nhật `units/{unitId}.characters`.
4. Tùy chọn: cập nhật `assets/data/sample_characters.json` nếu dùng offline demo.

### 5.3 Xử lý lỗi phổ biến

- Sai định dạng stroke path → script báo hàng lỗi và bỏ qua.
- Audio chưa upload → URL trả về 404 khi chạy app, cần kiểm tra Storage.
- Trùng characterId → script cập nhật document hiện tại, log cảnh báo.

## 6. Quản lý XP, streak, thành tích

- `RecordLessonResult` nhận điểm từng bước, tính XP theo quy tắc:
  - Đúng toàn bộ: +10 XP.
  - Sai một bước: +5 XP.
  - Sai nhiều: +2 XP (khuyến khích học lại).
- Streak tăng nếu người dùng hoàn thành ít nhất 1 bài trong ngày (dựa `lastActive`).
- Khi đạt chuỗi 5 bài đúng liên tiếp → gắn cờ `hotStreak=true`, hiển thị animation Lottie.

## 7. Audio & Hanzi Canvas

- `AudioService` wrap `just_audio` để phát URL, hỗ trợ preload offline.
- `HanziStrokeCanvas`:
  - Nhận `strokeData` (width/height/paths).
  - Vẽ grid 3x3 + outline.
  - Playback mode: animate theo thời gian.
  - Practice mode: so sánh path người dùng với path chuẩn (sử dụng approx polyline & tolerance).

## 8. Web preview

- `web/preview.html` dựng layout tĩnh mô phỏng Home, Practice.
- Dùng CSS/JS nhẹ mô phỏng progress bar, animation.
- Có thể host trên Firebase Hosting để giới thiệu UX nhanh.

## 9. Quy trình phát hành

1. Cấu hình Firebase project, tải `google-services.json`, `GoogleService-Info.plist`, bật Web app.
2. `flutterfire configure` để đồng bộ config.
3. Thiết lập App Check (SafetyNet/Play Integrity, DeviceCheck) theo môi trường.
4. `flutter build apk/ipa/web` tùy nền tảng.
5. Kiểm thử QA: đảm bảo đăng nhập, practice, review, profile hoạt động.

## 10. Phụ lục: mapping sự kiện

| Sự kiện | Controller | Use case / Service | Ghi chú |
|--------|------------|--------------------|---------|
| App mở | `SplashController` | `WatchAuthState`, `BootstrapProgress` | Quyết định điều hướng |
| Đăng nhập Google | `AuthController` | `SignInWithGoogle` | Lưu thông tin user |
| Đăng nhập ẩn danh | `AuthController` | `SignInAnonymously` | Không lưu email |
| Bắt đầu bài học | `PracticeController` | `BootstrapProgress` (đã có), chọn chữ tiếp theo | |
| Hoàn thành bước nghe | `PracticeController` | Nội bộ | Lưu kết quả tạm |
| Hoàn thành bước viết | `PracticeController` | `HanziStrokeCanvas` + scoring | |
| Lưu kết quả bài học | `PracticeController` | `RecordLessonResult`, `ProgressRepository` | Cập nhật Firestore + cache |
| Đồng bộ thủ công | `ProfileController` | `SyncProgress` | Xử lý offline |
| Đăng xuất | `ProfileController` | `SignOut`, `ClearProgressCache` | Gỡ dữ liệu local |

---

Tài liệu này cùng các hướng dẫn khác nằm trong thư mục `docs/vi`. Hãy cập nhật khi luồng nghiệp vụ hoặc cấu trúc dữ liệu thay đổi để đảm bảo đội ngũ luôn có nguồn tham chiếu mới nhất.

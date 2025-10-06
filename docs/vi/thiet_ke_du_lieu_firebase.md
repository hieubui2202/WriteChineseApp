# Thiết kế dữ liệu cho Hanzi Writing Trainer

Tài liệu này giải thích bằng tiếng Việt cách tổ chức dữ liệu khi đưa từ Excel (hoặc CSV/JSON) lên Firebase cho ứng dụng học viết chữ Hán. Bạn có thể dùng nó làm "bản thiết kế" trước khi nhập dữ liệu bằng script `tools/firebase/import_characters.py`.

## 1. Kiến trúc tổng thể

Hệ thống sử dụng ba dịch vụ Firebase chính:

1. **Authentication**: lưu thông tin đăng nhập (Google hoặc Anonymous).
2. **Cloud Firestore**: lưu tiến trình học và metadata của từng chữ Hán.
3. **Firebase Storage**: lưu file âm thanh/TTS và các tài nguyên nặng (ví dụ Lottie, SVG nếu cần).

Sơ đồ quan hệ cơ bản:

```
users/{uid}
  ├── name, email, avatarUrl
  ├── streakDays, xp
  └── progress
       └── {unitId}
            └── {character}
                 ├── completed: bool
                 └── score: number

characters/{character}
  ├── pinyin
  ├── meaning
  ├── ttsUrl
  ├── strokeData
  │     ├── width
  │     ├── height
  │     └── paths[]
  └── unit

units/{unitId}
  ├── title
  ├── description
  └── characters[]
```

## 2. Thiết kế bảng Excel

Bảng Excel sẽ đóng vai trò nguồn dữ liệu để import vào Firestore. Mỗi dòng tương ứng với một chữ Hán.

| Cột                 | Ý nghĩa                                                                 | Ví dụ                                    |
|---------------------|-------------------------------------------------------------------------|------------------------------------------|
| `character`         | Chữ Hán                                                                 | `咖`                                     |
| `pinyin`            | Phiên âm có dấu                                                         | `kāfēi`                                  |
| `meaning`           | Nghĩa tiếng Việt hoặc tiếng Anh hiển thị trong app                     | `cà phê / coffee`                        |
| `audioFileName`     | (Tuỳ chọn) Tên file âm thanh đặt cạnh file Excel                        | `kafei.mp3`                              |
| `ttsUrl`            | (Tuỳ chọn) Đường dẫn âm thanh đã host sẵn                               | `https://.../kafei.mp3`                  |
| `strokeData.paths`  | Danh sách lệnh path SVG, ngăn cách bằng dấu `|` hoặc JSON array         | `M ...|M ...`                            |
| `strokeData.width`  | Chiều rộng canvas nét vẽ (px)                                           | `109`                                    |
| `strokeData.height` | Chiều cao canvas nét vẽ (px)                                            | `109`                                    |
| `unit`              | ID của unit bài học (ví dụ `section1_unit1`)                            | `section1_unit1`                         |
| `order`             | (Tuỳ chọn) Thứ tự xuất hiện trong unit                                  | `0`, `1`, ...                            |

> ⚠️ Nếu bạn cung cấp cả `audioFileName` và `ttsUrl`, script sẽ ưu tiên `ttsUrl` (vì đã có link sẵn). Khi chỉ có `audioFileName`, script sẽ upload file từ thư mục cùng cấp với Excel lên Firebase Storage và tự tạo URL.

## 3. Ví dụ thực tế với chữ "咖"

Dòng dữ liệu trong Excel có thể ghi như sau:

```
character | order | unit             | meaning | meaningEn | pinyin | ttsUrl                                                              | strokeData.width | strokeData.height | strokeData.paths
咖        | 0     | section1_unit1   | cà phê  | coffee    | kāfēi  | https://d1vq87e9lcf771.cloudfront.net/.../5b8f5fbc21f1180334312b6a | 109              | 109               | M 12.00,38.32 C ...|M 13.35,39.93 C ...|...|M 78.34,80.16 C ...
```

Sau khi chạy importer:

* Firestore sẽ tạo document `characters/咖` với các trường đúng như cột bên trên.
* Collection `units/section1_unit1` sẽ cập nhật danh sách `characters` nếu bạn chạy thêm bước đồng bộ unit.
* Firebase Storage giữ nguyên file audio (nếu upload từ máy).

## 4. Tổ chức thư mục dự án

* **`tools/firebase/datasets/`**: nơi đặt file Excel/CSV và audio trước khi chạy importer.
* **`assets/data/sample_characters.json`**: dữ liệu offline mẫu dùng khi app không truy cập được Firestore. Hãy cập nhật file này sau khi thêm chữ mới để trải nghiệm offline đồng bộ.
* **`tools/firebase/import_characters.py`**: script Python chịu trách nhiệm đọc Excel, upload audio (nếu cần) và ghi dữ liệu vào Firestore/Storage.

## 5. Quy trình nhập dữ liệu (tóm tắt)

1. Chuẩn bị môi trường Python và cài đặt phụ thuộc: `pip install -r tools/firebase/requirements.txt`.
2. Điền dữ liệu theo bảng mẫu ở mục 2.
3. Đặt file Excel và audio vào `tools/firebase/datasets/`.
4. Cập nhật file `.env` hoặc biến môi trường với thông tin service account Firebase (nếu script yêu cầu).
5. Chạy `python tools/firebase/import_characters.py --input tools/firebase/datasets/characters.xlsx`.
6. Kiểm tra Firestore và Storage xem dữ liệu đã xuất hiện đúng chưa.

## 6. Gợi ý mở rộng

* Bạn có thể thêm cột `tags` (ví dụ `["đồ uống", "buổi sáng"]`) để phục vụ tính năng lọc nâng cao trong tương lai.
* Nếu muốn đa ngôn ngữ, cân nhắc tạo các cột `meaning_vi`, `meaning_en`, `meaning_ja` và chỉnh importer ghi vào các trường con trong Firestore.
* Dữ liệu tiến trình (`users/{uid}/progress`) được tạo động trong app, nên không cần import thủ công.

Việc thống nhất cấu trúc dữ liệu ngay từ đầu giúp quá trình phát triển, kiểm thử và mở rộng nội dung diễn ra nhanh chóng và ít lỗi.

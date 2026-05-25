# Money Tracker

Ứng dụng quản lý chi tiêu cá nhân sử dụng Flutter và Firebase.

## Công nghệ sử dụng

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Provider
- fl_chart
- intl

## Chức năng chính

- Splash Screen kiểm tra trạng thái đăng nhập
- Đăng ký và đăng nhập bằng email/password
- Xem thông tin người dùng
- Thêm, sửa, xóa giao dịch thu nhập và chi tiêu
- Lọc giao dịch theo loại và tháng hiện tại
- Thống kê tổng thu, tổng chi, số dư
- Biểu đồ tròn chi tiêu theo danh mục
- Biểu đồ cột chi tiêu 6 tháng gần nhất
- Đặt ngân sách tháng và cảnh báo vượt ngân sách
- Đăng xuất và xóa toàn bộ giao dịch

## Chạy project

```bash
flutter pub get
flutter run
```

## Firebase Android

1. Tạo Firebase project mới.
2. Thêm Android app với package name:

```text
com.example.money_tracker
```

3. Tải file `google-services.json`.
4. Đặt file vào:

```text
android/app/google-services.json
```

5. Bật `Email/Password` trong Firebase Authentication.
6. Tạo Cloud Firestore Database.

Chi tiết hơn xem tại [FIREBASE_SETUP.md](/D:/Myproject/money_tracker/FIREBASE_SETUP.md).

## Tài liệu báo cáo

Xem thêm:

- [FIREBASE_SETUP.md](/D:/Myproject/money_tracker/FIREBASE_SETUP.md)
- [REPORT_GUIDE.md](/D:/Myproject/money_tracker/REPORT_GUIDE.md)

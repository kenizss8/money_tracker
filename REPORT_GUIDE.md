# Report Guide

## Luồng hoạt động ngắn gọn

1. App mở vào Splash Screen để khởi tạo Firebase và kiểm tra trạng thái đăng nhập.
2. Nếu chưa đăng nhập, người dùng đi tới màn hình Login hoặc Register.
3. Sau khi đăng nhập thành công, app vào Main Screen với 4 tab:
   Trang chủ, Giao dịch, Thống kê, Cài đặt.
4. Người dùng có thể thêm, sửa, xóa và lọc giao dịch thu nhập hoặc chi tiêu.
5. Dữ liệu được lưu trên Firebase Authentication và Cloud Firestore theo từng user.
6. App tự tính tổng thu, tổng chi, số dư, thống kê tháng và biểu đồ chi tiêu.
7. Người dùng có thể đặt ngân sách tháng để theo dõi còn trong giới hạn hay đã vượt ngân sách.

## Nên chụp màn hình gì cho báo cáo

1. Splash Screen.
2. Màn hình đăng ký tài khoản.
3. Màn hình đăng nhập.
4. Trang chủ với tổng thu, tổng chi, số dư.
5. Form thêm giao dịch.
6. Danh sách giao dịch có filter.
7. Hộp thoại xác nhận xóa giao dịch.
8. Màn hình thống kê với biểu đồ tròn.
9. Màn hình thống kê với biểu đồ cột.
10. Màn hình đặt ngân sách tháng.
11. Màn hình cài đặt và thông tin người dùng.

## Lỗi thường gặp và cách sửa

1. `google-services.json` bị thiếu.
   Cách sửa: thêm đúng file vào `android/app/google-services.json`.

2. `No matching client found for package name`.
   Cách sửa: package name trên Firebase phải trùng với `com.example.money_tracker`.

3. Firebase Authentication chưa bật Email/Password.
   Cách sửa: vào Firebase Authentication và bật `Email/Password`.

4. Firestore bị từ chối quyền truy cập.
   Cách sửa: kiểm tra Firestore Rules và đăng nhập đúng tài khoản.

5. Chạy `flutter run` báo thiếu package.
   Cách sửa:

```bash
flutter pub get
```

6. Sau khi đổi cấu hình Firebase nhưng app vẫn lỗi.
   Cách sửa:

```bash
flutter clean
flutter pub get
flutter run
```

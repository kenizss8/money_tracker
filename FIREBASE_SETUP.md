# Firebase Android Setup

## 1. Tạo Firebase project

1. Vào Firebase Console.
2. Chọn `Create project`.
3. Đặt tên project, ví dụ: `money-tracker`.
4. Tạo project xong thì vào màn hình tổng quan.

## 2. Thêm ứng dụng Android

1. Chọn biểu tượng Android.
2. Android package name nên nhập đúng:

```text
com.example.money_tracker
```

3. App nickname có thể đặt:

```text
Money Tracker
```

4. Tải file `google-services.json`.

## 3. Đặt file cấu hình đúng vị trí

Đặt file vừa tải vào:

```text
android/app/google-services.json
```

## 4. Bật Authentication

1. Vào `Build` -> `Authentication`.
2. Chọn `Get started`.
3. Bật `Email/Password`.

## 5. Tạo Cloud Firestore

1. Vào `Build` -> `Firestore Database`.
2. Chọn `Create database`.
3. Có thể chọn `Start in test mode` để demo nhanh.
4. Chọn region gần bạn.

## 6. Kiểm tra cấu hình Android đã có sẵn trong project

Project này đã chuẩn bị sẵn:

- Plugin `com.google.gms.google-services` trong [android/settings.gradle.kts](/D:/Myproject/money_tracker/android/settings.gradle.kts)
- Plugin Google Services trong [android/app/build.gradle.kts](/D:/Myproject/money_tracker/android/app/build.gradle.kts)
- `applicationId` là `com.example.money_tracker`

## 7. Chạy project sau khi cấu hình

```bash
flutter clean
flutter pub get
flutter run
```

## 8. Firestore structure cần dùng

```text
users/{userId}
users/{userId}/transactions/{transactionId}
users/{userId}/budgets/{budgetId}
```

## 9. Gợi ý Firestore Rules cơ bản để demo

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /budgets/{budgetId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

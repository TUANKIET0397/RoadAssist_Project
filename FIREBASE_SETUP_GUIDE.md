# Hướng dẫn Setup Firebase từ A-Z

## Bước 1: Kiểm tra Firebase Console

1. Truy cập: https://console.firebase.google.com/
2. Chọn project: `roadassist-f1081`
3. Vào **Firestore Database** ở menu bên trái

## Bước 2: Tạo Firestore Database (nếu chưa có)

1. Nếu chưa có database, click **"Create database"**
2. Chọn **"Start in test mode"** (để test nhanh)
3. Chọn location: **asia-southeast1** (Singapore) hoặc gần nhất
4. Click **"Enable"**

## Bước 3: Cấu hình Firestore Rules (QUAN TRỌNG!)

1. Vào tab **"Rules"** trong Firestore Database
2. Thay đổi rules như sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cho phép đọc/ghi garage nếu user đã đăng nhập
    match /garages/{garageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Hoặc nếu bạn muốn cho phép tất cả (CHỈ DÙNG CHO TEST):
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

3. Click **"Publish"** để lưu rules

## Bước 4: Kiểm tra Collection Structure

Đảm bảo collection `garages` có cấu trúc như sau:

```
garages/
  └── {garageId}/
      ├── name: string
      ├── address: string
      ├── phone: string
      ├── vehicleTypes: array<string>
      ├── issues: array<string>
      ├── openTime: string
      ├── closeTime: string
      ├── isActive: boolean
      ├── location: {
      │   ├── lat: number
      │   └── lng: number
      │   }
      ├── userId: string (optional)
      └── taxCode: string (optional)
```

## Bước 5: Test Firebase Connection

Chạy app và kiểm tra console logs:
- Nếu thấy: "Garage saved successfully with ID: ..." → ✅ Thành công
- Nếu thấy: "Lỗi lưu garage: ..." → ❌ Có lỗi, xem chi tiết bên dưới

## Bước 6: Debug Common Issues

### Lỗi: "Missing or insufficient permissions"
**Giải pháp**: Kiểm tra Firestore Rules (Bước 3)

### Lỗi: "Collection not found"
**Giải pháp**: Collection sẽ tự động tạo khi lưu document đầu tiên

### Lỗi: "Network error" hoặc timeout
**Giải pháp**: 
- Kiểm tra internet connection
- Kiểm tra Firebase project có đang active không
- Thử restart app

### Lỗi: "Invalid API key"
**Giải pháp**: 
- Kiểm tra `firebase_options.dart` có đúng không
- Chạy lại: `flutterfire configure`

## Bước 7: Kiểm tra trong Firebase Console

1. Vào Firestore Database
2. Xem collection `garages`
3. Nếu có document mới → ✅ Đã lưu thành công!

## Bước 8: Cải thiện Security (Sau khi test xong)

Thay đổi Firestore Rules để bảo mật hơn:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /garages/{garageId} {
      // Chỉ cho phép user sở hữu garage đó mới được sửa
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

## Troubleshooting

Nếu vẫn gặp lỗi, kiểm tra:
1. ✅ Firebase đã được initialize trong `main.dart`
2. ✅ `google-services.json` đã được thêm vào `android/app/`
3. ✅ Firestore Rules đã được publish
4. ✅ Internet connection ổn định
5. ✅ Firebase project không bị suspend


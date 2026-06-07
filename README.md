# 📱 ROAD ASSIST

## ĐỒ ÁN MÔN LẬP TRÌNH THIẾT BỊ DI ĐỘNG

## 📌 Thông tin đồ án

- **Tên đề tài:** Ứng dụng hỗ trợ gọi garage sửa xe – _Road Assist_
- **Môn học:** Lập trình Thiết bị Di động
- **Công nghệ:** Flutter
- **Hình thức:** Đồ án nhóm (4 sinh viên)
- **Giảng viên hướng dẫn:** Trương Quang Tuấn
- **Thời gian thực hiện:** 2 tháng

---

## 📖 1. Giới thiệu đề tài

Trong bối cảnh thiết bị di động ngày càng phổ biến, việc xây dựng các ứng dụng hỗ trợ người dùng trong các tình huống khẩn cấp là rất cần thiết.  
Đề tài **Road Assist** được nhóm thực hiện nhằm xây dựng một ứng dụng di động cho phép **người dùng nhanh chóng liên hệ với các garage sửa xe** khi gặp sự cố.

Ứng dụng đóng vai trò là cầu nối giữa:

- **Người dùng** cần hỗ trợ
- **Garage** cung cấp dịch vụ sửa chữa

---

## 🎯 2. Mục tiêu đề tài

- Vận dụng kiến thức Flutter vào dự án thực tế
- Làm việc nhóm theo mô hình phân vai (BA – Developer)
- Hiểu quy trình phân tích yêu cầu và triển khai phần mềm
- Tích hợp backend cloud (Firebase)
- Hoàn thiện một ứng dụng di động chạy được trên Android

---

## ✨ 3. Chức năng chính

### 👤 Người dùng

- Đăng ký, đăng nhập tài khoản
- Xem danh sách garage
- Thực hiện cuộc gọi đến garage
- Xem thông tin garage

### 🏪 Garage

- Quản lý thông tin garage
- Nhận cuộc gọi từ người dùng
- Phản hồi hỗ trợ

### ⚙️ Hệ thống

- Lưu trữ dữ liệu người dùng và garage
- Đồng bộ dữ liệu thời gian thực
- Quản lý xác thực người dùng

---

## 🛠 4. Công nghệ sử dụng

| Thành phần     | Công nghệ               |
| -------------- | ----------------------- |
| Ngôn ngữ       | Dart                    |
| Framework      | Flutter                 |
| Backend        | Firebase                |
| Database       | Cloud Firestore         |
| Authentication | Firebase Authentication |
| UI             | Material Design         |
| Thiết kế       | Figma                   |

---

## 📱 5. Giao diện ứng dụng

<p align="center">
  <img src="assets/images/intro/intro1.png" height="400"/>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/images/intro/intro3.png" height="400"/>
</p>

<p align="center">
  <img src="assets/images/intro/intro1.png" height="400"/>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/images/intro/intro3.png" height="400"/>
</p>

## 🗂 6. Cấu trúc thư mục

```
└── 📁lib
    └── 📁config
        ├── app_config.dart
    └── 📁core
        └── 📁auth
            ├── auth_state.dart
        └── 📁errors
            └── 📁widgets
                ├── emergency_card.dart
            ├── no_internet_screen.dart
        └── 📁network
            ├── network_service.dart
            ├── network_status.dart
        └── 📁providers
            ├── auth_provider.dart
            ├── garage_notification_provider.dart
            ├── navigation_provider.dart
            ├── selected_role.dart
        └── 📁routes
            ├── app_routes.dart
            ├── navigation_observer.dart
            ├── route_config.dart
            ├── route_paths.dart
            ├── route_redirect.dart
        └── 📁services
            └── 📁gps
                ├── location_geolocator.dart
            └── 📁login
                ├── login_option.dart
            └── 📁storage
                ├── firebase_storage_service.dart
                ├── storage_provider.dart
            ├── call_hotline.dart
            ├── garage_scanner_service.dart
        └── 📁theme
            ├── app_palette.dart
            ├── app_theme_type.dart
            ├── app_theme.dart
            ├── theme_provider.dart
        └── 📁utils
            ├── geo_utils.dart
    └── 📁data
        └── 📁datasources
            └── 📁local
                ├── vehicle_constants.dart
            └── 📁remote
                ├── auth_remote_datasource.dart
                ├── rescue_service.dart
        └── 📁models
            ├── chat_model.dart
            ├── completion_payload.dart
            ├── garage_completion_payload.dart
            ├── garage_model.dart
            ├── message_model.dart
            ├── rescue_request_model.dart
            ├── review_model.dart
            ├── user_input.dart
            ├── user_model.dart
    └── 📁ui
        └── 📁auth
            └── 📁view
                ├── auth_role_screen.dart
                ├── garage_register_screen.dart
                ├── garage_success_screen.dart
                ├── login_screen.dart
                ├── user_register_screen.dart
            └── 📁viewmodel
                ├── garage_register_vm.dart
                ├── garage_success_vm.dart
                ├── login_viewmodel.dart
                ├── user_register_vm.dart
            └── 📁widgets
                ├── custom_text_field.dart
                ├── day_selector.dart
                ├── garage_info_card.dart
                ├── password_text_field.dart
                ├── phone_text_field.dart
                ├── section_header.dart
                ├── service_chip.dart
                ├── success_header.dart
                ├── time_picker_field.dart
                ├── vehicle_type_item.dart
        └── 📁call
            └── 📁extensions
                ├── call_extension.dart
            └── 📁models
                ├── call_model.dart
            └── 📁screens
                ├── call_screen.dart
                ├── incoming_call_screen.dart
                ├── waiting_call_screen.dart
            └── 📁services
                ├── call_initiation_service.dart
                ├── call_service.dart
            └── 📁widgets
                ├── wave_form_painter.dart
        └── 📁garage
            └── 📁account
                └── 📁models
                    ├── change_password_state.dart
                └── 📁view
                    ├── garage_account_screen.dart
                    ├── info_screen.dart
                    ├── password_reset_customer_sreen.dart
                    ├── search_screen.dart
                └── 📁viewmodel
                    ├── change_password_state.dart
                    ├── change_password_vm.dart
                    ├── garage_state.dart
                    ├── garage_vm.dart
                └── 📁widgets
                    ├── action_button.dart
                    ├── add_vehicle_dialog.dart
                    ├── garage_card.dart
                    ├── garage_text_field.dart
                    ├── password_field.dart
                    ├── save_garage_button.dart
                    ├── service_support_section.dart
                    ├── services_selector.dart
                    ├── vehicle_support_item.dart
                    ├── vehicle_support_section.dart
                    ├── working_days_selector.dart
                    ├── working_time_selector.dart
            └── 📁history
                └── 📁model
                    ├── garage_history_item.dart
                └── 📁view
                    ├── garage_history_detail_screen.dart
                    ├── garage_history_screen.dart
                └── 📁viewmodel
                    ├── garage_history_vm.dart
                └── 📁widgets
                    ├── garage_history_card.dart
                    ├── garage_history_filter_tabs.dart
                    ├── garage_history_status_badge.dart
            └── 📁home
                └── 📁view
                    ├── garage_completion_screen.dart
                    ├── garage_home_screen.dart
                    ├── garage_rescue_request_detail_screen.dart
                    ├── garage_rescue_status_update_screen.dart
                └── 📁viewmodel
                    ├── garage_completion_vm.dart
                    ├── garage_distance_vm.dart
                    ├── garage_home_viewmodel.dart
                └── 📁widgets
                    ├── garage_completion_actions.dart
                    ├── garage_completion_header.dart
                    ├── garage_completion_info_card.dart
                    ├── rescue_request_card.dart
            └── 📁review
                └── 📁view
                    ├── garage_reviews_screen.dart
                └── 📁viewmodel
                    ├── review_vm.dart
                └── 📁widget
                    ├── rating_bar_item.dart
                    ├── rating_overview.dart
                    ├── review_list_item.dart
        └── 📁map
            ├── location_pick_result.dart
            ├── map_pick_screen.dart
        └── 📁navigation
            └── 📁configs
                ├── garage_bottom_nav.dart
                ├── user_bottom_nav.dart
            └── 📁view
                ├── garage_main_screen.dart
                ├── user_main_screen.dart
            └── 📁viewmodel
                ├── garage_navigation_provider.dart
                ├── rescue_navigation_provider.dart
            └── 📁widgets
                ├── bottom_nav_item.dart.dart
                ├── slanted_animated_bottom_bar.dart
        └── 📁shared
            └── 📁skeleton
                ├── skeleton_widgets.dart
            └── 📁widgets
                ├── rescue_progress_timeline.dart
                ├── view_history_button.dart
        └── 📁user
            └── 📁account
                └── 📁model
                    ├── vehicle_model.dart
                └── 📁view
                    ├── account_screen.dart
                    ├── edit_profile_screen.dart
                    ├── password_reset_user_sreen.dart
                └── 📁viewmodel
                    ├── account_vm.dart
                    ├── edit_profile_vm.dart
                    ├── profile_viewmodel.dart
                    ├── vehicle_action_vm.dart
                └── 📁widgets
                    ├── action_grid.dart
                    ├── action_item.dart
                    ├── birth_date_field.dart
                    ├── logout_button.dart
                    ├── profile_card.dart
                    ├── vehicle_item.dart
                    ├── vehicle_section.dart
            └── 📁chat
                └── 📁view
                    ├── chatGarage_screen.dart
                    ├── chatList_screen.dart
                └── 📁viewmodel
                    ├── chatGarage_vm.dart
                    ├── chatList_vm.dart
                └── 📁widgets
                    ├── date_divider.dart
                    ├── message_bubble.dart
                    ├── triangle_gradient_painter.dart
            └── 📁garage
                └── 📁view
                    ├── garage_list_screen.dart
                    ├── garage_screen.dart
                    ├── garageDetail.dart
                    ├── review_screen.dart
                └── 📁viewmodel
                    ├── garage_favourite_vm.dart
                    ├── garage_vm.dart
                    ├── garageDetail_viewmodel.dart
                └── 📁widget
                    ├── garage_card.dart
                    ├── garage_favourite_screen.dart
                    ├── garage_list_view.dart
            └── 📁history
                └── 📁model
                    ├── history_item.dart
                └── 📁view
                    ├── history_detail_screen.dart
                    ├── history_screen.dart
                └── 📁viewmodel
                    ├── history_vm.dart
                └── 📁widgets
                    ├── history_card.dart
                    ├── history_filter_tabs.dart
                    ├── history_status_badge.dart
            └── 📁home
                └── 📁clippers
                    ├── rps_clipper_big.dart
                    ├── rps_clipper_small.dart
                └── 📁models
                    ├── vehicle_grid_data.dart
                    ├── vehicle_model.dart
                └── 📁painters
                    ├── clipper_border_painter.dart
                └── 📁view
                    ├── home_screen.dart
                    ├── main_home.dart
                └── 📁viewmodel
                    ├── home_vehicle_provider.dart
                    ├── vehicle_grid_provider.dart
                └── 📁widgets
                    ├── big_vehicle_card.dart
                    ├── clipped_card.dart
                    ├── feature_card.dart
                    ├── main_home.dart
                    ├── vehicle_favorite_grid.dart
                    ├── vehicle_grid_item.dart
            └── 📁rescue
                └── 📁view
                    ├── completion_screen.dart
                    ├── rescue_screen_wrapper.dart
                    ├── rescueRequest_screen.dart
                    ├── user_rescue_no_garage_screen_new.dart
                    ├── user_rescue_success_screen.dart
                    ├── user_rescue_tracking_screen.dart
                    ├── user_rescue_waiting_screen.dart
                └── 📁viewmodel
                    ├── completion_vm.dart
                    ├── rescue_navigation_provider.dart
                    ├── rescue_viewmodel.dart
                └── 📁widgets
                    ├── completion_actions.dart
                    ├── completion_header.dart
                    ├── completion_info_card.dart
                    ├── completion_rating_card.dart
                    ├── radar_scanner.dart
                    ├── rating_logic.dart
                    ├── rating_stars.dart
                    ├── rescue_cancel_button.dart
                    ├── rescue_cancel_dialog.dart
                    ├── rescue_image_picker.dart
                    ├── rescue_issue_selector.dart
                    ├── rescue_location_card.dart
                    ├── rescue_location_picker.dart
                    ├── rescue_status_checklist.dart
                    ├── rescue_vehicle_selector.dart
                    ├── rescue_vehiclecard.dart
    ├── app.dart
    ├── firebase_options.dart
    └── main.dart
```

---

## ⚙️ 7. Cài đặt và chạy chương trình

### Bước 1: Clone project

```bash
git clone https://github.com/TUANKIET0397/RoadAssist_Project.git
cd road-assist
```

### Bước 2: Cài đặt thư viện

```bash
flutter pub get
```

### Bước 3: Chạy ứng dụng

```bash
flutter run
```

### ✍️ Yêu cầu môi trường

- Flutter SDK >= 3.x

- Android Studio hoặc VS Code

- Android Emulator hoặc thiết bị thật

## 🔐 8. Cấu hình Firebase

- Tạo project Firebase

- Kết nối app Android

- Thêm file google-services.json vào thư mục android/app

#### Bật các dịch vụ:

- Firebase Authentication

- Cloud Firestore

- Storage

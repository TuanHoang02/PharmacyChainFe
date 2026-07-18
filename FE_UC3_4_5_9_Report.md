# Báo Cáo Kết Quả Triển Khai Giao Diện Frontend (Flutter)
**Dự án**: Pharmacy Chain System (Hệ thống quản lý chuỗi nhà thuốc)  
**Phạm vi**: Triển khai tích hợp các chức năng UC03, UC04, UC05, UC09.

---

## 🏛️ 1. Phạm vi thực hiện (Scope of Work)
Báo cáo này tóm tắt kết quả phát triển các màn hình giao diện (UI) và nghiệp vụ kết nối API phục vụ cho 4 Use Cases chính của khối quản lý hệ thống:
1. **UC03 - Quản lý Chi nhánh (Branch Management)**: Xem danh sách, tìm kiếm, lọc, tạo mới, chỉnh sửa thông tin chi nhánh và khóa hoạt động chi nhánh.
2. **UC04 - Quản lý Danh mục thuốc (Category Management)**: CRUD phân loại danh mục thuốc thông qua popup tương tác nhanh.
3. **UC05 - Quản lý Nhà cung cấp (Supplier Management)**: Quản lý thông tin liên hệ và trạng thái của các đối tác cung ứng dược phẩm.
4. **UC09 - Quản lý Nhân viên (Staff Management)**:
   - **Operations Manager**: Quản lý toàn bộ nhân sự hệ thống, phân bổ nhân sự vào các chi nhánh khác nhau.
   - **Branch Manager**: Chỉ xem và quản trị (thêm/sửa/xóa mềm) các dược sĩ thuộc chi nhánh do chính mình phụ trách.

---

## 📂 2. Chi tiết các tệp tin được bổ sung và cập nhật

### ➕ Tệp tin được bổ sung mới (`[NEW]`)

| Tên tệp tin | Đường dẫn | Chức năng nhiệm vụ |
| :--- | :--- | :--- |
| **`branch_service.dart`** | `lib/features/operations_manager/services/` | Gọi API `/api/Branch` kết nối CRUD chi nhánh. |
| **`branch_list_screen.dart`** | `lib/features/operations_manager/views/` | Giao diện danh sách chi nhánh, tìm kiếm, lọc trạng thái, phân trang. |
| **`branch_form_screen.dart`** | `lib/features/operations_manager/views/` | Form khai báo/chỉnh sửa thông tin chi nhánh kèm validate dữ liệu. |
| **`category_service.dart`** | `lib/features/operations_manager/services/` | Gọi API `/api/Category` tương tác danh mục thuốc. |
| **`category_list_screen.dart`** | `lib/features/operations_manager/views/` | Giao diện quản lý danh mục thuốc (thêm/sửa trực tiếp bằng Popup Dialog). |
| **`supplier_service.dart`** | `lib/features/operations_manager/services/` | Gọi API `/api/Supplier` tương tác nhà cung cấp. |
| **`supplier_list_screen.dart`** | `lib/features/operations_manager/views/` | Giao diện quản lý nhà cung cấp (CRUD qua Popup Dialog). |
| **`staff_service.dart`** | `lib/shared/services/` | Dịch vụ gọi API `/api/Staff` dùng chung cho cả 2 vai trò quản lý. |
| **`staff_management_screen.dart`**| `lib/features/operations_manager/views/` | Màn hình quản lý toàn bộ nhân viên chuỗi dành cho Operations Manager. |
| **`branch_staff_screen.dart`** | `lib/features/branch_manager/views/` | Màn hình quản lý nhân viên nội bộ chi nhánh của Branch Manager. |
| **`staff_form_screen.dart`** | `lib/features/shared/views/` | Form chung tạo/sửa tài khoản nhân sự (tự động khóa chi nhánh theo role). |

---

### 📝 Tệp tin cấu hình được chỉnh sửa (`[MODIFY]`)

1. **`app_router.dart`** (`lib/core/routes/`): Đăng ký phân quyền và định tuyến (GoRouter) tới toàn bộ các màn hình con mới mà không làm thay đổi các route sẵn có (Admin, Pharmacist, Supplier).
2. **`local_storage_service.dart`** (`lib/core/network/`): Viết thuật toán tự giải mã payload của JWT Token (`_decodeJwt`) để tự động tách claim `BranchID` lưu trữ vào SharedPreferences khi đăng nhập thành công.
3. **`api_constants.dart`** (`lib/core/constants/`): Cấu hình dynamic getter tự động nhận diện thiết bị chạy (trả về cổng `localhost:5003` trên Windows Desktop và `10.0.2.2:5003` trên máy ảo Android).
4. **`operations_manager_main_layout.dart`** & **`branch_manager_main_layout.dart`**: Cấu hình các Tabs điều hướng BottomNavigationBar chuyển màn hình tương ứng.

---

## ⚡ 3. Các điểm nhấn kỹ thuật quan trọng (Technical Highlights)

* **Tự động nhận diện cổng kết nối API**: Hệ thống tự kiểm tra nền tảng (`Platform.isAndroid` và `kIsWeb`) để quyết định cổng giao tiếp. Nhờ đó, ứng dụng hoạt động ngay trên cả Windows Desktop lẫn máy ảo Android mà không cần lập trình viên sửa code.
* **Giải mã JWT Client-side**: Việc viết hàm tự giải mã token thô giúp loại bỏ sự lệ thuộc vào thư viện ngoài (`jwt_decoder`), tối giản hóa dung lượng ứng dụng Flutter.
* **Phân quyền nhân sự tự động**: Logic nghiệp vụ được tích hợp chặt chẽ; `BranchManager` không thể chọn chi nhánh khác của chuỗi nhân sự khi tạo tài khoản nhờ cơ chế tự ẩn/khóa trường dữ liệu chi nhánh.
* **Popup Dialog CRUD thông minh**: Giảm tải số lượng màn hình chuyển trang bằng cách tích hợp trực tiếp Form tương tác vào Dialog (áp dụng cho Category & Supplier), mang lại trải nghiệm mượt mà và trực quan.

---

## 🔬 4. Hướng dẫn kiểm tra và chạy thử
1. Đảm bảo cổng Backend .NET chạy tại cổng `5003`.
2. Khởi chạy ứng dụng Frontend trên thiết bị bất kỳ (`flutter run`).
3. Đăng nhập với tài khoản:
   - **Operations Manager**: `opsmanager@gmail.com` / `123456`
   - **Branch Manager**: `branchmanager@gmail.com` / `123456`

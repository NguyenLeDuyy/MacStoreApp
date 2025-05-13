import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mac_store_app/views/screens/main_screen.dart'; // Import màn hình chính
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SignUpAndCreateBusiness2 extends StatefulWidget {
  // Nhận dữ liệu từ Bước 1
  final Map<String, dynamic> initialData;

  const SignUpAndCreateBusiness2({super.key, required this.initialData});

  @override
  State<SignUpAndCreateBusiness2> createState() => _SignUpAndCreateBusiness2State();
}

class _SignUpAndCreateBusiness2State extends State<SignUpAndCreateBusiness2> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường input của Bước 2
  final _aboutController = TextEditingController();
  final _categoriesController = TextEditingController();
  final _tagsController = TextEditingController();

  // State cho ảnh và loading
  File? _selectedImage;
  bool _isLoading = false; // Loading cho nút Hoàn tất
  String? _uploadedImageUrl; // Lưu URL ảnh sau khi upload

  @override
  void dispose() {
    // Giải phóng controllers
    _aboutController.dispose();
    _categoriesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    // Kiểm tra và yêu cầu quyền truy cập
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos, // iOS >= 14 & Android >= 33
      Permission.storage, // Android < 33
    ].request();

    bool permissionGranted = statuses.values.any((status) => status.isGranted || status.isLimited); // isLimited cho iOS

    if (permissionGranted) {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // Giảm chất lượng ảnh một chút
        if (pickedFile != null && mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Lỗi khi chọn ảnh: $e"), backgroundColor: Colors.red));
      }
    } else {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Quyền truy cập ảnh bị từ chối. Vui lòng cấp quyền trong cài đặt."),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Cài đặt',
          textColor: Colors.white,
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }
}
  }

  // Hàm Upload ảnh lên Supabase Storage
  Future<String?> _uploadImage(File imageFile, String userId) async {
    try {
      // *** KIỂM TRA LẠI TÊN BUCKET TRÊN SUPABASE STORAGE ***
      const bucketName = 'businesslogos'; // <-- Đảm bảo bucket này tồn tại
      // -----------------------------------------------------
      // Tạo đường dẫn file duy nhất trên Storage
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      print("Đang upload ảnh lên: $bucketName/$fileName");
      // Thực hiện upload
      await supabase.storage.from(bucketName).upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false), // Cấu hình tùy chọn
      );

      // Lấy URL công khai của ảnh vừa upload
      final imageUrlResponse = supabase.storage.from(bucketName).getPublicUrl(fileName);
      print("Upload ảnh thành công. URL: $imageUrlResponse");
      return imageUrlResponse;

    } catch (e) {
      print("Lỗi upload ảnh: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Lỗi upload ảnh: $e"), backgroundColor: Colors.red));
      return null;
    }
  }


  // --- HÀM HOÀN TẤT ĐĂNG KÝ (CẬP NHẬT THEO SCHEMA) ---
  Future<void> _completeSignUp() async {
    print('>>> BUTTON SIGN UP PRESSED');
    // Validate các trường của Bước 2
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ và đúng định dạng!')),
      );
      return;
    }

    // Bắt đầu trạng thái loading
    setState(() { _isLoading = true; });

    // Lấy User ID từ dữ liệu Bước 1
    final userId = widget.initialData['userId'] as String?;
    if (userId == null) {
      _showErrorDialog("Lỗi nghiêm trọng: Không có User ID.");
      setState(() { _isLoading = false; });
      return;
    }

    // 1. Upload ảnh (nếu người dùng đã chọn)
    _uploadedImageUrl = null; // Reset URL trước khi upload mới
    if (_selectedImage != null) {
      _uploadedImageUrl = await _uploadImage(_selectedImage!, userId);
      // Nếu upload lỗi, bạn có thể quyết định dừng lại hoặc tiếp tục không có ảnh
      // Ví dụ: Dừng lại nếu upload lỗi
      // if (_uploadedImageUrl == null && mounted) {
      //    _showErrorDialog("Lỗi upload ảnh đại diện. Vui lòng thử lại.");
      //    setState(() { _isLoading = false; });
      //    return;
      // }
    }

    // 2. Lấy và xử lý dữ liệu từ controllers Bước 2
    final about = _aboutController.text.trim();
    // Chuyển đổi categories và tags thành List<String> (tách bằng dấu phẩy)
    final List<String> categoriesList = _categoriesController.text.trim()
        .split(',') // Tách chuỗi bằng dấu phẩy
        .map((e) => e.trim()) // Loại bỏ khoảng trắng thừa
        .where((e) => e.isNotEmpty) // Loại bỏ phần tử rỗng
        .toList();
    final List<String> tagsList = _tagsController.text.trim()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // 3. Chuẩn bị Map dữ liệu để insert vào bảng 'business_accounts'
    // *** Đảm bảo các key khớp với tên cột trong schema bạn cung cấp ***
    final businessData = {
      'user_id': userId, // Liên kết với auth.users.id (Đảm bảo buyers(uid) tồn tại)
      'company_name': widget.initialData['companyName'],
      'company_number': widget.initialData['companyNumber'].isNotEmpty ? widget.initialData['companyNumber'] : null, // Lưu null nếu rỗng
      'address': widget.initialData['address'],
      'nid_owner': widget.initialData['nid'],
      'email': widget.initialData['email'], // Email liên hệ (từ Bước 1)
      'profile_picture_url': _uploadedImageUrl, // URL ảnh (có thể null)
      'about': about.isNotEmpty ? about : null, // Lưu null nếu rỗng
      'categories': categoriesList.isNotEmpty ? categoriesList : null, // Lưu null nếu list rỗng
      'tags': tagsList.isNotEmpty ? tagsList : null, // Lưu null nếu list rỗng
      // 'status', 'requested_at', 'created_at', 'reviewed_at' sẽ có giá trị default hoặc null từ DB
    };

    print("Dữ liệu chuẩn bị insert vào business_accounts: $businessData");

    // 4. Thực hiện insert vào bảng 'business_accounts'
    try {
      // *** Sử dụng đúng tên bảng: 'business_accounts' ***
      await supabase.from('business_accounts').insert(businessData);

      print("Lưu thông tin business account thành công!");

      // Điều hướng đến màn hình chính sau khi thành công
      if (mounted) {
        // Hiển thị thông báo thành công ngắn gọn
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký cửa hàng thành công!'), backgroundColor: Colors.green),
        );
        // Đợi 1 chút để người dùng thấy thông báo rồi mới chuyển màn hình
        await Future.delayed(const Duration(seconds: 1));
        // Xóa hết stack và về màn hình chính
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      }

    } on PostgrestException catch (e) {
      print("Lỗi Postgrest khi lưu business account: ${e.code} - ${e.message} - ${e.details}");
      String errorMessage = 'Lỗi lưu thông tin cửa hàng.';
      // Kiểm tra lỗi khóa ngoại cụ thể
      if (e.message.contains('violates foreign key constraint') && e.message.contains('business_accounts_user_id_fkey')) {
        errorMessage = 'Lỗi liên kết tài khoản người dùng. Hãy đảm bảo tài khoản người mua đã được tạo.';
      } else if (e.code == '23505') { // Lỗi unique violation (ví dụ: email hoặc user_id đã tồn tại)
        errorMessage = 'Thông tin cửa hàng (email hoặc tài khoản) đã tồn tại.';
      } else {
        errorMessage = 'Lỗi lưu thông tin: ${e.message}';
      }
      if (mounted) _showErrorDialog(errorMessage);

    } catch (e) {
      print("Lỗi không xác định khi lưu business account: $e");
      if (mounted) _showErrorDialog('Đã xảy ra lỗi không mong muốn: $e');
    } finally {
      // Luôn kết thúc trạng thái loading
      if (mounted) setState(() { _isLoading = false; });
    }
  }
  // ------------------------------------------------------

  // Hàm hiển thị dialog lỗi
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.error_outline, color: Colors.red, size: 40),
          title: const Text('Đã có lỗi xảy ra'),
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [ TextButton( onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đã hiểu')) ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Thông tin Doanh nghiệp', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white, // Màu AppBar
        foregroundColor: Colors.blue[800], // Màu chữ/icon AppBar
        elevation: 1, // Đổ bóng nhẹ
        leading: IconButton( // Nút back rõ ràng hơn
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại Bước 1',
        ),
      ),
      body: SafeArea(
        child: Center( // Căn giữa nội dung
          child: ConstrainedBox( // Giới hạn chiều rộng
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0), // Padding đều
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Căn trái các label
                  children: [
                    // --- Chọn Ảnh đại diện/Logo ---
                    Text("Ảnh đại diện / Logo", style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160, // Tăng chiều cao
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 45, color: Colors.grey.shade400), // Icon to hơn
                            const SizedBox(height: 10),
                            Text("Nhấn để chọn ảnh", style: GoogleFonts.lato(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Tăng khoảng cách

                    // --- Các trường thông tin chi tiết ---
                    _buildTextField("Giới thiệu về cửa hàng *", _aboutController, maxLines: 4, isRequired: true, hint: 'Mô tả ngắn về doanh nghiệp, sản phẩm chính...'),
                    _buildTextField("Danh mục chính *", _categoriesController, isRequired: true, hint: 'Nhập các danh mục, cách nhau bằng dấu phẩy (,)'),
                    _buildTextField("Tags (Từ khóa)", _tagsController, hint: 'Nhập các tag liên quan, cách nhau bằng dấu phẩy (,)'),

                    const SizedBox(height: 32), // Tăng khoảng cách
                    // --- Nút HOÀN TẤT ĐĂNG KÝ ---
                    SizedBox(
                      width: double.infinity,
                      height: 50, // Tăng chiều cao nút
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: _isLoading ? null : _completeSignUp, // Disable khi loading
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : Text(
                          'HOÀN TẤT ĐĂNG KÝ',
                          style: GoogleFonts.lato(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Khoảng cách dưới cùng
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper để tạo TextFormField cho Bước 2 (Cải tiến UI)
  Widget _buildTextField(
      String label,
      TextEditingController controller,
      {int maxLines = 1, bool isRequired = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label + (isRequired ? " *" : ""), // Label có dấu * nếu bắt buộc
          labelStyle: GoogleFonts.lato(color: Colors.grey.shade700),
          hintText: hint, // Hiển thị hint text
          hintStyle: GoogleFonts.lato(color: Colors.grey.shade400, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          alignLabelWithHint: true, // Căn label với hint khi nhiều dòng
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Thông tin này là bắt buộc';
          }
          return null;
        },
      ),
    );
  }
}

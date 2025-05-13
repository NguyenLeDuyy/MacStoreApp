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
    // In ra để kiểm tra trạng thái quyền trước khi yêu cầu
    print("Trạng thái Permission.photos trước khi request: ${await Permission.photos.status}");
    print("Trạng thái Permission.storage trước khi request: ${await Permission.storage.status}");

    // Kiểm tra và yêu cầu quyền truy cập
    // permission_handler sẽ tự động chọn quyền phù hợp dựa trên phiên bản OS
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos, // Dành cho iOS >= 14 & Android >= 33 (READ_MEDIA_IMAGES)
      Permission.storage, // Dành cho Android < 33 (READ_EXTERNAL_STORAGE)
      // Trên Android 33+, yêu cầu này có thể không được cấp hoặc không cần thiết nếu Permission.photos đã đủ.
    ].request();

    print("Kết quả sau khi request permissions: $statuses");

    // Kiểm tra xem ít nhất một trong các quyền cần thiết đã được cấp hay chưa
    // isGranted: Quyền đã được cấp đầy đủ.
    // isLimited: Quyền được cấp một phần (ví dụ: trên iOS, người dùng chỉ chọn một số ảnh nhất định).
    bool photosPermissionGranted = statuses[Permission.photos]?.isGranted ?? false;
    bool photosPermissionLimited = statuses[Permission.photos]?.isLimited ?? false; // Quan trọng cho iOS
    bool storagePermissionGranted = statuses[Permission.storage]?.isGranted ?? false;

    // Ưu tiên Permission.photos nếu được cấp (cho các OS mới hơn)
    // Hoặc Permission.storage cho các OS cũ hơn
    bool permissionActuallyGranted = (photosPermissionGranted || photosPermissionLimited) || storagePermissionGranted;

    print("Permission.photos granted: $photosPermissionGranted, limited: $photosPermissionLimited");
    print("Permission.storage granted: $storagePermissionGranted");
    print("permissionActuallyGranted: $permissionActuallyGranted");


    if (permissionActuallyGranted) {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
        if (pickedFile != null && mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        } else {
          print("Image picking cancelled or pickedFile is null.");
        }
      } catch (e) {
        print("Lỗi khi dùng ImagePicker: $e");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Lỗi khi chọn ảnh: $e"), backgroundColor: Colors.red));
      }
    } else {
      // Xử lý trường hợp không có quyền nào được cấp
      print("Quyền truy cập ảnh/bộ nhớ bị từ chối hoàn toàn.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Quyền truy cập ảnh bị từ chối. Vui lòng cấp quyền trong cài đặt."),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5), // Tăng thời gian hiển thị
            action: SnackBarAction(
              label: 'Mở Cài đặt',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings(); // Mở trang cài đặt của ứng dụng
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
      const bucketName = 'businesslogos'; // <-- Đảm bảo bucket này tồn tại và có policy phù hợp
      // -----------------------------------------------------
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      print("Đang upload ảnh lên: $bucketName/$fileName");
      await supabase.storage.from(bucketName).upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final imageUrlResponse = supabase.storage.from(bucketName).getPublicUrl(fileName);
      print("Upload ảnh thành công. URL: $imageUrlResponse");
      return imageUrlResponse;

    } catch (e) {
      print("Lỗi upload ảnh: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Lỗi upload ảnh: $e"), backgroundColor: Colors.red));
      return null;
    }
  }


  Future<void> _completeSignUp() async {
    print('>>> BUTTON SIGN UP PRESSED');
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ và đúng định dạng!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final userId = widget.initialData['userId'] as String?;
    if (userId == null) {
      _showErrorDialog("Lỗi nghiêm trọng: Không có User ID.");
      setState(() { _isLoading = false; });
      return;
    }

    _uploadedImageUrl = null;
    if (_selectedImage != null) {
      _uploadedImageUrl = await _uploadImage(_selectedImage!, userId);
      // Cân nhắc: Nếu upload ảnh là bắt buộc và thất bại, có thể dừng ở đây.
      // if (_uploadedImageUrl == null) {
      //   if (mounted) _showErrorDialog("Lỗi upload ảnh đại diện. Không thể hoàn tất.");
      //   setState(() { _isLoading = false; });
      //   return;
      // }
    }

    final about = _aboutController.text.trim();
    final List<String> categoriesList = _categoriesController.text.trim()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final List<String> tagsList = _tagsController.text.trim()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final businessData = {
      'user_id': userId,
      'company_name': widget.initialData['companyName'],
      'company_number': widget.initialData['companyNumber'].isNotEmpty ? widget.initialData['companyNumber'] : null,
      'address': widget.initialData['address'],
      'nid_owner': widget.initialData['nid'],
      'email': widget.initialData['email'],
      'profile_picture_url': _uploadedImageUrl,
      'about': about.isNotEmpty ? about : null,
      'categories': categoriesList.isNotEmpty ? categoriesList : null,
      'tags': tagsList.isNotEmpty ? tagsList : null,
    };

    print("Dữ liệu chuẩn bị insert vào business_accounts: $businessData");

    try {
      await supabase.from('business_accounts').insert(businessData);
      print("Lưu thông tin business account thành công!");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký cửa hàng thành công!'), backgroundColor: Colors.green),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      }

    } on PostgrestException catch (e) {
      print("Lỗi Postgrest khi lưu business account: ${e.code} - ${e.message} - ${e.details}");
      String errorMessage = 'Lỗi lưu thông tin cửa hàng.';
      if (e.message.contains('violates foreign key constraint') && e.message.contains('business_accounts_user_id_fkey')) {
        errorMessage = 'Lỗi liên kết tài khoản người dùng. Hãy đảm bảo tài khoản người mua đã được tạo.';
      } else if (e.code == '23505') {
        errorMessage = 'Thông tin cửa hàng (email hoặc tài khoản) đã tồn tại.';
      } else {
        errorMessage = 'Lỗi lưu thông tin: ${e.message}';
      }
      if (mounted) _showErrorDialog(errorMessage);

    } catch (e) {
      print("Lỗi không xác định khi lưu business account: $e");
      if (mounted) _showErrorDialog('Đã xảy ra lỗi không mong muốn: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

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
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại Bước 1',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ảnh đại diện / Logo", style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
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
                            Icon(Icons.add_a_photo_outlined, size: 45, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text("Nhấn để chọn ảnh", style: GoogleFonts.lato(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField("Giới thiệu về cửa hàng", _aboutController, maxLines: 4, isRequired: false, hint: 'Mô tả ngắn về doanh nghiệp, sản phẩm chính...'), // isRequired: false nếu không bắt buộc
                    _buildTextField("Danh mục chính", _categoriesController, isRequired: false, hint: 'Nhập các danh mục, cách nhau bằng dấu phẩy (,)'), // isRequired: false nếu không bắt buộc
                    _buildTextField("Tags (Từ khóa)", _tagsController, hint: 'Nhập các tag liên quan, cách nhau bằng dấu phẩy (,)'),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: _isLoading ? null : _completeSignUp,
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : Text(
                          'HOÀN TẤT ĐĂNG KÝ',
                          style: GoogleFonts.lato(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          labelText: label + (isRequired ? " *" : ""),
          labelStyle: GoogleFonts.lato(color: Colors.grey.shade700),
          hintText: hint,
          hintStyle: GoogleFonts.lato(color: Colors.grey.shade400, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          alignLabelWithHint: true,
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

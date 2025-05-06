import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screens/business_signup_step2.dart'; // Import Bước 2
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SignUpAndCreateBusiness1 extends StatefulWidget {
  const SignUpAndCreateBusiness1({super.key});

  @override
  State<SignUpAndCreateBusiness1> createState() => _SignUpAndCreateBusiness1State();
}

class _SignUpAndCreateBusiness1State extends State<SignUpAndCreateBusiness1> {
  // Khởi tạo Supabase client (chỉ để lấy user hiện tại nếu cần)
  final supabase = Supabase.instance.client;

  // GlobalKey cho Form để validate
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường input (Bỏ email/password ở đây)
  final _companyNameController = TextEditingController();
  final _companyNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _nidController = TextEditingController();
  // Lấy email từ user đang đăng nhập
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    // Lấy email của người dùng đang đăng nhập
    _currentUserEmail = supabase.auth.currentUser?.email;
    // Có thể thêm logic kiểm tra nếu currentUser là null (dù không nên xảy ra ở màn này)
    if (_currentUserEmail == null) {
      print("Lỗi: Người dùng chưa đăng nhập khi vào màn hình đăng ký store.");
      // Có thể điều hướng về màn hình login hoặc hiển thị lỗi
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Navigator.of(context).pop(); // Ví dụ: Quay lại màn hình trước
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng đăng nhập trước.")));
      // });
    }
  }


  @override
  void dispose() {
    // Giải phóng controllers
    _companyNameController.dispose();
    _companyNumberController.dispose();
    _addressController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút "TIẾP THEO"
  void _goToStep2() {
    // Validate form trước khi chuyển sang bước tiếp theo
    if (!_formKey.currentState!.validate()) {
      return; // Dừng lại nếu form không hợp lệ
    }

    // Lấy User ID của người dùng đang đăng nhập (quan trọng)
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _showErrorDialog("Lỗi: Không thể xác định người dùng. Vui lòng đăng nhập lại.");
      return;
    }

    // Lấy dữ liệu từ controllers
    final companyName = _companyNameController.text.trim();
    final companyNumber = _companyNumberController.text.trim();
    final address = _addressController.text.trim();
    final nid = _nidController.text.trim();

    // Chuyển sang Bước 2 và truyền dữ liệu đã nhập + User ID + Email
    Navigator.push( // Dùng push thay vì pushReplacement để có thể back lại Bước 1
      context,
      MaterialPageRoute(
        builder: (_) => SignUpAndCreateBusiness2(
          initialData: {
            'userId': userId, // User ID từ Auth
            'companyName': companyName,
            'companyNumber': companyNumber,
            'address': address,
            'nid': nid,
            'email': _currentUserEmail ?? '', // Email của người dùng đang đăng nhập
          },
        ),
      ),
    );
  }

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
      // Thêm AppBar để có nút back và tiêu đề rõ ràng
      appBar: AppBar(
        title: Text('Đăng ký Cửa hàng (Bước 1)', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 1,
        // Không cần nút back tự động vì đây là màn hình đầu tiên của flow này
        // Nếu muốn cho phép hủy, có thể thêm nút Cancel ở actions
        // actions: [ TextButton(onPressed: ()=> Navigator.pop(context), child: Text('Hủy')) ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0), // Tăng padding
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Tiêu đề ---
                    Icon(Icons.storefront_outlined, size: 60, color: Colors.blue[700]), // Thêm icon
                    const SizedBox(height: 16),
                    Text(
                      'Thông tin Doanh nghiệp',
                      style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cung cấp thông tin cơ bản về cửa hàng của bạn.',
                      style: GoogleFonts.lato(color: Colors.grey.shade700, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // --- Các trường Input (Không có Email/Password) ---
                    _buildInputField(Icons.business_center_outlined, 'Tên công ty / cửa hàng *', controller: _companyNameController, isRequired: true),
                    _buildInputField(Icons.confirmation_number_outlined, 'Số ĐKKD (Nếu có)', controller: _companyNumberController),
                    _buildInputField(Icons.location_city_outlined, 'Địa chỉ kinh doanh *', controller: _addressController, isRequired: true),
                    _buildInputField(Icons.badge_outlined, 'Số CCCD/CMND chủ sở hữu *', controller: _nidController, isRequired: true, keyboardType: TextInputType.number),

                    const SizedBox(height: 32), // Tăng khoảng cách
                    // --- Nút NEXT ---
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: _goToStep2, // Gọi hàm chuyển sang Bước 2
                        child: Row( // Thêm Icon cho nút
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TIẾP THEO',
                              style: GoogleFonts.lato(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Bỏ link đăng nhập vì người dùng đã đăng nhập rồi
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper để tạo TextFormField (Cải tiến UI)
  Widget _buildInputField(
      IconData icon,
      String label, {
        required TextEditingController controller,
        bool isRequired = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue[700], size: 20),
          labelText: label, // Dùng labelText
          labelStyle: GoogleFonts.lato(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.white,
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
          return null; // Hợp lệ
        },
      ),
    );
  }
}

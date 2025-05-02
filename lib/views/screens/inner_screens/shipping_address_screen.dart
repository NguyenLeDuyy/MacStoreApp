import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Xóa dòng này
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Xóa dòng này

  // Lấy Supabase client
  final supabase = Supabase.instance.client;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Sử dụng TextEditingController thay vì late String để quản lý dữ liệu form tốt hơn
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();

  bool _isLoading = false; // Biến trạng thái loading cho nút

  // Hàm để lấy địa chỉ hiện tại (nếu có) khi màn hình được mở
  @override
  void initState() {
    super.initState();
    _loadCurrentUserAddress();
  }

  Future<void> _loadCurrentUserAddress() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      try {
        final userId = currentUser.id;
        // Truy vấn để lấy địa chỉ hiện tại từ bảng buyers
        // Đảm bảo các tên cột 'city', 'state', 'locality' và 'uid' khớp với bảng Supabase của bạn
        final response =
            await supabase
                .from('buyers')
                .select('city, state, locality') // Chọn các cột cần lấy
                .eq(
                  'uid',
                  userId,
                ) // Lọc theo 'uid' (dựa trên giả định từ lỗi trước)
                .maybeSingle(); // Dùng maybeSingle để không lỗi nếu chưa có dữ liệu

        if (response != null && mounted) {
          // Kiểm tra widget còn tồn tại không
          setState(() {
            _cityController.text = response['city'] ?? '';
            _stateController.text = response['state'] ?? '';
            _localityController.text = response['locality'] ?? '';
          });
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi tải địa chỉ: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ controller khi widget bị hủy
    _cityController.dispose();
    _stateController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    // Kiểm tra form có hợp lệ không
    if (_formKey.currentState!.validate()) {
      // Lấy người dùng hiện tại từ Supabase Auth
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập để thực hiện việc này'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      }); // Bắt đầu loading

      try {
        final userId = currentUser.id;
        // Thực hiện cập nhật dữ liệu vào bảng 'buyers'
        // Đảm bảo tên cột 'city', 'state', 'locality' và 'uid' khớp với DB
        await supabase
            .from('buyers')
            .update({
              'city':
                  _cityController.text
                      .trim(), // Lấy giá trị từ controller và loại bỏ khoảng trắng thừa
              'state': _stateController.text.trim(),
              'locality': _localityController.text.trim(),
            })
            .eq(
              'uid',
              userId,
            ); // Điều kiện cập nhật: chỉ cập nhật dòng có 'uid' khớp

        if (mounted) {
          // Kiểm tra widget còn tồn tại trước khi hiển thị SnackBar hoặc điều hướng
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật địa chỉ thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Quay lại màn hình trước đó sau khi lưu
        }
      } catch (error) {
        if (mounted) {
          print('Lỗi khi cập nhật địa chỉ: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật địa chỉ: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          }); // Dừng loading dù thành công hay lỗi
        }
      }
    } else {
      // Hiển thị thông báo nếu form không hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.96),
        foregroundColor: Colors.black87, // Đảm bảo icon back màu đen dễ thấy
        title: Text(
          'Địa chỉ giao hàng',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87, // Màu tiêu đề rõ ràng
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0), // Thêm padding xung quanh
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Căn trái các label
              children: [
                Text(
                  'Vui lòng nhập thông tin địa chỉ:', // Sửa lại câu chữ
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black54,
                  ), // Giảm kích thước chữ
                ),
                const SizedBox(height: 25),

                // --- Trường nhập Tỉnh/Thành phố ---
                TextFormField(

                  enableSuggestions: false,
                  autocorrect: false,
                  controller: _cityController, // Sử dụng controller
                  // onChanged: (value){ city = value; }, // Không cần onChanged nữa
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      // Kiểm tra chặt chẽ hơn
                      return "Vui lòng nhập Tỉnh/Thành phố";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Tỉnh/Thành phố',
                    hintText: 'Ví dụ: TP. Hồ Chí Minh', // Thêm gợi ý
                    border: OutlineInputBorder(
                      // Thêm viền cho đẹp
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ), // Padding bên trong
                  ),
                  textInputAction:
                      TextInputAction.next, // Chuyển sang trường tiếp theo
                ),
                const SizedBox(height: 20), // Giảm khoảng cách
                // --- Trường nhập Quận/Huyện ---
                TextFormField(
                  controller: _stateController, // Sử dụng controller
                  // onChanged: (value){ state = value; },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập Quận/Huyện";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Quận/Huyện',
                    hintText: 'Ví dụ: Quận 1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // --- Trường nhập Phường/Xã ---
                TextFormField(
                  controller: _localityController, // Sử dụng controller
                  // onChanged: (value){ locality = value; },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập Phường/Xã";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Phường/Xã',
                    hintText: 'Ví dụ: Phường Bến Nghé',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.done, // Hoàn thành nhập liệu
                  onFieldSubmitted:
                      (_) => _saveAddress(), // Lưu khi nhấn done trên bàn phím
                ),
              ],
            ),
          ),
        ),
      ),

      // --- Thanh BottomNavigationBar ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // Tăng padding
        child: ElevatedButton(
          // Sử dụng ElevatedButton thay vì InkWell + Container
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isLoading
                    ? Colors.grey
                    : Color(0xFF1532E7), // Màu nút (disable khi loading)
            foregroundColor: Colors.white,
            minimumSize: Size(
              double.infinity,
              50,
            ), // Chiếm hết chiều rộng, chiều cao 50
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bo góc
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed:
              _isLoading
                  ? null
                  : _saveAddress, // Gọi hàm _saveAddress, disable khi loading
          child:
              _isLoading
                  ? const SizedBox(
                    // Hiển thị loading indicator nhỏ hơn
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : const Text('Lưu địa chỉ'), // Đổi chữ nút
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, //user must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cập nhật địa chỉ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Vui lòng đợi...'),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 3), (){
      Navigator.of(context).pop();
    });
  }
}

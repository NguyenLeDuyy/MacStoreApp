import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/provider/cart_provider.dart';
import 'package:mac_store_app/views/screens/inner_screens/shipping_address_screen.dart';
import 'package:mac_store_app/views/screens/main_screen.dart';
// import 'package:uuid/uuid.dart'; // Không cần uuid nếu Supabase tự tạo ID đơn hàng
import 'package:supabase_flutter/supabase_flutter.dart'; // Đã import Supabase

class checkoutScreen extends ConsumerStatefulWidget {
  const checkoutScreen({super.key});

  @override
  _checkoutScreenState createState() => _checkoutScreenState();
}

class _checkoutScreenState extends ConsumerState<checkoutScreen> {
  String _selectedPaymentMethod = 'stripe';
  bool _isLoading = false; // Trạng thái loading cho nút Đặt Hàng
  bool _isAddressLoading = true; // Trạng thái loading cho việc tải địa chỉ

  // Lấy Supabase client
  final supabase = Supabase.instance.client;

  // Các biến lưu trữ địa chỉ người dùng
  String _fullName = ''; // Thêm biến lưu tên
  String _state = '';
  String _city = '';
  String _locality = '';
  String _email = ''; // Thêm biến lưu email

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy dữ liệu người dùng từ Supabase khi màn hình khởi tạo
    _loadUserDataFromSupabase();
  }

  // Hàm lấy thông tin người dùng (bao gồm địa chỉ) từ Supabase
  Future<void> _loadUserDataFromSupabase() async {
    setState(() { _isAddressLoading = true; }); // Bắt đầu loading địa chỉ
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      try {
        final userId = currentUser.id;
        // Lấy thông tin từ bảng 'buyers' bằng Supabase
        // Đảm bảo tên cột 'fullName', 'email', 'state', 'city', 'locality', 'uid' khớp với DB
        final response = await supabase
            .from('buyers')
            .select('fullName, email, state, city, locality') // Lấy các cột cần thiết
            .eq('uid', userId) // Lọc theo 'uid' (như đã xác định trước đó)
            .maybeSingle(); // Dùng maybeSingle để tránh lỗi nếu chưa có dữ liệu

        if (response != null && mounted) {
          setState(() {
            _fullName = response['fullName'] ?? '';
            _email = response['email'] ?? '';
            _state = response['state'] ?? '';
            _city = response['city'] ?? '';
            _locality = response['locality'] ?? '';
          });
        }
      } catch (error) {
        if (mounted) {
          print('Lỗi khi tải thông tin người dùng: $error');
          // Có thể hiển thị SnackBar lỗi nếu muốn
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Lỗi khi tải thông tin địa chỉ: $error')),
          // );
        }
      } finally {
        if (mounted) {
          setState(() { _isAddressLoading = false; }); // Kết thúc loading địa chỉ
        }
      }
    } else {
      if (mounted) {
        setState(() { _isAddressLoading = false; }); // Kết thúc loading nếu không có user
      }
    }
  }

  // Hàm build phần hiển thị địa chỉ
  Widget _buildAddressSection(BuildContext context) {
    if (_isAddressLoading) {
      return Container( // Hiển thị loading indicator nhỏ gọn
        width: double.infinity,
        height: 74,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFEFF0F2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3,))),
      );
    }

    bool hasAddress = _state.isNotEmpty || _city.isNotEmpty || _locality.isNotEmpty;

    return InkWell(
      onTap: () async {
        // Điều hướng đến màn hình chỉnh sửa/thêm địa chỉ
        // Chờ kết quả trả về (có thể là true nếu địa chỉ được cập nhật)
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const ShippingAddressScreen(),
          ),
        );
        // Nếu có kết quả trả về (ví dụ: sau khi lưu thành công bên ShippingAddressScreen),
        // thì tải lại dữ liệu địa chỉ
        if (result == true && mounted) {
          _loadUserDataFromSupabase();
        } else if (mounted) {
          // Tải lại ngay cả khi không có kết quả trả về rõ ràng, phòng trường hợp pop thông thường
          _loadUserDataFromSupabase();
        }
      },
      child: Container( // Sử dụng Container thay vì SizedBox + Stack phức tạp
        width: double.infinity, // Chiếm hết chiều rộng
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFEFF0F2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row( // Dùng Row để sắp xếp icon, text và nút edit
          children: [
            // Icon địa chỉ
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFBF7F5),
                shape: BoxShape.circle, // Bo tròn icon nền
              ),
              child: Icon(Icons.location_on_outlined, color: Color(0xFF1532E7), size: 22), // Thay icon network bằng icon Flutter
            ),
            const SizedBox(width: 12),
            // Phần text địa chỉ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAddress ? 'Địa chỉ giao hàng' : 'Thêm địa chỉ giao hàng', // Thay đổi tiêu đề
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hasAddress
                        ? '$_locality, $_state, $_city' // Hiển thị địa chỉ đã lấy được
                        : 'Nhấn để thêm thông tin giao hàng', // Thông báo nếu chưa có
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.normal, // Đổi fontWeight
                      height: 1.3,
                      color: Color(0xFF7F808C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Icon Edit
            Icon(Icons.edit_outlined, color: Color(0xFF7F808C), size: 20), // Icon edit rõ ràng hơn
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cartProviderData = ref.watch(cartProvier);
    final cartNotifier = ref.read(cartProvier.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán'),
        elevation: 1, // Thêm elevation nhẹ
        backgroundColor: Colors.white, // Đồng bộ màu nền
        foregroundColor: Colors.black87, // Màu chữ/icon trên AppBar
      ),
      backgroundColor: Colors.grey.shade50, // Màu nền nhẹ cho body

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), // Giảm padding ngang một chút
        // Sử dụng ListView thay vì Column để tránh lỗi tràn nếu nội dung quá dài
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start, // Bỏ đi khi dùng ListView
          children: [
            // --- Phần hiển thị địa chỉ ---
            _buildAddressSection(context), // Gọi hàm build địa chỉ

            const SizedBox(height: 20), // Tăng khoảng cách
            const Text(
              'Sản phẩm của bạn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87), // Tăng nhẹ fontSize
            ),
            const SizedBox(height: 10), // Thêm khoảng cách

            // --- Danh sách sản phẩm ---
            // Sử dụng ListView.separated để có đường kẻ phân cách
            ListView.separated(
              itemCount: cartProviderData.length,
              shrinkWrap: true, // Cần thiết khi ListView trong ListView/Column
              physics: NeverScrollableScrollPhysics(), // Tắt scroll của ListView con
              separatorBuilder: (context, index) => const SizedBox(height: 10), // Khoảng cách giữa các item
              itemBuilder: (context, index) {
                final cartItem = cartProviderData.values.toList()[index];

                // --- Card Item được thiết kế lại (giống cart_screen) ---
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200) // Viền nhẹ hơn
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row( // Dùng Row thay vì Stack
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect( // Bo góc ảnh
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          cartItem.imageUrl[0],
                          height: 70, // Giảm kích thước ảnh
                          width: 70,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CupertinoActivityIndicator()),
                          errorBuilder: (context, error, stack) => Icon(Icons.image_not_supported, size: 70),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItem.productName,
                              style: GoogleFonts.lato(
                                fontSize: 15, // Kích thước chữ vừa phải
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cartItem.categoryName,
                              style: GoogleFonts.lato(
                                fontSize: 13, // Chữ nhỏ hơn
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text( // Hiển thị cả số lượng và giá
                              '${cartItem.quantity} x \$${cartItem.productPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1532E7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Có thể thêm tổng tiền cho item này nếu muốn
                      // Text(
                      //   '\$${(cartItem.quantity * cartItem.productPrice).toStringAsFixed(2)}',
                      //   style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
                      // )
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20), // Tăng khoảng cách

            const Text(
              'Chọn Phương Thức Thanh Toán',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
            ),
            const SizedBox(height: 5),

            // --- Radio Button cho phương thức thanh toán ---
            // Bọc trong Card/Container để có nền trắng
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)
              ),
              margin: const EdgeInsets.symmetric(vertical: 5), // Thêm margin
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.symmetric(horizontal: 8), // Giảm padding
                activeColor: Color(0xFF1532E7), // Màu khi được chọn
                title: const Text('Thanh toán trực tuyến (Stripe)'),
                value: 'stripe',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() { _selectedPaymentMethod = value!; });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)
              ),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                activeColor: Color(0xFF1532E7),
                title: const Text('Thanh toán khi nhận hàng (COD)'),
                value: 'cashOnDelivery',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() { _selectedPaymentMethod = value!; });
                },
              ),

            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // --- Thanh BottomSheet ---
      // Kiểm tra xem đã có địa chỉ chưa (_state không rỗng) trước khi hiển thị nút Đặt Hàng
      bottomSheet: _isAddressLoading || _state.isEmpty // Nếu đang load hoặc chưa có địa chỉ
          ? Container( // Hiển thị thông báo yêu cầu thêm địa chỉ
        height: 60,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Center(
          child: TextButton.icon(
            icon: Icon(Icons.add_location_alt_outlined, color: Color(0xFF1532E7)),
            label: Text(
              _isAddressLoading ? 'Đang tải địa chỉ...' : 'Vui lòng thêm địa chỉ giao hàng',
              style: TextStyle(color: Color(0xFF1532E7), fontWeight: FontWeight.bold),
            ),
            onPressed: _isAddressLoading ? null : () { // Chỉ cho phép nhấn khi không loading
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShippingAddressScreen()),
              ).then((_) => _loadUserDataFromSupabase()); // Tải lại địa chỉ sau khi quay về
            },
          ),
        ),
      )
          : Padding( // Nếu đã có địa chỉ, hiển thị nút Đặt Hàng
        padding: const EdgeInsets.all(12.0), // Tăng padding
        child: ElevatedButton( // Dùng ElevatedButton
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLoading ? Colors.grey : Color(0xFF1532E7),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _isLoading || _state.isEmpty // Disable nếu đang loading hoặc chưa có địa chỉ
              ? null
              : () async { // Logic đặt hàng giữ nguyên (đã dùng Supabase)
            setState(() { _isLoading = true; });
            final currentUser = supabase.auth.currentUser;
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bạn cần đăng nhập!')),
              );
              setState(() { _isLoading = false; });
              return;
            }

            if (_selectedPaymentMethod == 'stripe') {
              print('Thanh toán bằng Stripe - Chưa được triển khai');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng thanh toán Stripe chưa có.')),
              );
              setState(() { _isLoading = false; });
            } else {
              // Xử lý đơn hàng Cash on Delivery với Supabase
              try {
                final userId = currentUser.id;
                // Không cần lấy lại thông tin user ở đây vì đã lấy ở initState và lưu vào biến state
                // final userDataResponse = await supabase...

                List<Map<String, dynamic>> ordersToInsert = [];
                print(cartNotifier.getCartItem.values);
                for (var item in cartNotifier.getCartItem.values) {
                  print('Item details: ${item.toString()}');
// Kiểm tra và in ra dữ liệu của item
                  print('Product ID: ${item.productId}');
                  print('Product Name: ${item.productName}');
                  print('Product Size: ${item.productSize}');
                  print('Quantity: ${item.quantity}');
                  print('Product Price: ${item.productPrice}');
                  print('Category Name: ${item.categoryName}');
                  print('Product Image: ${item.imageUrl[0]}');
                  print('State: $_state');
                  print('City: $_city');
                  print('Locality: $_locality');
                  print('Email: $_email');
                  print('Full Name: $_fullName');
                  print('Buyer ID: $userId');
                  print('Seller_id: ${item.seller_id}');

                  ordersToInsert.add({
                    'productId': item.productId,
                    'productName': item.productName,
                    'size': item.productSize,
                    'quantity': item.quantity,
                    'price': item.quantity * item.productPrice,
                    'category': item.categoryName,
                    'productImage': item.imageUrl[0],
                    // Lấy thông tin địa chỉ từ biến state đã lấy được
                    'state': _state,
                    'city': _city, // Thêm city nếu có trong bảng orders
                    'locality': _locality,
                    'email': _email, // Lấy email từ biến state
                    'fullName': _fullName, // Lấy tên từ biến state
                    'buyerId': userId,
                    'seller_id': item.seller_id,



                  });
                }

                if (ordersToInsert.isNotEmpty) {
                  await supabase.from('orders').insert(ordersToInsert);
                  cartNotifier.clearCartData(); // Đảm bảo tên hàm này đúng trong provider
                  if(mounted){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đặt hàng thành công!'), backgroundColor: Colors.green),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                          (Route<dynamic> route) => false, // Về màn hình chính và xóa stack
                    );
                  }
                } else {
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Giỏ hàng trống!')),
                    );
                  }
                }
              } catch (error) {
                if(mounted){
                  print('Lỗi khi đặt hàng: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xảy ra lỗi khi đặt hàng: $error'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                if(mounted){
                  setState(() { _isLoading = false; });
                }
              }

            }
          },

          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
              : const Text('ĐẶT HÀNG'),
        ),
      ),
    );
  }
}
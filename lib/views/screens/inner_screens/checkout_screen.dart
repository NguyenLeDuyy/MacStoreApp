import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/provider/cart_provider.dart';
import 'package:mac_store_app/views/screens/main_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class checkoutScreen extends ConsumerStatefulWidget {
  const checkoutScreen({super.key});

  @override
  _checkoutScreenState createState() => _checkoutScreenState();
}

class _checkoutScreenState extends ConsumerState<checkoutScreen> {
  String _selectedPaymentMethod = 'stripe';
  bool _isLoading = false; // Thêm biến trạng thái loading

  // Lấy Supabase client
  final supabase =
      Supabase.instance.client; // Cách truy cập Supabase client đã khởi tạo
  @override
  Widget build(BuildContext context) {
    final cartProviderData = ref.watch(
      cartProvier,
    ); // Dùng watch để tự cập nhật UI nếu giỏ hàng thay đổi
    final cartNotifier = ref.read(
      cartProvier.notifier,
    ); // Lấy notifier để thao tác với giỏ hàng

    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {},
                child: SizedBox(
                  width: 335,
                  height: 74,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 335,
                          height: 74,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xFFEFF0F2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 70,
                        top: 17,
                        child: SizedBox(
                          width: 215,
                          height: 41,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -1,
                                left: -1,
                                child: SizedBox(
                                  width: 219,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Thêm địa chỉ',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 5),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Điền thành phố',
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                            color: Color(0xFF7F808C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 16,
                        top: 16,
                        child: SizedBox.square(
                          dimension: 42,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 43,
                                  height: 43,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFBF7F5),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      Positioned(
                                        left: 11,
                                        top: 11,
                                        child: Image.network(
                                          "https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F2ee3a5ce3b02828d0e2806584a6baa88.png",
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 305,
                        top: 25,
                        child: Image.network(
                          "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F6ce18a0efc6e889de2f2878027c689c9caa53feeedit%201.png?alt=media&token=a3a8a999-80d5-4a2e-a9b7-a43a7fa8789a",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              const Text(
                'Sản phẩm của bạn',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              Flexible(
                child: ListView.builder(
                  itemCount: cartProviderData.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context, index) {
                    final cartItem = cartProviderData.values.toList()[index];

                    return InkWell(
                      onTap: () {},
                      child: Container(
                        width: 336,
                        height: 91,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Color(0xFFdcdbdc)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 6,
                              top: 6,
                              child: SizedBox(
                                width: 331,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 78,
                                      height: 78,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFBCC5FF),
                                      ),
                                      child: Image.network(
                                        cartItem.imageUrl[0],
                                      ),
                                    ),

                                    const SizedBox(width: 11),

                                    Expanded(
                                      child: Container(
                                        height: 78,
                                        alignment: const Alignment(0, -0.51),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  cartItem.productName,
                                                  style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 4),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  cartItem.categoryName,
                                                  style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16),
                                    Text(
                                      cartItem.discount.toStringAsFixed(2),
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        height: 1.3,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Chọn Phương Thức Thanh Toán',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              RadioListTile<String>(
                title: const Text('Thanh toán trực tuyến'),
                value: 'stripe',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),

              RadioListTile<String>(
                title: const Text('Thanh toán khi nhận hàng'),
                value: 'cashOnDelivery',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      bottomSheet: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap:
              _isLoading
                  ? null
                  : () async {
                    // Vô hiệu hóa nút khi đang xử lý
                    setState(() {
                      _isLoading = true;
                    }); // Bắt đầu loading

                    // Kiểm tra người dùng đã đăng nhập chưa
                    final currentUser = supabase.auth.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn cần đăng nhập để đặt hàng!'),
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      }); // Dừng loading
                      // Có thể điều hướng người dùng đến trang đăng nhập ở đây
                      return;
                    }

                    if (_selectedPaymentMethod == 'stripe') {
                      /// TODO: Triển khai thanh toán với Stripe
                      /// Phần này cần tích hợp SDK Stripe riêng, không liên quan trực tiếp đến Supabase DB
                      print('Thanh toán bằng Stripe - Chưa được triển khai');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chức năng thanh toán Stripe chưa có.'),
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      }); // Dừng loading
                    } else {
                      // Xử lý đơn hàng Cash on Delivery với Supabase
                      try {
                        // 1. Lấy thông tin người mua từ bảng 'buyers'
                        //    Chúng ta cần thông tin này để điền vào đơn hàng
                        final userId = currentUser.id;
                        final userDataResponse =
                            await supabase
                                .from('buyers')
                                .select(
                                  'email, fullName, state, locality',
                                ) // Chỉ lấy các cột cần thiết
                                .eq(
                                  'uid',
                                  userId,
                                ) // Lọc theo ID người dùng hiện tại
                                .single(); // Mong đợi chỉ 1 kết quả (hoặc lỗi nếu không tìm thấy/tìm thấy nhiều)

                        // userDataResponse bây giờ là một Map<String, dynamic> chứa thông tin buyer
                        // Ví dụ: {'email': 'user@example.com', 'fullName': 'Nguyen Van A', ...}

                        // 2. Chuẩn bị danh sách các đơn hàng cần thêm vào bảng 'orders'
                        List<Map<String, dynamic>> ordersToInsert = [];
                        // final orderIdBase = const Uuid().v4(); // Có thể tạo một UUID gốc nếu muốn nhóm đơn hàng, nhưng thường mỗi item là 1 bản ghi riêng

                        for (var item in cartNotifier.getCartItem.values) {
                          // final orderId = const Uuid().v4(); // Supabase sẽ tự tạo orderId nếu cột được cấu hình DEFAULT gen_random_uuid()

                          ordersToInsert.add({
                            // 'orderId': orderId, // Không cần nếu Supabase tự tạo
                            'productId': item.productId,
                            'productName': item.productName,
                            'size':
                                item.productSize, // Đảm bảo tên cột khớp với DB ('size')
                            'quantity':
                                item.quantity, // Đảm bảo tên cột khớp với DB ('quantity')
                            'price':
                                item.quantity *
                                item.productPrice, // Tổng giá chưa discount cho item này
                            'category': item.categoryName,
                            'productImage': item.imageUrl[0],
                            // Lấy thông tin địa chỉ từ user data đã lấy được
                            'state': userDataResponse['state'],
                            'email': userDataResponse['email'],
                            'locality': userDataResponse['locality'],
                            'fullName': userDataResponse['fullName'],
                            'buyerId':
                                userId, // ID của người dùng đang đăng nhập
                            // 'delivered': false, // Đã có giá trị DEFAULT trong DB
                            // 'processing': true, // Đã có giá trị DEFAULT trong DB
                            'deliveriedCount': 0, // Không dùng cột này nữa
                          });
                        }

                        // 3. Insert tất cả các đơn hàng vào bảng 'orders' trong một lần gọi
                        if (ordersToInsert.isNotEmpty) {
                          await supabase.from('orders').insert(ordersToInsert);

                          // 4. (Quan trọng) Xóa giỏ hàng sau khi đặt hàng thành công
                          cartNotifier
                              .clearCartData(); // Gọi hàm xóa giỏ hàng từ provider của bạn

                          // 5. Thông báo thành công và/hoặc điều hướng
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đặt hàng thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Optional: Điều hướng về trang chủ hoặc trang lịch sử đơn hàng
                          // Navigator.of(context).popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MainScreen();
                              },
                            ),
                          ); // Quay lại màn hình trước đó
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Giỏ hàng trống!')),
                          );
                        }
                      } catch (error) {
                        // 6. Xử lý lỗi nếu có
                        print('Lỗi khi đặt hàng: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã xảy ra lỗi khi đặt hàng: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        }); // Dừng loading dù thành công hay lỗi
                      }
                    }
                  },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width - 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  _isLoading
                      ? Colors.grey
                      : Color(0xFF1532E7), // Màu xám khi loading
            ),
            child: Center(
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                      ) // Hiển thị loading indicator
                      : const Text(
                        'ĐẶT HÀNG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          height: 1.4, // Có thể không cần thiết
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

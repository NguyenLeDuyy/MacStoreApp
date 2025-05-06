import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Cần cho ảnh
import 'package:intl/intl.dart'; // Cần cho format số/tiền
import 'package:mac_store_app/views/screens/nav_screens/business_signup_step1.dart'; // Import màn hình đăng ký
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
// Import PostgrestException để bắt lỗi cụ thể (tùy chọn)
// import 'package:postgrest/postgrest.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  // Khởi tạo Supabase client
  final SupabaseClient supabase = Supabase.instance.client;

  // Các biến trạng thái
  bool _isLoading = true; // Trạng thái loading ban đầu
  bool _hasAccount = false; // Người dùng đã có tài khoản business chưa?

  // Dữ liệu của cửa hàng
  String _companyName = '';
  String _profileImageUrl = '';

  // Các số liệu thống kê
  int _totalOrders = 0;
  int _totalReviews = 0;
  int _pendingOrders = 0;

  @override
  void initState() {
    super.initState();
    // Gọi hàm load dữ liệu khi màn hình được khởi tạo
    _loadBusinessData();
  }

  // --- HÀM LOAD DỮ LIỆU (ĐÃ SỬA LỖI COUNT) ---
  Future<void> _loadBusinessData() async {
    // Kiểm tra widget còn tồn tại không
    if (!mounted) return;
    // Bắt đầu trạng thái loading
    setState(() => _isLoading = true);

    // Lấy thông tin người dùng hiện tại
    final user = supabase.auth.currentUser;
    if (user == null) {
      // Nếu chưa đăng nhập, dừng loading và không làm gì thêm
      print("StoreProfile: User not logged in.");
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Lấy thông tin tài khoản doanh nghiệp từ bảng 'business_accounts'
      final businessRes = await supabase
          .from('business_accounts') // <-- Tên bảng tài khoản doanh nghiệp
          .select('company_name, profile_picture_url') // Các cột cần lấy
          .eq('user_id', user.id) // Lọc theo user_id của người dùng hiện tại
          .maybeSingle(); // Lấy một bản ghi hoặc null

      // Nếu tìm thấy tài khoản doanh nghiệp
      if (businessRes != null) {
        _hasAccount = true; // Đánh dấu là đã có tài khoản
        // Lấy dữ liệu, xử lý null
        _companyName = businessRes['company_name'] ?? 'Tên cửa hàng';
        _profileImageUrl = businessRes['profile_picture_url'] ?? '';

        // --- SỬA LỖI LẤY COUNT ---
        // 2. Lấy tổng số đơn hàng
        // *** QUAN TRỌNG: Thay 'seller_id' bằng tên cột đúng trong bảng 'orders'
        //     dùng để liên kết với người bán (user.id) ***
        final orderCountResponse = await supabase
            .from('orders')
            .select() // Không cần select cột cụ thể khi chỉ lấy count
            .eq('buyerId', user.id) // <-- THAY THẾ CỘT LIÊN KẾT ĐÚNG
            .count(CountOption.exact); // <-- Lấy count chính xác
        _totalOrders = orderCountResponse as int; // Gán trực tiếp kết quả count

        // Lấy số đơn hàng đang chờ xử lý (chưa giao)
        final pendingResponse = await supabase
            .from('orders')
            .select()
            .eq('buyerId', user.id) // <-- THAY THẾ CỘT LIÊN KẾT ĐÚNG
            .eq('delivered', false) // Lọc đơn chưa giao
            .count(CountOption.exact);
        _pendingOrders = pendingResponse as int;

        // 3. Lấy tổng số đánh giá
        // *** QUAN TRỌNG: Thay 'seller_id' bằng tên cột đúng trong bảng 'reviews'
        //     dùng để liên kết với người bán (user.id) ***
        final reviewsResponse = await supabase
            .from('reviews')
            .select()
            .eq('seller_id', user.id) // <-- THAY THẾ CỘT LIÊN KẾT ĐÚNG
            .count(CountOption.exact);
        _totalReviews = reviewsResponse as int;
        // --------------------------

      } else {
        // Không tìm thấy tài khoản doanh nghiệp
        _hasAccount = false;
      }
    } catch (e) {
      // Xử lý lỗi chung khi load dữ liệu
      debugPrint('Lỗi khi tải dữ liệu hồ sơ cửa hàng: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải dữ liệu: $e'), backgroundColor: Colors.red)
        );
        _hasAccount = false; // Đặt là false nếu có lỗi
      }
    } finally {
      // Luôn kết thúc loading sau khi xử lý xong
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // -------------------------------------

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading indicator khi đang tải dữ liệu
    if (_isLoading) {
      return const Scaffold(
        appBar: _StoreAppBarPlaceholder(), // AppBar tạm thời để giữ layout
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Nếu chưa có tài khoản doanh nghiệp, hiển thị nút đăng ký
    if (!_hasAccount) {
      return Scaffold(
        appBar: AppBar(title: const Text("Cửa hàng của bạn")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                Text(
                  "Bạn chưa đăng ký cửa hàng",
                  style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Hãy tạo cửa hàng của riêng bạn để bắt đầu bán hàng ngay!",
                  style: GoogleFonts.lato(fontSize: 15, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text("Đăng ký cửa hàng ngay"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // Điều hướng đến màn hình đăng ký Bước 1
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const SignUpAndCreateBusiness1()
                    )).then((value) {
                      // Sau khi quay lại từ flow đăng ký (dù thành công hay không),
                      // gọi lại _loadBusinessData để cập nhật trạng thái
                      print("Quay lại từ màn hình đăng ký, đang tải lại dữ liệu...");
                      _loadBusinessData();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- Giao diện khi đã có tài khoản doanh nghiệp ---
    // Tính toán số dư (ví dụ, bạn cần thay bằng logic thực tế)
    final balance = _totalOrders * 10000.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Không cần AppBar ở đây vì Header đã có nền
      body: RefreshIndicator( // Cho phép kéo xuống để tải lại
        onRefresh: _loadBusinessData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Luôn cho phép cuộn
          child: Column(
            children: [
              // Header với dữ liệu đã load
              _buildHeader(context, _companyName, balance, _profileImageUrl),
              const SizedBox(height: 30),
              // Nút Upload và Tóm tắt đơn hàng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần Upload
                    Text("Quản lý Sản phẩm", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text("Tải Sản phẩm lên", style: GoogleFonts.lato(color: Colors.white)),
                        onPressed: () {
                          // TODO: Implement upload product navigation/logic
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chức năng tải sản phẩm chưa được triển khai.")));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Phần Tóm tắt
                    Text("Tóm tắt Đơn hàng", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryCard(context: context, count: _totalOrders, label: "Tổng đơn hàng", icon: Icons.shopping_bag_outlined, color: Colors.orange),
                        _buildSummaryCard(context: context, count: _totalReviews, label: "Tổng đánh giá", icon: Icons.star_border_outlined, color: Colors.amber),
                        _buildSummaryCard(context: context, count: _pendingOrders, label: "Chờ xử lý", icon: Icons.pending_actions_outlined, color: Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // Khoảng cách dưới cùng
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Helper cho Header ---
  Widget _buildHeader(BuildContext context, String name, double balance, String imageUrl) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox( // Dùng SizedBox để giới hạn chiều cao chính xác
      height: screenHeight * 0.35, // Chiều cao khoảng 35% màn hình
      child: Stack(
        alignment: Alignment.center, // Căn giữa các phần tử trong Stack
        clipBehavior: Clip.none, // Cho phép ảnh đại diện tràn ra ngoài
        children: [
          // Nền xanh cong
          Positioned.fill( // Chiếm hết không gian Stack
            bottom: 50, // Để lại khoảng trống 50px ở dưới cho ảnh
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[800]!, Colors.lightBlue[500]!], // Màu gradient khác
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.elliptical(150, 50)), // Tăng độ cong
                  boxShadow: [ // Thêm đổ bóng cho nền
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
              ),
            ),
          ),
          // Vòng tròn trang trí (tùy chọn)
          // ...

          // Nội dung chính (Ảnh, Tên, Số dư)
          Positioned(
            bottom: 0, // Đặt ở dưới cùng của SizedBox
            child: Column(
              children: [
                // Ảnh đại diện với viền trắng
                CircleAvatar(
                  radius: 55, // Bán kính viền ngoài
                  backgroundColor: Colors.white, // Màu viền
                  child: CircleAvatar(
                    radius: 50, // Bán kính ảnh
                    backgroundColor: Colors.grey[200], // Màu nền placeholder
                    child: ClipOval( // Đảm bảo ảnh được cắt tròn
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: 100, // Kích thước ảnh
                        height: 100,
                        placeholder: (context, url) => const CupertinoActivityIndicator(), // Loading kiểu iOS
                        errorWidget: (context, url, error) => const Icon(Icons.storefront, size: 50, color: Colors.grey), // Icon placeholder
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Tăng khoảng cách
                // Tên cửa hàng
                Text(
                  name,
                  style: GoogleFonts.lato(
                      fontSize: 22, // Tăng cỡ chữ
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.4), offset: const Offset(1,1))]
                  ),
                ),
                const SizedBox(height: 6),
                // Số dư
                Text(
                  "Số dư của bạn",
                  style: GoogleFonts.lato(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 4),
                Text(
                  // Format số dư
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(balance),
                  style: GoogleFonts.lato(
                      fontSize: 26, // Tăng cỡ chữ số dư
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.4), offset: const Offset(1,1))]
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Helper cho mỗi ô Tóm tắt đơn hàng ---
  Widget _buildSummaryCard({
    required BuildContext context, // Thêm context
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded( // Để các card chia sẻ không gian
      child: Card(
        elevation: 2, // Giảm độ nổi chút
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bo góc nhiều hơn
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0), // Tăng padding dọc
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar( // Icon trong hình tròn
                radius: 20,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                NumberFormat.decimalPattern('vi_VN').format(count), // Format số
                style: GoogleFonts.lato(
                  fontSize: 18, // Giảm cỡ chữ số
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 11, // Giảm cỡ chữ label
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500, // Đậm hơn chút
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget AppBar tạm thời khi đang loading
class _StoreAppBarPlaceholder extends StatelessWidget implements PreferredSizeWidget {
  const _StoreAppBarPlaceholder();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Cửa hàng của bạn"),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

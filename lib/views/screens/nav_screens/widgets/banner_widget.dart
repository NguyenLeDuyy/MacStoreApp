import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Thêm import Supabase

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final SupabaseClient _supabase =
      Supabase.instance.client; // Khởi tạo Supabase client

  List<String> _bannerImageUrls = []; // Danh sách lưu URL ảnh banner

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy banner khi widget được khởi tạo
    getBanners();
  }

  // Hàm lấy banner từ Supabase
  Future<void> getBanners() async {
    try {
      // Truy vấn bảng 'banners' và chỉ lấy cột 'image_url'
      // Bạn có thể thêm .order('order_column') nếu có cột thứ tự
      final response = await _supabase
          .from('banners') // Tên bảng Supabase của bạn
          .select('image'); // Tên cột chứa URL ảnh banner

      // response bây giờ là List<Map<String, dynamic>>
      final List<dynamic> data = response as List<dynamic>;

      // Tạo list tạm để chứa URL
      final List<String> tempUrls = [];
      for (var row in data) {
        // Kiểm tra kiểu dữ liệu và null safety
        if (row is Map<String, dynamic> && row['image'] != null) {
          tempUrls.add(row['image'] as String);
        }
      }

      // Cập nhật state chỉ một lần sau khi xử lý xong
      if (mounted) {
        // Luôn kiểm tra mounted trước khi gọi setState sau await
        setState(() {
          _bannerImageUrls = tempUrls;
        });
      }
      print('Banner URLs fetched: $_bannerImageUrls');
    } catch (e) {
      print('Lỗi không xác định khi lấy banners: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lấy danh sách banner: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phần UI của bạn sẽ sử dụng list _bannerImageUrls để hiển thị banner
    // Ví dụ dùng PageView:
    return _bannerImageUrls.isEmpty
        ? Center(
          child: CircularProgressIndicator(),
        ) // Hiển thị loading nếu chưa có dữ liệu
        : Container(
          height: 170, // Chiều cao của banner
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 10,
              offset: Offset(0, 2),
            )],
          ),
          child: PageView.builder(
            itemCount: _bannerImageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _bannerImageUrls[index],
                    fit: BoxFit.cover,
                    // Thêm loadingBuilder và errorBuilder để trải nghiệm tốt hơn
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Lỗi tải ảnh banner: $error');
                      return Container(
                        color: Colors.grey,
                        child: Icon(Icons.error),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
  }
}

import 'package:flutter/material.dart';
import 'package:mac_store_app/controllers/banner_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Thêm import Supabase

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {

  final SupabaseClient _supabase =
      Supabase.instance.client; // Khởi tạo Supabase client

  final BannerController _bannerController = BannerController();

  @override
  Widget build(BuildContext context) {
    // Lấy controller đã được đăng ký bằng GetX
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 170,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          // ... styles của bạn
        ),
        child: StreamBuilder<List<String>>(
          stream: _bannerController.getBannerUrls(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Hiển thị loading khi đang chờ dữ liệu đầu tiên
              return Center(child: CircularProgressIndicator(color: Colors.blue));
            } else if (snapshot.hasError) {
              print('Lỗi StreamBuilder: ${snapshot.error}'); // Thêm log lỗi
              return Center(child: Icon(Icons.error, color: Colors.red)); // Hiển thị lỗi rõ hơn
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Dữ liệu trống hoặc không có dữ liệu sau khi chờ
              return Center(
                child: Text(
                  'No Banners available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            } else {
              // Có dữ liệu, hiển thị PageView
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      // Thêm kiểm tra lỗi network image nếu cần
                    return Image.network(
                      snapshot.data![index],
                      fit: BoxFit.cover, // Thêm fit để ảnh đẹp hơn
                      );
                    },
                  ),
                  _buildPageIndicator(snapshot.data!.length)
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index){
          return Container(
            width: 8.0, height: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

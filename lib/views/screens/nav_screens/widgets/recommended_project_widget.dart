import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/product_item.dart'; // Đảm bảo đường dẫn này đúng
import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendedProjectWidget extends StatefulWidget {
  const RecommendedProjectWidget({super.key});

  @override
  State<RecommendedProjectWidget> createState() => _RecommendedProjectWidgetState();
}

class _RecommendedProjectWidgetState extends State<RecommendedProjectWidget> {
  late final Stream<List<Map<String, dynamic>>> _productsStream;

  @override
  void initState() {
    super.initState();

    // --- !!! THAY THẾ CÁC GIÁ TRỊ SAU BẰNG TÊN THỰC TẾ TRONG SUPABASE CỦA BẠN !!! ---
   // const String createdAtColumnInProductsTable = 'created_at'; // Tên cột ngày tạo trong bảng 'products' (Nếu có và dùng để sắp xếp)
    // --- KẾT THÚC PHẦN THAY THẾ ---

    // Câu truy vấn Supabase để lấy sản phẩm và tên danh mục liên quan
    _productsStream = Supabase.instance.client
        .from('products')
        .select('*, categories(category_name)')
        .order('rating', ascending: false)
    // --- THAY ĐỔI Ở ĐÂY ---
        .asStream() // GỌI asStream() MÀ KHÔNG CẦN primaryKey
    // --- KẾT THÚC THAY ĐỔI ---
        .handleError((error, stackTrace) {
      print('>>> LỖI TRONG STREAM SUPABASE (RecommendedProjectWidget): $error');
      print('>>> STACK TRACE STREAM: $stackTrace');
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _productsStream, // Sử dụng stream đã khởi tạo
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {

        // 1. Xử lý trạng thái lỗi
        if (snapshot.hasError) {
          print('>>> LỖI TRONG STREAMBUILDER (RecommendedProjectWidget): ${snapshot.error}');
          print('>>> STACK TRACE BUILDER: ${snapshot.stackTrace}');
          // Hiển thị thông báo lỗi thân thiện hơn cho người dùng
          return const Center(
            child: Text(
              'Đã có lỗi xảy ra khi tải sản phẩm.\nVui lòng thử lại sau.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        // 2. Xử lý trạng thái đang chờ dữ liệu
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị indicator loading trong khi chờ dữ liệu đầu tiên
          return const Center(child: CircularProgressIndicator());
        }

        // 3. Xử lý trường hợp không có dữ liệu hoặc danh sách rỗng
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Hiện chưa có sản phẩm nào.'));
        }

        // 4. Dữ liệu đã sẵn sàng, tiến hành xây dựng danh sách
        final products = snapshot.data!; // products là List<Map<String, dynamic>>

        // Sử dụng SizedBox để giới hạn chiều cao của ListView ngang
        return SizedBox(
          height: 250, // Điều chỉnh chiều cao nếu cần
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Thêm padding ngang
            scrollDirection: Axis.horizontal, // Danh sách cuộn ngang
            itemCount: products.length,       // Số lượng sản phẩm
            itemBuilder: (context, index) {
              final productData = products[index]; // Lấy dữ liệu của sản phẩm tại vị trí index

              // Truyền dữ liệu sản phẩm vào ProductItemWidget để hiển thị
              return Padding(
                padding: const EdgeInsets.only(right: 12.0), // Thêm khoảng cách giữa các item
                child: ProductItemWidget(
                  productData: productData,

                ),
              );
            },
          ),
        );
      },
    );
  }

}

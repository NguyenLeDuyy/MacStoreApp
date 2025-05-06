import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/product_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PopularProductsScreen extends StatelessWidget {
  const PopularProductsScreen({Key? key}) : super(key: key);

  // Hàm lấy categoryName từ bảng categories theo categoryId
  Future<String> getCategoryName(int categoryId) async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select('category_name')
          .eq('id', categoryId)
          .maybeSingle();

      if (response != null && response['category_name'] != null) {
        return response['category_name'] as String;
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy category name: $e');
    }

    return 'Không rõ';
  }

  @override
  Widget build(BuildContext context) {
    final productStream = Supabase.instance.client
        .from('products_with_order_count')
        .stream(primaryKey: ['productId'])
        .order('totalorders', ascending: false);


    // Khoảng cách bạn muốn
    const double gridPadding = 16;
    const double gridSpacing = 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sản phẩm phổ biến",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: productStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Có lỗi, thử lại sau."));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(
              child: Text(
                "Không có sản phẩm nào.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(
              products.map((product) async {
                final categoryId = product['category'] as int;
                final categoryName = await getCategoryName(categoryId);
                return {
                  ...product,
                  'categoryName': categoryName,  // Thêm categoryName vào dữ liệu sản phẩm
                };
              }).toList(),
            ),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (futureSnapshot.hasError) {
                return const Center(child: Text("Lỗi khi lấy danh mục"));
              }

              final updatedProducts = futureSnapshot.data ?? [];

              return GridView.builder(
                padding: const EdgeInsets.all(gridPadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,               // 2 cột
                  crossAxisSpacing: gridSpacing,   // spacing ngang giữa các ô
                  mainAxisSpacing: gridSpacing,    // spacing dọc giữa các ô
                  childAspectRatio: 146 / 245,     // tỉ lệ khung con của ProductItemWidget
                ),
                itemCount: updatedProducts.length,
                itemBuilder: (context, index) {
                  final productData = updatedProducts[index];
                  //print(productData);

                  return ProductItemWidget(
                    productData: productData, // Truyền dữ liệu sản phẩm đã được cập nhật với categoryName
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

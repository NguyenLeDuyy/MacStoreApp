import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/popularItem.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

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
    final Stream<List<Map<String, dynamic>>> productStream = Supabase.instance.client
        .from('products')
        .stream(primaryKey: ['id']);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đề xuất cho bạn",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: productStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi. Vui lòng thử lại.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(
                'Không có sản phẩm nào.\nHãy kiểm tra lại sau!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.7),
              ),
            );
          }

          return GridView.count(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 300 / 500,
            children: List.generate(data.length, (index) {
              final productData = data[index];
              final categoryId = productData['category'];

              // Sử dụng FutureBuilder để lấy category name cho từng sản phẩm
              return FutureBuilder<String>(
                future: getCategoryName(categoryId),
                builder: (context, categorySnapshot) {
                  if (!categorySnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final productWithCategory = {
                    ...productData,
                    'categoryName': categorySnapshot.data!,
                  };

                  return PopularItem(productData: productWithCategory);
                },
              );
            }),
          );
        },
      ),
    );
  }
}

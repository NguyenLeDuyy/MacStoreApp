import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/models/category_models.dart';
import 'package:mac_store_app/views/screens/inner_screens/product_detail_screen.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/popularItem.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryProductScreen extends StatelessWidget {
  final CategoryModel categoryModel;

  const CategoryProductScreen({super.key, required this.categoryModel});

  @override
  Widget build(BuildContext context) {

    Future<Map<int, String>> fetchCategories() async {
      final response = await Supabase.instance.client
          .from('categories')
          .select('id, category_name');

      Map<int, String> categoryMap = {};
      for (var category in response) {
        categoryMap[category['id']] = category['category_name']; // Lưu id → tên danh mục
      }

      return categoryMap;
    }
    final Stream<List<Map<String, dynamic>>> _productStream = Supabase.instance.client
        .from('products')
        .stream(primaryKey: ['productId']);

    _productStream.listen((data) async {
      final categoryMap = await fetchCategories();

      // Chuyển đổi `categoryId` sang `categoryName`
      List<Map<String, dynamic>> updatedData = data.map((product) {
        product['categoryName'] = categoryMap[product['category']];
        return product;
      }).toList();

      // Lọc sản phẩm theo `categoryModel.category_name`
      List<Map<String, dynamic>> productData = updatedData
          .where((product) => product['categoryName'] == categoryModel.category_name)
          .toList();

      print(productData); // Danh sách sản phẩm sau khi lọc
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryModel.category_name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productStream,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Product under this category\nCheck back later',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.7,
                ),
              ),
            );
          }

          // Fetch danh mục để ánh xạ categoryId -> categoryName
          return FutureBuilder<Map<int, String>>(
            future: fetchCategories(), // Hàm lấy danh sách danh mục
            builder: (context, categorySnapshot) {
              if (categorySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (categorySnapshot.hasError || categorySnapshot.data == null) {
                return const Center(child: Text('Failed to load categories'));
              }

              Map<int, String> categoryMap = categorySnapshot.data!;

              // Chuyển đổi categoryId -> categoryName
              List<Map<String, dynamic>> productData = snapshot.data!
                  .map((product) {
                product['categoryName'] = categoryMap[product['category']];
                return product;
              })
                  .where((product) => product['categoryName'] == categoryModel.category_name) // Lọc đúng danh mục
                  .toList();

              if (productData.isEmpty) {
                return const Center(
                  child: Text(
                    'No Product under this category\nCheck back later',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.7,
                    ),
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
                children: List.generate(productData.length, (index) {
                  print("In ra kết quả");
                  print(productData);
                  return PopularItem(productData: productData[index]);
                }),
              );
            },
          );
        },
      ),
    );
  }
}

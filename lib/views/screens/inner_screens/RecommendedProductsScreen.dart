import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/popularItem.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> _productStream = Supabase.instance.client
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
        stream: _productStream,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi. Vui lòng thử lại.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
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
            children: List.generate(snapshot.data!.length, (index) {
              final productData = snapshot.data![index];
              return PopularItem(productData: productData);
            }),
          );
        },
      ),
    );
  }
}
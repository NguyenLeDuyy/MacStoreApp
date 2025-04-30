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

    final Stream<List<Map<String, dynamic>>> _productStream = Supabase.instance.client
        .from('product_with_category')
        .stream(primaryKey: ['id'])
        .eq('category', categoryModel.category_name);


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
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty){
            return const Center(
              child: Text('No Product under this category\ncheck back later',
                textAlign: TextAlign.center,
                style:TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.7
              ),),
            );
          }

          return GridView.count(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 300/500,
            children: List.generate(snapshot.data!.length, (index){
              final productData = snapshot.data![index];
              return PopularItem(productData: productData);
          }),
          );

        },
      ),
    );
  }
}

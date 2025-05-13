import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo stream từ Supabase
    final Stream<List<Map<String, dynamic>>> _categoriesStream =
    Supabase.instance.client
        .from('categories')
        .stream(primaryKey: ['id'])
        .order('created_at');


    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _categoriesStream,
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No categories found");
        }

        final categories = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final categoryData = categories[index];
            final imageUrl = categoryData['category_image'];
            final categoryName = categoryData['category_name'];

            return Column(
              children: [
                imageUrl != null
                    ? Image.network(
                  imageUrl,
                  height: 100,
                  width: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error),
                )
                    : Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey,
                  child: Icon(Icons.image),
                ),
                Text(categoryName ?? 'No name'),
              ],
            );
          },
        );
      },
    );


  }
}
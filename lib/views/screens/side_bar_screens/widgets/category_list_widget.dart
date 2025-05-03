import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo stream từ Supabase
    final Stream<List<Map<String, dynamic>>> _categoriesStream =
    Supabase.instance.client.from('categories').stream(primaryKey: ['id']);

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
          return Text("No users found");
        }

        return GridView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8 ),
            itemBuilder: (context, index){
              final categoryData = snapshot.data![index];              return Column(
                children: [
                  Image.network(
                    categoryData['categoryImage'],
                    height: 100,
                    width:100,
                  ),
                  
                  Text(categoryData['categoryName'],)

                ],
              );
            }
        );


        // return ListView(
        //   children: snapshot.data!.map((data) {
        //     return ListTile(
        //       title: Text(data['full_name'] ?? 'Unknown'),
        //       subtitle: Text(data['company'] ?? 'No company'),
        //     );
        //   }).toList(),
        // );
      },
    );
  }
}
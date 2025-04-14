import 'package:get/get.dart';
import 'package:mac_store_app/models/category_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _fetchCategories();
  }

  void _fetchCategories() {
    _supabase
        .from('categories')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      categories.assignAll(data.map((doc) {
        return CategoryModel(
          category_name: doc['category_name'],
          category_image: doc['category_image'],
        );
      }).toList());
    });
  }
}

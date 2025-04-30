
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/controllers/category_controller.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({super.key});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem>{
final CategoryController _categoryController = Get.find<CategoryController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categoryController.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(


                  mainAxisSpacing: 4,
                  crossAxisSpacing: 8,
                  crossAxisCount: 4), itemBuilder: (context, index){
                  return InkWell(
                    onTap: (){},
                    child: Column(
                      children: [
                        Image.network(
                          _categoryController.categories[index].category_image,
                          width: 47,
                          height: 47,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          _categoryController.categories[index].category_name,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
              })
        ],
      );
    });
  }
}


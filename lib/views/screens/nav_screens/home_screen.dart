import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/banner_widget.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/category_item.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/header_widget.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/recommended_project_widget.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/reuseable_text_widget.dart';

import '../inner_screens/RecommendedProductsScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: SingleChildScrollView(
            child: Column(
              children:
              [
                HeaderWidget(),
                BannerWidget(),
                CategoryItem(),
                ReuseableTextWidget(
                  title: 'Đề xuất cho bạn',
                  subTitle: 'Xem tất cả',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RecommendedProductsScreen()),
                    );
                  },
                ),

                RecommendedProjectWidget(),
                ReuseableTextWidget(title: 'Sản phẩm phổ biến', subTitle: 'Xem tất cả'),

              ],
            )

        ));
  }
}



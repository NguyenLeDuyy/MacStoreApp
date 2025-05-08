import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screens/account_screen.dart';
import 'package:mac_store_app/views/screens/nav_screens/cart_screen.dart';
import 'package:mac_store_app/views/screens/nav_screens/favorite_screen.dart';
import 'package:mac_store_app/views/screens/nav_screens/home_screen.dart';
import 'package:mac_store_app/views/screens/nav_screens/business_signup_step1.dart';

import 'nav_screens/store_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;
  final  List<Widget> _pages = [
    HomeScreen(),
    FavoriteScreen(),
    // SignUpAndCreateBusiness1(),
    StoreProfileScreen(),
    CartScreen(),
    AccountScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Cửa hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),

      body: _pages[_pageIndex],
    );
  }
}

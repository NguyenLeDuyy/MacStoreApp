import 'package:app_web/views/screens/authentication_screens/forgot_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:app_web/views/screens/side_bar_screens/category_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/buyers_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/vendors_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/orders_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/upload_banner.screen.dart';
import 'package:app_web/views/screens/side_bar_screens/products_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/register_account.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main-screen';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selectedRoute = MainScreen.id;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Management Dashboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      sideBar: SideBar(
        header: Container(
          height: 50,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: const Center(
            child: Text(
                'Mult Vendor Admin',
              style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,letterSpacing:1.7,
              ),
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: Colors.black,
          child: Center(
            child: const Text(
              'Footer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,

              ),
            ),
          ),
        ),
        items: const [
          AdminMenuItem(
            title: 'Vendors',
            route: VendorsScreen.id,
            icon: CupertinoIcons.person_3,
          ),
          AdminMenuItem(
            title: 'Buyers',
            route: BuyersScreen.id,
            icon: CupertinoIcons.person,
          ),
          AdminMenuItem(
            title: 'Orders',
            route: OrdersScreen.id,
            icon: CupertinoIcons.shopping_cart,
          ),
          AdminMenuItem(
            title: 'Categories',
            route: CategoryScreen.id,
            icon: Icons.category,
          ),
          AdminMenuItem(
            title: 'Upload Banner',
            route: UploadBanner.id,
            icon: Icons.upload,
          ),
          AdminMenuItem(
            title: 'Products',
            route: ProductsScreen.id,
            icon: Icons.store,
          ),

          AdminMenuItem(
            title: 'Register Admin',
            route: RegisterScreenAdmin.id,
            icon: Icons.mode_edit,
          ),
        ],
        selectedRoute: _selectedRoute,
        onSelected: (item) {
          if (item.route != null) {
            setState(() {
              _selectedRoute = item.route!;
            });
          }
        },
      ),
      body: _buildBody(_selectedRoute),
    );
  }

  // Hàm hiển thị màn hình theo route đã chọn
  Widget _buildBody(String route) {
    switch (route) {
      case VendorsScreen.id:
        return const VendorsScreen();
      case BuyersScreen.id:
        return const BuyersScreen();
      case OrdersScreen.id:
        return const OrdersScreen();
      case CategoryScreen.id:
        return const CategoryScreen();
      case UploadBanner.id:
        return const UploadBanner();
      case ProductsScreen.id:
        return const ProductsScreen();
      case RegisterScreenAdmin.id:
        return const RegisterScreenAdmin();
      default:
        return const Center(child: Text('Dashboard'));
    }
  }
}

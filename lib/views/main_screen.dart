import 'package:app_web/views/screens/authentication_screens/forgot_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:app_web/views/screens/side_bar_screens/category_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/buyers_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/vendors_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/orders_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/upload_banner.screen.dart';
import 'package:app_web/views/screens/side_bar_screens/products_screen.dart';
import 'package:app_web/views/screens/side_bar_screens/register_account.dart';
import 'package:app_web/views/screens/authentication_screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main-screen';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selectedRoute = MainScreen.id;
  final SupabaseClient supabase = Supabase.instance.client;
  OverlayEntry ? overlayEntry;

  Future<void> _getUserProfile(BuildContext context) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('User not logged in');
      return;
    }

    final response = await supabase
        .from('admin')
        .select('email, fullName, profileImage')
        .eq('admin_id', userId)
        .maybeSingle(); // Tránh lỗi nếu không có dữ liệu


    if (response != null && response.isNotEmpty) {
      _showProfileOverlay(context, response['fullName'] ?? 'Unknown', response['email'] ?? '', response['profileImage'] ?? '');
    } else {
      print('Không tìm thấy thông tin người dùng');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Management Dashboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {

            },

          ),

          IconButton(
            icon: const Icon(Icons.help, color: Colors.white),
            onPressed: () async {
            },
          ),

          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              _getUserProfile(context);
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
                  // // Xử lý đăng xuất
              _showLogoutDialog(context);
            },
          ),

        ],
      ),

      // Sidebar
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreenAdmin()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showProfileOverlay(BuildContext context, String username, String email, String profileImage) {
      overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque, // Đảm bảo nhận diện nhấn ngoài vùng hộp thoại
            onTap: () {
              overlayEntry?.remove(); // Kiểm tra null trước khi xoá
            },
          ),
          Positioned(
            top: 43,
            right: 45,
            child: Material(
              elevation: 10,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    const SizedBox(height: 12),
                    Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        overlayEntry?.remove();
                      },
                      child: const Text('Chỉnh sửa hồ sơ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(overlayEntry!);
    });
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

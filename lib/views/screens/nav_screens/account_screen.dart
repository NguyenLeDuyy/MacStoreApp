import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mac_store_app/views/screens/inner_screens/order_screen.dart';

import '../inner_screens/user_profile.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final UserProfile _profileService = UserProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileService.fetchBuyerProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text("Không thể tải thông tin người dùng"));
          }

          final userData = snapshot.data!;
          final name = userData['fullName'] ?? 'Chưa có tên';
          final avatarUrl = userData['profileImage'];
          final location = userData['city'] ?? 'Chưa xác định';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Phần thông tin người dùng
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF102DE1),

                  ),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [

                      const SizedBox(height: 50),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: avatarUrl != null && avatarUrl.isNotEmpty
                              ? Image.network(
                            avatarUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/images/profile.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(location, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ///
                          /// Thống kê mấy cái này chưa đc
                          ///
                          _StatCard(icon: Icons.shopping_cart,
                              count: 22,
                              label: "Cart"),
                          _StatCard(icon: Icons.favorite, count: 192, label: "Favorite"),
                          _StatCard(icon: Icons.check_circle, count: 162, label: "Completed"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _MenuTile(
                  icon: Icons.local_shipping,
                  title: "Đơn hàng",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderScreen()));
                  },
                ),
                _MenuTile(
                  icon: Icons.logout,
                  title: "Đăng xuất",
                  onTap: () async {
                    _showLogoutDialog(context);

                    // TODO: Redirect to login
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

}


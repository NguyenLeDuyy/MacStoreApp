import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessDashboardScreen extends StatelessWidget {
  final String avatarUrl;
  final String userName;
  final double balance;
  final int totalOrders;
  final int totalReviews;
  final int pendingOrders;

  const BusinessDashboardScreen({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.balance,
    required this.totalOrders,
    required this.totalReviews,
    required this.pendingOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ----- Header dạng cong -----
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar tròn
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  const SizedBox(height: 12),
                  // Tên chủ shop
                  Text(
                    userName,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Nhãn "Số dư"
                  Text(
                    'Số dư hiện có',
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Giá trị số dư
                  Text(
                    '\$${balance.toStringAsFixed(1)}',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ----- Nút Upload Products -----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: điều hướng sang màn upload sản phẩm
              },
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Đăng sản phẩm',
                style: GoogleFonts.lato(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ----- Tiêu đề Thống kê -----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thống kê đơn hàng',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ----- 3 Thẻ thông số -----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard(
                  label: 'Tổng đơn',
                  value: totalOrders.toString(),
                ),
                _StatCard(
                  label: 'Tổng đánh giá',
                  value: totalReviews.toString(),
                ),
                _StatCard(
                  label: 'Đang chờ',
                  value: pendingOrders.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget helper cho các card thống kê
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

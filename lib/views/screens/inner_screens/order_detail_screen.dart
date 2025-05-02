import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {

  final dynamic orderData;

  const OrderDetailScreen({super.key, required this.orderData});

  Map<String, dynamic> _getStatusInfo() {
    if (orderData['delivered'] == true) {
      return {'text': 'Đã giao hàng', 'color': Colors.green.shade700};
    } else if (orderData['processing'] == true) {
      return {'text': 'Đang xử lý', 'color': Colors.orange.shade700};
    } else {
      return {'text': 'Đã hủy', 'color': Colors.red.shade700};
    }
  }

  @override
  Widget build(BuildContext context) {

    final statusInfo = _getStatusInfo();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final displayPrice = currencyFormat.format(orderData['price'] ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Thông tin sản phẩm
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          orderData['productImage'] ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) => progress == null
                              ? child
                              : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade100,
                              child: Icon(Icons.broken_image, color: Colors.grey.shade400)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderData['productName'] ?? 'Không rõ tên',
                              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              orderData['category'] ?? 'Không rõ danh mục',
                              style: GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Số lượng: ${orderData['quantity'] ?? 1} - Size: ${orderData['size'] ?? 'N/A'}',
                              style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayPrice,
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        statusInfo['text'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      backgroundColor: statusInfo['color'],
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Thông tin giao hàng
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin giao hàng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person_outline, 'Người nhận:', orderData['fullName'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Địa chỉ:',
                    '${orderData['locality'] ?? ''}, ${orderData['state'] ?? ''}, ${orderData['city'] ?? ''}',
                  ),
                  const SizedBox(height: 16),

                  // Nút đánh giá
                  if (orderData['delivered'] == true)
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('Viết đánh giá'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng đánh giá chưa được triển khai')),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị thông tin hàng ngang có icon
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Giữ lại nếu đây là font chuẩn của app bạn
// import 'package:intl/intl.dart'; // Có thể cần nếu bạn muốn format ngày tháng, giá tiền

class OrderDetailScreen extends StatelessWidget {
  final dynamic orderData; // Nên định nghĩa một class OrderModel thay vì dynamic

  const OrderDetailScreen({super.key, required this.orderData});

  // Helper function để lấy màu và text cho trạng thái đơn hàng
  Map<String, dynamic> _getStatusInfo() {
    if (orderData['delivered'] == true) {
      return {'text': 'Đã giao hàng', 'color': Colors.green.shade700};
    } else if (orderData['processing'] == true) {
      return {'text': 'Đang xử lý', 'color': Colors.purple.shade700};
    } else {
      // Giả sử có một trạng thái 'cancelled' hoặc mặc định là đã hủy
      return {'text': 'Đã hủy', 'color': Colors.red.shade700};
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    // Định dạng giá tiền (ví dụ)
    // final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    // final formattedPrice = currencyFormat.format(orderData['price'] ?? 0);
    // Hoặc đơn giản là thêm dấu $ hoặc đ
    final displayPrice = '\$${(orderData['price'] ?? 0).toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        // --- Thêm nút Back vào đây ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icon mũi tên quay lại
          onPressed: () {
            Navigator.of(context).pop(); // Hành động quay lại màn hình trước
          },
          tooltip: 'Quay lại', // Thêm tooltip cho rõ nghĩa
        ),
        // --- Kết thúc phần thêm nút Back ---
        title: const Text( // Text cố định cho dễ hiểu
          'Chi tiết đơn hàng',
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87, // Áp dụng cho cả title và nút leading (nếu không bị override màu)
      ),
      backgroundColor: Colors.grey.shade100, // Màu nền nhẹ cho body
      body: ListView( // Sử dụng ListView để nội dung dài có thể cuộn
        padding: const EdgeInsets.all(16.0), // Padding chung cho toàn bộ màn hình
        children: [
          // --- Card Thông tin sản phẩm ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero, // Bỏ margin mặc định của Card
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hình ảnh sản phẩm
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          orderData['productImage'] ?? '', // Xử lý null
                          width: 80, // Kích thước hợp lý
                          height: 80,
                          fit: BoxFit.cover,
                          // Thêm loading và error builder
                          loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2))),
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade100,
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey.shade400)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thông tin chi tiết (Tên, Loại, Giá)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderData['productName'] ?? 'N/A', // Xử lý null
                              style: GoogleFonts.lato( // Giữ font nếu là chuẩn
                                // style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Hoặc dùng Theme
                                fontSize: 18,
                                fontWeight: FontWeight.w600, // Hoặc bold
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              orderData['category'] ?? 'N/A', // Xử lý null
                              style: GoogleFonts.lato( // Giữ font nếu là chuẩn
                                // style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600), // Hoặc dùng Theme
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayPrice, // Hiển thị giá đã format
                              style: GoogleFonts.lato( // Giữ font nếu là chuẩn
                                // style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary), // Hoặc dùng Theme
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary, // Sử dụng màu chủ đạo
                              ),
                            ),
                            // Thêm thông tin khác nếu cần (ví dụ: số lượng)
                            // if (orderData['quantity'] != null) ...[
                            //   const SizedBox(height: 4),
                            //   Text(
                            //     'Số lượng: ${orderData['quantity']}',
                            //     style: Theme.of(context).textTheme.bodyMedium,
                            //   ),
                            // ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Khoảng cách trước status
                  // --- Trạng thái đơn hàng ---
                  Align( // Căn phải hoặc trái tùy ý
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        statusInfo['text'],
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      backgroundColor: statusInfo['color'],
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      labelPadding: EdgeInsets.zero, // Bỏ padding mặc định của label chip
                      visualDensity: VisualDensity(horizontal: 0.0, vertical: -4), // Làm chip nhỏ gọn hơn
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16), // Khoảng cách giữa các Card

          // --- Card Thông tin giao hàng ---
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Dùng TextTheme
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person_outline, 'Người nhận:', orderData['fullName'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on_outlined,'Địa chỉ:', '${orderData['locality'] ?? ''}, ${orderData['state'] ?? ''}, ${orderData['city'] ?? ''}'), // Ghép địa chỉ đầy đủ, xử lý null
                  // _buildInfoRow(Icons.location_city_outlined, 'Phường/Xã:', orderData['locality'] ?? 'N/A'),
                  // const SizedBox(height: 8),
                  // _buildInfoRow(Icons.map_outlined, 'Quận/Huyện:', orderData['state'] ?? 'N/A'),
                  // const SizedBox(height: 8),
                  // _buildInfoRow(Icons.business_outlined, 'Tỉnh/Thành phố:', orderData['city'] ?? 'N/A'), // Thêm city nếu có

                  // --- Nút Đánh giá ---
                  if (orderData['delivered'] == true) ...[ // Chỉ hiển thị nếu đã giao hàng
                    const SizedBox(height: 16),
                    Center( // Đưa nút vào giữa
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.rate_review_outlined, size: 18),
                        label: Text('Viết đánh giá'),
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: Theme.of(context).colorScheme.secondary, // Có thể dùng màu phụ
                          // foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                        ),
                        onPressed: () {
                          // TODO: Xử lý điều hướng hoặc hiển thị dialog đánh giá
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chức năng đánh giá chưa được triển khai')),
                          );
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget để hiển thị một dòng thông tin (icon, label, value)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        // Text('$label ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4), // Dễ đọc hơn
          ),
        ),
      ],
    );
  }
}
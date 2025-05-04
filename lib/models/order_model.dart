import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Nếu bạn muốn thêm getter format ngày/tiền

class OrderModel {
  final String orderId; // Khóa chính (giả sử là 'orderId' hoặc 'id' tùy DB của bạn)
  final String productId;
  final String productName;
  final String category;
  final String productImage;
  final int quantity;
  final double price; // Tổng giá cho số lượng sản phẩm này trong đơn hàng
  final String? size; // Có thể null
  final String buyerId;
  final String fullName;
  final String email;
  final String state;
  final String city;
  final String locality;
  final bool processing;
  final bool delivered;
  final DateTime createdAt; // Ngày tạo đơn hàng

  OrderModel({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.category,
    required this.productImage,
    required this.quantity,
    required this.price,
    this.size,
    required this.buyerId,
    required this.fullName,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.processing,
    required this.delivered,
    required this.createdAt,
  });

  // Factory constructor để tạo OrderModel từ Map lấy về từ Supabase
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    // Cần đảm bảo tên key trong map ('orderId', 'productId',...) khớp với tên cột trong DB Supabase
    return OrderModel(
      // Sử dụng key đúng với cột khóa chính của bạn ('id' hoặc 'orderId')
      orderId: map['orderId'] ?? map['id'] ?? 'N/A',
      productId: map['productId'] ?? 'N/A',
      productName: map['productName'] ?? 'N/A',
      category: map['category'] ?? 'N/A',
      productImage: map['productImage'] ?? '', // Cung cấp giá trị mặc định nếu null
      quantity: (map['quantity'] ?? 0).toInt(), // Chuyển đổi an toàn sang int
      price: (map['price'] ?? 0.0).toDouble(), // Chuyển đổi an toàn sang double
      size: map['size'], // size có thể null
      buyerId: map['buyerId'] ?? '',
      fullName: map['fullName'] ?? 'N/A',
      email: map['email'] ?? 'N/A',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      locality: map['locality'] ?? '',
      processing: map['processing'] ?? false, // Giá trị mặc định nếu null
      delivered: map['delivered'] ?? false, // Giá trị mặc định nếu null
      // Parse ngày tháng từ chuỗi ISO 8601, cung cấp giá trị mặc định nếu null hoặc lỗi
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // --- Các Getter hữu ích (Tùy chọn) ---

  // Getter để lấy trạng thái dưới dạng text và màu
  Map<String, dynamic> get statusInfo {
    if (delivered == true) {
      return {'text': 'Đã giao hàng', 'color': Colors.green.shade700};
    } else if (processing == true) {
      return {'text': 'Đang xử lý', 'color': Colors.orange.shade700};
    } else {
      // Giả sử nếu không phải delivered hay processing thì là cancelled
      return {'text': 'Đã hủy', 'color': Colors.red.shade700};
    }
  }

  // Getter để lấy địa chỉ đã format
  String get formattedAddress {
    List<String> parts = [locality, state, city];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  // Getter để lấy ngày đặt hàng đã format
  String get formattedCreatedAt {
    try {
      return DateFormat('HH:mm dd/MM/yyyy', 'vi_VN').format(createdAt);
    } catch (e) {
      return 'N/A'; // Trả về N/A nếu có lỗi format
    }
  }

  // Getter để lấy giá đã format
  String get formattedPrice {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return currencyFormat.format(price);
  }
}
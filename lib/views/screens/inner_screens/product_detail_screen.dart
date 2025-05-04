import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/provider/cart_provider.dart';
import 'package:mac_store_app/provider/favorite_provider.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final dynamic productData;

  const ProductDetailScreen({super.key, required this.productData});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProviderData = ref.read(cartProvier.notifier);
    final favoriteProviderData = ref.read(favoriteProvider.notifier);
    ref.watch(favoriteProvider);

    final data = widget.productData;
    final String categoryName = data['categoryName'] ?? data['categories']?['category_name'] ?? 'Không rõ';
    final double rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final int totalReviews = (data['totalReviews'] as num?)?.toInt() ?? 0;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(
            onPressed: () {
              favoriteProviderData.addProductToFavorite(
                productName: data['productName'],
                productId: data['productId'],
                imageUrl: data['productImage'],
                productPrice: data['productPrice'],
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                margin: const EdgeInsets.all(15),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.grey,
                content: Text(data['productName']),
              ));
            },
            icon: favoriteProviderData.getFavoriteItem.containsKey(data['productId'])
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border, color: Colors.red),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Ảnh sản phẩm
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: data['productImage'].length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xffd8ddff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(data['productImage'][index], fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tên + Giá + Rating
          Text(data['productName'],
              style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF3C55EF))),
          const SizedBox(height: 6),

          // Rating
          Row(
            children: [
              RatingBarIndicator(
                rating: rating,
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 18,
              ),
              const SizedBox(width: 8),
              Text('${rating.toStringAsFixed(1)} (${totalReviews > 99 ? "99+" : totalReviews})',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 10),

          // Giá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(currencyFormat.format(data['productPrice']),
                  style: GoogleFonts.roboto(
                      fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3C55EF))),
            ],
          ),

          const SizedBox(height: 16),

          // Kích cỡ
          Text('Kích cỡ:', style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List<Widget>.generate(
              data['productSize'].length,
                  (index) => Chip(label: Text(data['productSize'][index])),
            ),
          ),

          const SizedBox(height: 20),
          // Mô tả
          Text('Về sản phẩm:', style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(data['description'] ?? '-', style: const TextStyle(color: Colors.black87)),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            cartProviderData.addProductToCart(
              productName: data['productName'],
              productPrice: data['productPrice'],
              categoryName: categoryName,
              imageUrl: data['productImage'],
              quantity: 1,
              instock: data['quantity'],
              productId: data['productId'],
              productSize: '',
              discount: data['discount'],
              description: data['description'],
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              margin: const EdgeInsets.all(15),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.grey,
              content: Text(data['productName']),
            ));
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xff3b54ee),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('THÊM VÀO GIỎ HÀNG',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
      ),
    );
  }
}

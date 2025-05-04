import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/views/screens/inner_screens/product_detail_screen.dart';
import 'package:mac_store_app/provider/favorite_provider.dart';
import 'package:mac_store_app/provider/cart_provider.dart';

class ProductItemWidget extends ConsumerWidget {
  final Map<String, dynamic> productData;

  const ProductItemWidget({super.key, required this.productData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy danh sách sản phẩm yêu thích từ provider
    final favoriteItems = ref.watch(favoriteProvider);
    final productId = productData['productId'];
    final isFavorite = favoriteItems.containsKey(productId);

    // Lấy tên sản phẩm từ productData một cách an toàn
    final String productName =
        productData['productName'] as String? ?? 'Sản phẩm không tên';

    // Lấy tên danh mục từ dữ liệu lồng nhau một cách an toàn
    final categoryData = productData['categories'];
    String categoryName = 'Không rõ';

    final double rating        = (productData['rating'] as num?)?.toDouble() ?? 0.0;
    final int   totalReviews  = (productData['totalReviews'] as num?)?.toInt()   ?? 0;

    if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['category_name'] as String? ?? 'N/A';
    }
// Lấy danh sách sản phẩm trong giỏ hàng từ provider
    final cartItems = ref.watch(cartProvier);


// Kiểm tra xem sản phẩm có trong giỏ hàng hay không
    final isInCart = cartItems.containsKey(productId);





    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetailScreen(productData: productData);
        }));
      },
      child: Container(
        width: 146,
        height: 245,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 146,
                height: 245,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0f040828),
                      spreadRadius: 0,
                      offset: Offset(0, 18),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 7,
              top: 130,
              child: Text(
                productName,
                style: GoogleFonts.lato(
                  color: Color(0xFF1E3354),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            Positioned(
              left: 7,
              top: 177,
              child: Text(
                categoryName,
                style: GoogleFonts.lato(
                  color: Color(0xFF7F8E9D),
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            Positioned(
              left: 7,
              top: 207,
              child: Text(
                '\$${productData['discount']}',
                style: GoogleFonts.lato(
                  color: const Color(0xFF1E3354),
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            Positioned(
              left: 51,
              top: 210,
              child: Text(
                "\$${productData['productPrice']}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),

            Positioned(
              left: 9,
              top: 9,
              child: Container(
                width: 128,
                height: 108,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -1,
                      top: -1,
                      child: Container(
                        width: 130,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5C3),
                          border: Border.all(width: 0.8, color: Colors.white),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 14,
                      top: 4,
                      child: Opacity(
                        opacity: 0.5,
                        child: Container(
                          width: 100,
                          height: 100,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF44F),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 10,
                      top: -10,
                      child: CachedNetworkImage(
                        imageUrl: productData['productImage'][0],
                        width: 108,
                        height: 107,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 5,
              top: 155,
              child: Row(
                children: [
                  // 5 ngôi sao nhỏ phản ánh điểm trung bình
                  RatingBarIndicator(
                    rating: rating,
                    itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber, size: 12),
                    itemCount: 5,
                    itemSize: 12,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 4),
                  // Số điểm
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.lato(color: Color(0xFF7F8E9D), fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  // Tổng số reviews
                  Text(
                    '($totalReviews đánh giá)',
                    style: GoogleFonts.roboto(color: Color(0xFF7F8E9D), fontSize: 12),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 104,
              top: 15,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: Color(0xFFFA634D),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33E30D0D),
                      spreadRadius: 0,
                      offset: Offset(0, 7),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              right: 5,
              top: 5,
              child: IconButton(
                onPressed: () {
                  final favoriteNotifier = ref.read(favoriteProvider.notifier);
                  if (isFavorite) {
                    favoriteNotifier.removeItem(productId);
                  } else {
                    favoriteNotifier.addProductToFavorite(
                      productId: productId,
                      productName: productData['productName'],
                      imageUrl: productData['productImage'],
                      productPrice: productData['productPrice'],
                    );
                  }
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size:18,
                ),
              ),
            ),
            Positioned(
              left: 104,
              top: 210,
              child: Container(
                width: 40,
                height: 35,
                decoration: BoxDecoration(
                  color: Color(0xFFFA634D),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),       // Góc trên bên trái
                    bottomRight: Radius.circular(4),   // Góc dưới bên phải
                  ),

                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33E30D0D),
                      spreadRadius: 0,
                      offset: Offset(0, 7),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 104,
              top: 205,
              child: IconButton(
                onPressed: () {
                  final cartNotifier = ref.read(cartProvier.notifier);
                  final productId = (productData['productId'] as num?)?.toInt() ?? 0;

                  // Nếu đã có trong giỏ thì xóa
                  if (cartNotifier.getCartItem.containsKey(productId)) {
                    cartNotifier.removeItem(productId);
                  } else {
                    // Lấy category name an toàn
                    final categoryData = productData['categories'];
                    String categoryName = 'Không rõ';
                    if (categoryData is Map<String, dynamic>) {
                      categoryName = categoryData['category_name'] ?? 'Không rõ';
                    }

                    cartNotifier.addProductToCart(
                      productName: productData['productName'] ?? 'Không tên',
                      productPrice: (productData['productPrice'] as num?)?.toInt() ?? 0,
                      categoryName: categoryName,
                      imageUrl: List<String>.from(productData['productImage'] ?? []),
                      quantity: 1,
                      instock: (productData['quantity'] as num?)?.toInt() ?? 0,
                      productId: productId,
                      productSize: productData['productSize'].toString(),
                      discount: (productData['discount'] as num?)?.toInt() ?? 0,
                      description: productData['description'] ?? 'Không có mô tả',
                    );
                  }
                },

                icon: Icon(
                  isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size:22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

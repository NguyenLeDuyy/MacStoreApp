import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/views/screens/inner_screens/product_detail_screen.dart'; // Sử dụng Google Fonts cho đẹp hơn

class ProductItemWidget extends StatelessWidget {
  // Nhận dữ liệu sản phẩm dưới dạng Map
  final Map<String, dynamic> productData;

  const ProductItemWidget({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    // --- !!! THAY THẾ CÁC GIÁ TRỊ SAU BẰNG TÊN CỘT THỰC TẾ TRONG SUPABASE CỦA BẠN !!! ---
    // --- KẾT THÚC PHẦN THAY THẾ ---

    // Lấy tên sản phẩm từ productData một cách an toàn
    final String productName =
        productData['productName'] as String? ?? 'Sản phẩm không tên';

    // Lấy tên danh mục từ dữ liệu lồng nhau một cách an toàn
    final categoryData =
        productData['categories']; // Lấy Map lồng nhau (hoặc null)
    String categoryName = 'Không rõ'; // Giá trị mặc định

    if (categoryData is Map<String, dynamic>) {
      // Nếu categoryData là Map, lấy giá trị của cột tên danh mục
      categoryName = categoryData['category_name'] as String? ?? 'N/A';
    } else if (categoryData != null) {
      // Ghi log nếu categoryData có giá trị nhưng không phải là Map (trường hợp lạ)
      print(
        'DEBUG (ProductItemWidget): Dữ liệu category không phải Map: $categoryData',
      );
    }
    // Nếu categoryData là null, categoryName sẽ giữ giá trị 'Không rõ'

    // Xây dựng giao diện cho một sản phẩm
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ProductDetailScreen(productData: productData ,);
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
      
            // TODO: Thêm giá tiền hoặc các thông tin khác nếu cần
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
                        imageUrl: productData['productImage'],
                        width: 108,
                        height: 107,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      
            Positioned(
              left: 56,
              top: 155,
              child: Text(
                '500> sold',
                style: GoogleFonts.lato(color: Color(0xFF7F8E9D), fontSize: 12),
              ),
            ),
      
            Positioned(
              left: 23,
              top: 155,
              child: Text(
                "4.5",
                style: GoogleFonts.lato(color: Color(0xFF7F8E9D), fontSize: 12),
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
                child: IconButton(onPressed: (){}, icon: const Icon(Icons.favorite_border, color: Colors.white, size: 16,)),),
            
          ],
        ),
      ),
    );
  }
}

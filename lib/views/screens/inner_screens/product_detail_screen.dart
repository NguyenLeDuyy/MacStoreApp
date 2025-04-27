import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatelessWidget {
  final dynamic productData;

  const ProductDetailScreen({super.key, required this.productData});
  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Detail' ,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(
                    0xFF363330,
                )
              ),
            ),
            IconButton(
                onPressed: (){},
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
            )
          ],
        ),
      ),
     body: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Center(
           child: Container(
             width: 260,
             height: 274,
             clipBehavior: Clip.hardEdge,
             decoration: const BoxDecoration(),

             child:  Stack(
               clipBehavior: Clip.none,
               children: [
                 Positioned(
                     left:0,
                     top:0,
                     child: Container(
                       width:260,
                       height: 260,
                       clipBehavior: Clip.hardEdge,
                       decoration: BoxDecoration(
                         color: const Color(
                            0xffd8ddff,
                         ),

                         borderRadius: BorderRadius.circular(
                           130,
                         ),
                       ),
                     ),
                 ),
                 Positioned(
                   left:22,
                   top: 0,
                   child: Container(
                     width:216,
                     height: 274,
                     clipBehavior: Clip.hardEdge,
                     decoration:  BoxDecoration(
                       color: const Color(
                         0xFF9CA8FF,
                       ),
                       borderRadius: BorderRadius.circular(14,)
                     ),

                     child: SizedBox(
                       height: 300,
                       child: PageView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: productData['productImage'].length,
                           itemBuilder: (context, index){
                             return Image.network(
                               productData['productImage'],
                               width: 198,
                               height: 225,
                               fit: BoxFit.cover,

                             );
                           }),
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                productData['productName'],
                 style: GoogleFonts.roboto(
                   fontSize: 17,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1,
                   color: const Color(
                     0xFF3C55EF,
                   ),
                 ),
                ),
               Text(
                 "\$${productData['productPrice'].toStringAsFixed(2)}",
                 style: GoogleFonts.roboto(
                   fontSize: 17,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1,
                   color: const Color(
                     0xFF3C55EF,
                   ),
                 ),
               ),

             ],
           ),
         ),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Text(
             categoryName,
             style: const TextStyle(
               fontSize: 16,
               fontWeight: FontWeight.bold,
             ),
           ),
         ),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                 'Size:', style:GoogleFonts.lato(
                    color: Color(
                      0xff343434,
                    ),
                    fontSize: 16,
                    letterSpacing: 1.6,
                  ),
               ),

               SizedBox(
                 height: 50,
                 child: ListView.builder(
                   shrinkWrap: true,
                   scrollDirection: Axis.horizontal,
                   itemCount: productData['productSize'].length,
                   itemBuilder: (context, index){
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (){},
                          child: Container(
                            decoration:  BoxDecoration(
                              color: const Color(0xff126881),

                              borderRadius: BorderRadius.circular(5,),
                            ),
                          child: Padding(padding: EdgeInsets.all(8), child:Text(
                            productData['productSize'][index],
                            style: GoogleFonts.lato(
                              color: Colors.white,
                            ),
                          ),),

                          ),
                        ),
                      );
                   },
                 ),
               )
             ],
           ),
         ),

         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('About', style:GoogleFonts.lato(
                 color: Color(0xff363330),
                 fontSize: 16,
                 letterSpacing: 1,
               ),),
               Text(productData['description'],)
             ],
           ),
         )
       ],
     ),
      bottomSheet: Padding(
        padding: EdgeInsets.all(8),
        child: InkWell(
          onTap: (){},
          child: Container(
            width: 386,
            height: 48,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Color(
                0xff3b54ee,
              ),
              borderRadius: BorderRadius.circular(
                24,
              ),
            ),
            child: Center(
              child: Text(
                'ADD TO CART',
                style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),),
            ),
          ),
        ),
      ),
    );
  }
}

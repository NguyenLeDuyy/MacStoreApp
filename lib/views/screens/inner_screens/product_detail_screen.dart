import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/provider/cart_provider.dart';
import 'package:mac_store_app/provider/favorite_provider.dart';

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
// Giá trị mặc định
    String categoryName = 'Không rõ';
// TH1: Nếu có key 'categoryName' (kiểu String - từ map đã xử lý)
    if (widget.productData['categoryName'] is String) {
      categoryName = widget.productData['categoryName'] as String;
    }
// TH2: Nếu có key 'categories' và nó là Map chứa 'category_name'
    else if (widget.productData['categories'] is Map<String, dynamic>) {
      final categoryData = widget.productData['categories'] as Map<String, dynamic>;
      categoryName = categoryData['category_name'] as String? ?? 'N/A';
    }
// TH3: Có key 'categories' nhưng không đúng kiểu
    else if (widget.productData['categories'] != null) {
      print(
        'DEBUG (ProductItemWidget): Dữ liệu category không phải Map: ${widget.productData['categories']}',
      );
    }




    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chi tiết sản phẩm' ,
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
                onPressed: (){
                  favoriteProviderData.addProductToFavorite(
                      productName: widget.productData['productName'],
                      productId: widget.productData['productId'],
                      imageUrl: widget.productData['productImage'],
                      productPrice: widget.productData['productPrice'],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    margin: const EdgeInsets.all(15),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.grey,
                    content: Text(widget.productData['productName']),
                  ));
                },
                icon: favoriteProviderData.getFavoriteItem
                    .containsKey(widget.productData['productId'])
                    ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                )
                : const Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                ),
            ),
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
                           itemCount: widget.productData['productImage'].length,
                           itemBuilder: (context, index){
                             return Image.network(
                               widget.productData['productImage'][index],
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
                widget.productData['productName'],
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
                 "\$${widget.productData['productPrice'].toStringAsFixed(2)}",
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
                 'Kích cỡ:', style:GoogleFonts.roboto(
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
                   itemCount: widget.productData['productSize'].length,
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
                            widget.productData['productSize'][index],
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
               Text('Về sản phẩm:', style:GoogleFonts.roboto(
                 color: Color(0xff363330),
                 fontSize: 16,
                 letterSpacing: 1,
               ),),
               Text(widget.productData['description'],)
             ],
           ),
         )
       ],
     ),
      bottomSheet: Padding(
        padding: EdgeInsets.all(8),
        child: InkWell(
          onTap: (){
            cartProviderData.addProductToCart(
                productName: widget.productData['productName'],
                productPrice: widget.productData['productPrice'],
                categoryName: categoryName,
                imageUrl: widget.productData['productImage'],
                quantity: 1,
                instock: widget.productData['quantity'],
                productId: widget.productData['productId'],
                productSize: '',
                discount: widget.productData['discount'],
                description: widget.productData['description']
            );

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                margin: const EdgeInsets.all(15),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.grey,
                content: Text(widget.productData['productName'])));
          },
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
                'THÊM VÀO GIỎ HÀNG',
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

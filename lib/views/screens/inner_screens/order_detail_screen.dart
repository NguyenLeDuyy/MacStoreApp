import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailScreen extends StatelessWidget {
  final dynamic orderData;

  const OrderDetailScreen({super.key,required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(orderData['productName'],
        ),
      ),

      body: Column(
        children: [
      Padding(
      padding: const  EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 25,
      ),
      child: Container(
        width: 335,
        height: 153,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 336,
                  height: 154,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(
                        0xffeff0f2,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(9,),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left:13,
                        top: 9,
                        child: Container(
                          width: 78,
                          height: 78,
                          clipBehavior: Clip.antiAlias,
                          decoration:  BoxDecoration(
                            color: const Color(
                              0xffbcc5ff,
                            ),
                            borderRadius: BorderRadius.circular(8,),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left:10,
                                top:5,
                                child: Image.network(
                                  orderData['productImage'],
                                  width: 58,
                                  height: 67,
                                  fit: BoxFit.cover,
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 101,
                        top: 14,
                        child: SizedBox(
                          width: 216,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        orderData['productName'],overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.getFont(
                                          'Lato',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4,),

                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(orderData['category'],

                                        style: const TextStyle(
                                          color: Color(
                                            0xff7f808c,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const  SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "\$${orderData['price']}",
                                      style: const TextStyle(
                                        color: Color(
                                          0xff0b0c1e,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 13,
                        top: 113,
                        child: Container(
                          width: 77,
                          height: 25,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: orderData['delivered']== true?Color(0xff3c55ef):orderData['processing']==true?
                            Colors.purple
                                : Colors.red,
                            borderRadius: BorderRadius.circular(4,),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                  left: 9,
                                  top: 3,
                                  child: Text(
                                    orderData['delivered']==true
                                        ?'Delivered':orderData['processing']==
                                        true
                                        ?'Processing'
                                        :'Cancelled',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
          Padding(padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
            child: Container(
              width: 336,
              height: 154,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xffef0f2,),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Địa chỉ giao hàng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        orderData['locality'] + " " +  orderData['state'],
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        orderData['state'],
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

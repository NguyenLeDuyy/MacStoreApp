import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/provider/cart_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:mac_store_app/views/screens/main_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvier);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.20,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 118,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/cartb.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 322,
                top: 52,
                child: Stack(
                  children: [
                    Image.asset('assets/icons/not.png', width: 26, height: 25),

                    Positioned(
                      top: 0,
                      right: 0,
                      child: badges.Badge(
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.yellow.shade900,
                        ),
                        badgeContent: Text(
                          cartData.length.toString(),
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 61,
                top: 51,
                child: Text(
                  'My Cart',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body:
          cartData.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your shopping cart is empty.\nYou can add product to your cart from the button below.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 17,
                        letterSpacing: 1.7,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return MainScreen();
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Shop Now',
                        style: GoogleFonts.lato(fontSize: 17, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 49,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 49,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: Color(0xFFD7DDFF),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 44,
                            top: 19,
                            child: Container(
                              width: 10,
                              height: 10,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 69,
                            top: 14,
                            child: Text(
                              'You have ${cartData.length} items',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ListView.builder(
                      itemCount: cartData.length,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                        final cartItem = cartData.values.toList()[index];

                        return Padding(
                          padding: EdgeInsets.all(8),
                          child: Card(
                            child: SizedBox(
                              height: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    child: Image.network(
                                      cartItem.imageUrl[0],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.productName,
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        Text(
                                          cartItem.categoryName,
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                        ),

                                        Text(
                                          cartItem.productPrice.toStringAsFixed(
                                            2,
                                          ),
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink,
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF102DE1),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                      CupertinoIcons.minus,
                                                      color: Colors.white,
                                                    ),
                                                  ),

                                                  Text(
                                                    cartItem.quantity
                                                        .toString(),
                                                    style: GoogleFonts.lato(
                                                      color: Colors.white,
                                                    ),
                                                  ),

                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                      CupertinoIcons.plus,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                CupertinoIcons.delete,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}

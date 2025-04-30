import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/provider/cart_provider.dart';

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
      body: ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: cartData.length,
        itemBuilder: (context, index) {
          final cartItem = cartData.values.toList()[index];

          return Center(child: Text(cartItem.productName));
        },
      ),
    );
  }
}

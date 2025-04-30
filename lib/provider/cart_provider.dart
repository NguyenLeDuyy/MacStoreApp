import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/models/cart_models.dart';

final cartProvier = StateNotifierProvider<CartNotifier, Map<int, CartModel>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<int, CartModel>> {
  CartNotifier() : super({});

  void addProductToCart({
    required String productName,
    required int productPrice,     // <-- Mong đợi int
    required String categoryName,
    required List imageUrl,
    required int quantity,         // <-- Mong đợi int
    required int instock,          // <-- Mong đợi int
    required int productId,     // <-- Mong đợi String
    required String productSize,   // <-- Mong đợi String
    required int discount,         // <-- Mong đợi int
    required String description,
  }) {
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: CartModel(
          state[productId]!.productName,
          state[productId]!.productPrice,
          state[productId]!.categoryName,
          state[productId]!.imageUrl,
          state[productId]!.quantity + 1,
          state[productId]!.instock,
          state[productId]!.productId,
          state[productId]!.productSize,
          state[productId]!.discount,
          state[productId]!.description,
        ),
      };
    } else {
      state = {
        ...state,
        productId: CartModel(productName, productPrice, categoryName, imageUrl, quantity, instock, productId, productSize, discount, description)
      };
    }


  }
  
  Map<int, CartModel> get getCartItem => state;
}

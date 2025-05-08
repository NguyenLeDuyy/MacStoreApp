import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/models/cart_models.dart';

final cartProvier = StateNotifierProvider<CartNotifier, Map<int, CartModel>>((
  ref,
) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<int, CartModel>> {
  CartNotifier() : super({});

  void addProductToCart({
    required String productName,
    required int productPrice, // <-- Mong đợi int
    required String categoryName,
    required List imageUrl,
    required int quantity, // <-- Mong đợi int
    required int instock, // <-- Mong đợi int
    required int productId, // <-- Mong đợi String
    required String productSize, // <-- Mong đợi String
    required int discount, // <-- Mong đợi int
    required String description,
    required String seller_id,
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
          state[productId]!.seller_id,
        ),
      };
    } else {
      state = {
        ...state,
        productId: CartModel(
          productName,
          productPrice,
          categoryName,
          imageUrl,
          quantity,
          instock,
          productId,
          productSize,
          discount,
          description,
          seller_id,
        ),
      };
    }
  }

  //func to remove item from cart
  void removeItem(int productId){
    state.remove(productId);
    //notify listeners that the state has changed
    state = {...state};
  }

  //func to increase item's quantity in cart
  void incrementItem(int productId){
    if(state.containsKey(productId)){
      state[productId]?.quantity++;
    }

    //notify listeners that the state has changed
    state = {...state};
  }

  //func to decrease item's quantity in cart
  void decrementItem(int productId){
    if(state.containsKey(productId)){
      state[productId]?.quantity--;
    }

    //notify listeners that the state has changed
    state = {...state};
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((int productId, CartModel cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }

  void clearCartData(){
    state.clear();

    //notify listeners that the state has changed
    state = {...state};
  }

  Map<int, CartModel> get getCartItem => state;
}

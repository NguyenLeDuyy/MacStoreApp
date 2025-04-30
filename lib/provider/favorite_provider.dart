import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/models/favorite_models.dart';

final favoriteProvider =
  StateNotifierProvider<FavoriteNotifier, Map<int, FavoriteModel>>(
    (ref) {
  return FavoriteNotifier();
  },
);
class FavoriteNotifier extends StateNotifier<Map<int, FavoriteModel>>{
  FavoriteNotifier():super({});

  //is to add product to favorite

  void addProductToFavorite(
      {required String productName,
        required int productId,
        required List imageUrl,
        required int productPrice,

      }){

    state[productId] = FavoriteModel(
        productName: productName,
        productId: productId,
        imageUrl: imageUrl,
        productPrice: productPrice);

    //notify listeners that the state has changed
    state = {...state};
  }

  //remove all item from favorite
  void removeAllItem(){
    state.clear();

    //notify listeners that the state has changed
    state = {...state};

  }
  //remove favorite item
  void removeItem(int productId){
    state.remove(productId);

    //notify listeners that the state has changed
    state = {...state};
  }

  //retrive value from the state object
  Map<int, FavoriteModel> get getFavoriteItem => state;
}
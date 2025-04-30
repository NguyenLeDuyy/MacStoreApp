class FavoriteModel{
  final String productName;
  final int productId;
  final List imageUrl;
  final int productPrice;

  FavoriteModel(
      {required this.productName,
        required this.productId,
        required this.imageUrl,
        required this.productPrice});

}
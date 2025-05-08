class CartModel {
  final String productName;
  final int productPrice;
  final String categoryName;
  final List imageUrl;
  int quantity;
  final int instock;
  final int productId;
  final String productSize;
  final int discount;
  final String description;
  final String seller_id;

  CartModel(this.productName, this.productPrice, this.categoryName, this.imageUrl, this.quantity, this.instock, this.productId, this.productSize, this.discount, this.description, this.seller_id);



}
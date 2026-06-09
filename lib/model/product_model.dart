class ProductModel {
  final String productSrNo;
  final String productName;

  ProductModel({required this.productSrNo, required this.productName});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productSrNo: json['product_srno'] ?? "",
      productName: json['product_name'] ?? "",
    );
  }
}

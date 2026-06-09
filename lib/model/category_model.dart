class CategoryModel {
  final String categorySrNo;
  final String categoryName;

  CategoryModel({required this.categorySrNo, required this.categoryName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categorySrNo: (json['category_srno'] ?? '').toString(),
      categoryName: (json['category_name'] ?? '').toString(),
    );
  }
}

class CommonModel {
  final String id;
  final String name;

  CommonModel({required this.id, required this.name});

  factory CommonModel.fromJson(
    Map<String, dynamic> json,
    String idKey,
    String nameKey,
  ) {
    return CommonModel(id: json[idKey], name: json[nameKey]);
  }
}

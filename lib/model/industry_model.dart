class IndustryModel {
  final String industrySrNo;
  final String industryName;

  IndustryModel({required this.industrySrNo, required this.industryName});

  factory IndustryModel.fromJson(Map<String, dynamic> json) {
    return IndustryModel(
      industrySrNo: (json['industry_srno'] ?? '').toString(),
      industryName: (json['industry_name'] ?? '').toString(),
    );
  }
}

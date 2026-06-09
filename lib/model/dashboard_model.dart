class DashboardModel {
  final int customerCount;
  final int customerLadleCount;
  final int enquiryCount;
  final double visitPercentage;

  DashboardModel({
    required this.customerCount,
    required this.customerLadleCount,
    required this.enquiryCount,
    required this.visitPercentage,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      customerCount: int.tryParse(json['customer_count'].toString()) ?? 0,

      customerLadleCount:
          int.tryParse(json['customer_ladle_count'].toString()) ?? 0,

      enquiryCount: int.tryParse(json['enquiry_count'].toString()) ?? 0,

      visitPercentage:
          double.tryParse(json['visit_percentage'].toString()) ?? 0,
    );
  }
}

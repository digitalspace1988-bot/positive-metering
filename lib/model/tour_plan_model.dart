class TourPlanModel {
  final String tourPlanSrNo;
  final String companyName;
  final String regionName;

  final String name;

  final String? kajal;
  final String? ravi;
  final String? malhar;

  final String status;

  TourPlanModel({
    required this.tourPlanSrNo,
    required this.companyName,
    required this.regionName,
    required this.name,
    this.kajal,
    this.ravi,
    this.malhar,
    required this.status,
  });

  factory TourPlanModel.fromJson(Map<String, dynamic> json) {
    return TourPlanModel(
      tourPlanSrNo: json['tour_plan_srno'] ?? "",

      companyName: json['company_name']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),

      regionName: json['region_name']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),

      name: json['name'] ?? "",

      kajal: json['kajal'],
      ravi: json['ravi'],
      malhar: json['malhar'],

      status: json['status'] ?? "",
    );
  }
}
class TourPlanYearlyModel {
  final String companyName;
  final String regionName;
  final String status;
  final String type;
  final String? kajal;
  final String? ravi;
  final String? malhar;
  final String tourPlanSrNo;
  final String name;

  TourPlanYearlyModel({
    required this.companyName,
    required this.regionName,
    required this.status,
    required this.type,
    this.kajal,
    this.ravi,
    this.malhar,
    required this.tourPlanSrNo,
    required this.name,
  });

  factory TourPlanYearlyModel.fromJson(Map<String, dynamic> json) {
    return TourPlanYearlyModel(
      tourPlanSrNo: json['tour_plan_srno'] ?? "",
      companyName: json['company_name'],
      regionName: json['region_name'],
      status: json['status'],
      type: json['tour_type'] ?? "Tour",
      kajal: json['kajal'],
      ravi: json['ravi'],
      malhar: json['malhar'],
      name: json['name'] ?? "",
    );
  }
}

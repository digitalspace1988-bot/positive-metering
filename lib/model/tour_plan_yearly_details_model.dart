class TourPlanYearlyDetailsModel {
  final String tourPlanSrNo;
  final String fromDate;
  final String toDate;
  final String customerSrNo;
  final String tourType;
  final String visitCall;
  final String regionSrNo;
  final String customerTypeSrNo;
  final String groupSrNo;
  final String name;

  TourPlanYearlyDetailsModel({
    required this.tourPlanSrNo,
    required this.fromDate,
    required this.toDate,
    required this.customerSrNo,
    required this.tourType,
    required this.visitCall,
    required this.regionSrNo,
    required this.customerTypeSrNo,
    required this.groupSrNo,
    required this.name,
  });

  factory TourPlanYearlyDetailsModel.fromJson(Map<String, dynamic> json) {
    return TourPlanYearlyDetailsModel(
      tourPlanSrNo: json['tour_plan_srno'] ?? "",
      fromDate: json['from_date'] ?? "",
      toDate: json['to_date'] ?? "",
      customerSrNo: json['customer_srno'] ?? "",
      tourType: json['tour_type'] ?? "",
      visitCall: json['visit_call'] ?? "",
      regionSrNo: json['region_srno'] ?? "",
      customerTypeSrNo: json['customer_type_srno'] ?? "",
      groupSrNo: json['group_srno'] ?? "",
      name: json['name'] ?? "",
    );
  }
}

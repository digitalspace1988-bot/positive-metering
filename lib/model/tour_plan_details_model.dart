class TourPlanDetailsModel {
  final String tourPlanSrNo;
  final String billDate;
  final String customerSrNo;
  final String tourType;
  final String visitCall;
  final String regionSrNo;
  final String customerTypeSrNo;
  final String groupSrNo;
  final String name;

  TourPlanDetailsModel({
    required this.tourPlanSrNo,
    required this.billDate,
    required this.customerSrNo,
    required this.tourType,
    required this.visitCall,
    required this.regionSrNo,
    required this.customerTypeSrNo,
    required this.groupSrNo,
    required this.name,
  });

  factory TourPlanDetailsModel.fromJson(Map<String, dynamic> json) {
    return TourPlanDetailsModel(
      tourPlanSrNo: json['tour_plan_srno'] ?? "",
      billDate: json['bill_date'] ?? "",
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

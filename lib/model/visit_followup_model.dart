class VisitFollowUpModel {
  final String customerSrNo;
  final String tourPlanSrNo;
  final String followupDate;
  final String companyName;
  final String mobileNo;
  final String status;
  final String name;

  VisitFollowUpModel({
    required this.tourPlanSrNo,
    required this.followupDate,
    required this.companyName,
    required this.mobileNo,
    required this.status,
    required this.customerSrNo,
    required this.name,
  });

  factory VisitFollowUpModel.fromJson(Map<String, dynamic> json) {
    return VisitFollowUpModel(
      customerSrNo: (json['customer_srno'] ?? "").toString(),
      tourPlanSrNo: (json['tour_plan_srno'] ?? "").toString(),
      followupDate: (json['visit_followup_date'] ?? "").toString(),
      companyName: (json['company_name'] ?? "").toString(),
      mobileNo: (json['mobile_no'] ?? "").toString(),
      status: (json['status'] ?? "").toString(),
      name: (json['name'] ?? "").toString(),
    );
  }
}

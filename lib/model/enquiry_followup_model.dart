class EnquiryFollowUpModel {
  final String enquirySrNo;
  final String followupDate;
  final String companyName;
  final String mobileNo;
  final String status;
  final String product;
  final String customerSrNo;
  final String name;

  EnquiryFollowUpModel({
    required this.enquirySrNo,
    required this.followupDate,
    required this.companyName,
    required this.mobileNo,
    required this.status,
    required this.product,
    required this.customerSrNo,
    required this.name,
  });

  factory EnquiryFollowUpModel.fromJson(Map<String, dynamic> json) {
    return EnquiryFollowUpModel(
      customerSrNo: (json['customer_srno'] ?? "").toString(),
      enquirySrNo: (json['enquirysrno'] ?? "").toString(),
      followupDate: (json['followup_date'] ?? "").toString(),
      companyName: (json['company_name'] ?? "").toString(),
      mobileNo: (json['mobile_no'] ?? "").toString(),
      status: (json['status'] ?? "").toString().replaceAll("\n", " "),
      product: (json['product'] ?? "").toString(),
      name: (json['name'] ?? "").toString(),
    );
  }
}

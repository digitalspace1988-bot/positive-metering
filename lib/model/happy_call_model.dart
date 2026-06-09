class HappyCallModel {
  final String happycallsSrNo;
  final String companyName;
  final String customerName;
  final String mobileNo;
  final String status;

  HappyCallModel({
    required this.happycallsSrNo,
    required this.companyName,
    required this.customerName,
    required this.mobileNo,
    required this.status,
  });

  factory HappyCallModel.fromJson(Map<String, dynamic> json) {
    return HappyCallModel(
      happycallsSrNo: json['happycalls_srno'] ?? "",
      companyName: json['company_name'] ?? "",
      customerName: json['customer_name'] ?? "",
      mobileNo: json['mobile_no'] ?? "",
      status: (json['status'] ?? 'Pending').toString(),
    );
  }
}

class EnquiryModel {
  final String enquirySrNo;
  final String billDate;
  final String companyName;
  final String status;
  final String name;

  EnquiryModel({
    required this.enquirySrNo,
    required this.billDate,
    required this.companyName,
    required this.status,
    required this.name,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      enquirySrNo: json['enquirysrno'],
      billDate: json['bill_date'],
      companyName: json['company_name'],
      status: json['status'],
      name: (json['name'] ?? "")
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),
    );
  }
}

class EnquiryDetailModel {
  final String enquirySrNo;
  final String billDate;
  final String customerSrNo;
  final String companyName;
  final String productSrNo;
  final String statusSrNo;
  final String? followupDate;
  final String? comments;
  final String name;

  EnquiryDetailModel({
    required this.enquirySrNo,
    required this.billDate,
    required this.customerSrNo,
    required this.companyName,
    required this.productSrNo,
    required this.statusSrNo,
    this.followupDate,
    this.comments,
    required this.name,
  });

  factory EnquiryDetailModel.fromJson(Map<String, dynamic> json) {
    return EnquiryDetailModel(
      enquirySrNo: json['enquirysrno']
          .toString()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim(),

      billDate: json['bill_date']
          .toString()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim(),

      customerSrNo: json['customer_srno']
          .toString()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim(),

      companyName: json['company_name']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),

      productSrNo: json['product_srno']
          .toString()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim(),

      statusSrNo: json['status_srno']
          .toString()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim(),

      followupDate: json['followup_date']
          ?.toString()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim(),

      comments: json['comments']
          ?.toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),

      name: (json['name'] ?? "")
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),
    );
  }
}

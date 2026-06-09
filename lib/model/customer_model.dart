class CustomerModel {
  final String customerSrNo;
  final String regionSrNo;
  final String subregionSrNo;
  final String customerTypeSrNo;
  final String groupSrNo;

  final String companyName;
  final String customerName;
  final String mobileNo;

  final String customerType;
  final String groupName;

  final String source;
  final String department;

  bool isLadle;

  CustomerModel({
    required this.customerSrNo,
    required this.regionSrNo,
    required this.subregionSrNo,
    required this.customerTypeSrNo,
    required this.groupSrNo,
    required this.companyName,
    required this.customerName,
    required this.mobileNo,
    required this.customerType,
    required this.groupName,
    required this.source,
    required this.department,
    required this.isLadle,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerSrNo: json['customer_srno'] ?? "",

      regionSrNo: json['region_srno'] ?? "",

      subregionSrNo: json['subregion_srno'] ?? "",

      customerTypeSrNo: json['customer_type_srno'] ?? "",

      groupSrNo: json['group_srno'] ?? "",

      source: json['source'] ?? "",

      department: json['department'] ?? "",

      companyName: json['company_name']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),

      customerName: json['customer_name']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim(),

      mobileNo: json['mobile_no'] ?? "",

      customerType: json['customer_type'] ?? "",

      groupName: json['group_name'] ?? "",

      isLadle: json['ladle'] == "y",
    );
  }
}

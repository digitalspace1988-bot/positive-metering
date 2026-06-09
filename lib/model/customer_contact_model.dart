class CustomerContactModel {
  final String customerContactSrNo;
  final String customerName;
  final String mobileNo;
  final String landlineNo;
  final String email;
  final String designation;
  final String address;
  final String source;
  final String department;

  CustomerContactModel({
    required this.customerContactSrNo,
    required this.customerName,
    required this.mobileNo,
    required this.landlineNo,
    required this.email,
    required this.designation,
    required this.address,
    required this.source,
    required this.department,
  });

  factory CustomerContactModel.fromJson(Map<String, dynamic> json) {
    return CustomerContactModel(
      customerContactSrNo: json['customer_contact_srno'] ?? "",
      customerName: json['customer_name'] ?? "",
      mobileNo: json['mobile_no'] ?? "",
      landlineNo: json['landline_no'] ?? "",
      email: json['email'] ?? "",
      designation: json['designation'] ?? "",
      address: json['address'] ?? "",
      source: json['source'] ?? "",

      department: json['department'] ?? "",
    );
  }
}

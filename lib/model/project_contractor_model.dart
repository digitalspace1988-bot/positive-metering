class ProjectContractorModel {
  final String projectContractorsSrNo;
  final String name;
  final String email;
  final String mobile;
  final String address;

  ProjectContractorModel({
    required this.projectContractorsSrNo,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
  });

  factory ProjectContractorModel.fromJson(Map<String, dynamic> json) {
    return ProjectContractorModel(
      projectContractorsSrNo: (json["project_contractors_srno"] ?? "")
          .toString(),
      name: (json["name"] ?? "").toString(),
      email: (json["email"] ?? "").toString(),
      mobile: (json["mobile"] ?? "").toString(),
      address: (json["address"] ?? "").toString(),
    );
  }
}

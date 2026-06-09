class ProjectModel {
  final String projectSrNo;
  final String projectTitle;
  final String regionName;
  final String projectValue;
  final String clientName;
  final String clientContactNumber;

  ProjectModel({
    required this.projectSrNo,
    required this.projectTitle,
    required this.regionName,
    required this.projectValue,
    required this.clientName,
    required this.clientContactNumber,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectSrNo: (json['project_srno'] ?? "").toString(),
      projectTitle: (json['project_title'] ?? "").toString(),
      regionName: (json['region_name'] ?? "").toString(),
      projectValue: (json['project_value'] ?? "").toString(),
      clientName: (json['client_name'] ?? "").toString(),
      clientContactNumber: (json['client_contact_number'] ?? "").toString(),
    );
  }
}

class ProjectFollowUpModel {
  final String projectSrNo;
  final String followupDate;
  final String projectTitle;
  final String regionName;
  final String projectValue;
  final String clientName;
  final String clientContactNumber;

  ProjectFollowUpModel({
    required this.projectSrNo,
    required this.followupDate,
    required this.projectTitle,
    required this.regionName,
    required this.projectValue,
    required this.clientName,
    required this.clientContactNumber,
  });

  factory ProjectFollowUpModel.fromJson(Map<String, dynamic> json) {
    return ProjectFollowUpModel(
      projectSrNo: (json['project_srno'] ?? "").toString(),
      followupDate: (json['followup_date'] ?? "").toString(),
      projectTitle: (json['project_title'] ?? "").toString(),
      regionName: (json['region_name'] ?? "").toString(),
      projectValue: (json['project_value'] ?? "").toString(),
      clientName: (json['client_name'] ?? "").toString(),
      clientContactNumber: (json['client_contact_number'] ?? "").toString(),
    );
  }
}

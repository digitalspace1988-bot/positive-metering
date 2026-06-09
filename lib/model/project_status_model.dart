class ProjectStatusModel {
  final String statusSrNo;
  final String statusName;

  ProjectStatusModel({required this.statusSrNo, required this.statusName});

  factory ProjectStatusModel.fromJson(Map<String, dynamic> json) {
    return ProjectStatusModel(
      statusSrNo: (json['status_srno'] ?? '').toString(),
      statusName: (json['status_name'] ?? '').toString(),
    );
  }
}

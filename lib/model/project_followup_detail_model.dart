class ProjectFollowupDetailModel {
  final String followupDate;
  final String status;
  final String followupComment;
  final String nextFollowup;
  final String name;

  ProjectFollowupDetailModel({
    required this.followupDate,
    required this.status,
    required this.followupComment,
    required this.nextFollowup,
    required this.name,
  });

  factory ProjectFollowupDetailModel.fromJson(Map<String, dynamic> json) {
    return ProjectFollowupDetailModel(
      followupDate: (json["followup_date"] ?? "").toString(),
      status: (json["status"] ?? "").toString(),
      followupComment: (json["followup_comment"] ?? "").toString(),
      nextFollowup: (json["next_followup"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
    );
  }
}

class TaskModel {
  final String taskSrNo;

  final String assignedBy;
  final String assignedTo;

  final String taskDetails;
  final String status;
  final String taskComments;

  TaskModel({
    required this.taskSrNo,
    required this.assignedBy,
    required this.assignedTo,
    required this.taskDetails,
    required this.status,
    required this.taskComments,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskSrNo: (json['task_srno'] ?? "").toString(),

      assignedBy: (json['assigned_by'] ?? "").toString(),

      assignedTo: (json['assigned_to'] ?? "").toString(),

      taskDetails: (json['task_details'] ?? "").toString(),

      status: (json['status'] ?? "Pending").toString(),

      taskComments: (json['task_comments'] ?? "").toString(),
    );
  }
}

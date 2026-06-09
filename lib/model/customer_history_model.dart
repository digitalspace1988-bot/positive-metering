class CustomerHistoryModel {
  final String transactionType;
  final String date;
  final String transactionSrNo;

  CustomerHistoryModel({
    required this.transactionType,
    required this.date,
    required this.transactionSrNo,
  });

  factory CustomerHistoryModel.fromJson(Map<String, dynamic> json) {
    return CustomerHistoryModel(
      transactionType: json['transaction_type'] ?? "",
      date: json['date'] ?? "",
      transactionSrNo: json['transaction_srno'] ?? "",
    );
  }
}

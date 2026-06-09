class ProjectDetailModel {
  final String projectSrNo;
  final String projectDate;
  final String projectTitle;
  final String projectValue;

  final String clientName;
  final String clientContactNumber;
  final String clientEmail;

  final String industrySrNo;
  final String statusSrNo;
  final String categorySrNo;

  final String regionSrNo;
  final String subregionSrNo;
  final String countrySrNo;
  final String stateSrNo;
  final String districtSrNo;
  final String citySrNo;
  final String areaSrNo;

  ProjectDetailModel({
    required this.projectSrNo,
    required this.projectDate,
    required this.projectTitle,
    required this.projectValue,
    required this.clientName,
    required this.clientContactNumber,
    required this.clientEmail,
    required this.industrySrNo,
    required this.statusSrNo,
    required this.categorySrNo,
    required this.regionSrNo,
    required this.subregionSrNo,
    required this.countrySrNo,
    required this.stateSrNo,
    required this.districtSrNo,
    required this.citySrNo,
    required this.areaSrNo,
  });

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailModel(
      projectSrNo: (json["project_srno"] ?? "").toString(),
      projectDate: (json["project_date"] ?? "").toString(),
      projectTitle: (json["project_title"] ?? "").toString(),
      projectValue: (json["project_value"] ?? "").toString(),

      clientName: (json["client_name"] ?? "").toString(),
      clientContactNumber: (json["client_contact_number"] ?? "").toString(),
      clientEmail: (json["client_email"] ?? "").toString(),

      industrySrNo: (json["industry_srno"] ?? "").toString(),
      statusSrNo: (json["status_srno"] ?? "").toString(),
      categorySrNo: (json["category_srno"] ?? "").toString(),

      regionSrNo: (json["region_srno"] ?? "").toString(),
      subregionSrNo: (json["subregion_srno"] ?? "").toString(),
      countrySrNo: (json["country_srno"] ?? "").toString(),
      stateSrNo: (json["state_srno"] ?? "").toString(),
      districtSrNo: (json["district_srno"] ?? "").toString(),
      citySrNo: (json["city_srno"] ?? "").toString(),
      areaSrNo: (json["area_srno"] ?? "").toString(),
    );
  }
}

class ApiConfig {
  static const String baseUrl =
      "https://digitalspaceinc.com/positive_metering/ws/";

  static String get sendOtpUrl => "${baseUrl}sendotp.php";
  static String get loginUrl => "${baseUrl}login.php";
  static String get getTourPlanUrl => "${baseUrl}getTourPlan.php";
  static String get getTourPlanYearlyUrl => "${baseUrl}getTourPlanYearly.php";
  static String get getCustomerListUrl => "${baseUrl}getCustomerList.php";
  static String get getRegionUrl => "${baseUrl}getRegion.php";
  static String get getCustomerTypeUrl => "${baseUrl}getCustomer_type.php";
  static String get getGroupUrl => "${baseUrl}getGroup.php";
  static String get addTourPlanUrl => "${baseUrl}addTourPlan.php";
  static String get addTourPlanYearlyUrl => "${baseUrl}addTourPlanYearly.php";
  static String get getAttendanceReportUrl =>
      "${baseUrl}get_attendance_report.php";

  static String get addAttendanceRegularizeUrl =>
      "${baseUrl}addattendanceregularize.php";

  static String get markAttendanceUrl => "${baseUrl}markAttendance.php";
  static String get getAttendanceStatusUrl =>
      "${baseUrl}get_attendance_status.php";

  static String get addEmployeeLocationUrl =>
      "${baseUrl}addEmployeeLocation.php";

  static String get getProductsUrl => "${baseUrl}getProducts.php";
  static String get getTourPlanDetailsUrl => "${baseUrl}getTourPlanDetails.php";
  static String get getTourPlanDetailsYearlyUrl =>
      "${baseUrl}getTourPlanDetailsYearly.php";
  static String get addVisitUrl => "${baseUrl}addVisit.php";
  static String get addEnquiryUrl => "${baseUrl}addEnquiry.php";
  static const String getHappyCallsUrl = "$baseUrl/gethappycalls.php";

  static const String happyCallStatusUpdateUrl =
      "$baseUrl/happycalls_status_update.php";
}

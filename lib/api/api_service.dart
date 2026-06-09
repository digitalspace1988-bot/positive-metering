import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:positive_metering/model/category_model.dart';
import 'package:positive_metering/model/common_model.dart';
import 'package:positive_metering/model/customer_contact_model.dart';
import 'package:positive_metering/model/customer_history_model.dart';
import 'package:positive_metering/model/customer_model.dart';
import 'package:positive_metering/model/dashboard_model.dart';
import 'package:positive_metering/model/enquiry_detail_model.dart';
import 'package:positive_metering/model/enquiry_followup_model.dart';
import 'package:positive_metering/model/enquiry_model.dart';
import 'package:positive_metering/model/happy_call_model.dart';
import 'package:positive_metering/model/industry_model.dart';
import 'package:positive_metering/model/login_model.dart';
import 'package:positive_metering/model/product_model.dart';
import 'package:positive_metering/model/project_contractor_model.dart';
import 'package:positive_metering/model/project_detail_model.dart';
import 'package:positive_metering/model/project_followup_model.dart';
import 'package:positive_metering/model/project_model.dart';
import 'package:positive_metering/model/project_status_model.dart';
import 'package:positive_metering/model/task_model.dart';
import 'package:positive_metering/model/tour_plan_details_model.dart';
import 'package:positive_metering/model/tour_plan_model.dart';
import 'package:positive_metering/model/tour_plan_yearly_details_model.dart';
import 'package:positive_metering/model/tour_plan_yearly_model.dart';
import 'package:positive_metering/model/user_model.dart';
import 'package:positive_metering/model/visit_followup_model.dart';
import 'api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> _postRequest(
    String url,
    Map<String, String> params,
  ) async {
    try {
      final response = await http.post(Uri.parse(url), body: params);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 1, 'message': 'Server error'};
      }
    } catch (e) {
      return {'status': 1, 'message': 'Network error'};
    }
  }

  /// SEND OTP
  static Future<bool> sendOtp(String email) async {
    final res = await _postRequest(ApiConfig.sendOtpUrl, {'email': email});

    return res['status'] == 0;
  }

  /// LOGIN
  static Future<LoginModel?> login({
    required String email,
    required String otp,
  }) async {
    final res = await _postRequest(ApiConfig.loginUrl, {
      'email': email,
      'otp_entered': otp,
    });

    if (res['status'] == 0) {
      return LoginModel.fromJson(res);
    }

    return null;
  }

  static Future<List<TourPlanModel>> getTourPlan({
    required String userSrNo,
    required String billDate,
    required String tourType,
  }) async {
    final res = await _postRequest(ApiConfig.getTourPlanUrl, {
      'usersrno': userSrNo,
      'bill_date': billDate,
      'tour_type': tourType,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => TourPlanModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<List<TourPlanYearlyModel>> getTourPlanYearly({
    required String userSrNo,
    required String tourType,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(ApiConfig.getTourPlanYearlyUrl, {
      'usersrno': userSrNo,
      'tour_type': tourType,
      'from_date': fromDate,
      'to_date': toDate,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => TourPlanYearlyModel.fromJson(e))
          .toList();
    }

    return [];
  }

  /// CUSTOMER LIST
  static Future<List<CustomerModel>> getCustomerList({
    required String userSrNo,
    required String regionSrNo,
    required String subregionSrNo,
  }) async {
    final res = await _postRequest(ApiConfig.getCustomerListUrl, {
      'usersrno': userSrNo,
      'region_srno': regionSrNo,
      'subregion_srno': subregionSrNo,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => CustomerModel.fromJson(e))
          .toList();
    }
    return [];
  }

  /// REGION
  static Future<List<CommonModel>> getRegion() async {
    final res = await _postRequest(ApiConfig.getRegionUrl, {});
    if (res['status'] == 0) {
      return (res['data'] as List)
          .map((e) => CommonModel.fromJson(e, "region_srno", "region_name"))
          .toList();
    }
    return [];
  }

  /// CUSTOMER TYPE
  static Future<List<CommonModel>> getCustomerType() async {
    final res = await _postRequest(ApiConfig.getCustomerTypeUrl, {});
    if (res['status'] == 0) {
      return (res['data'] as List)
          .map(
            (e) =>
                CommonModel.fromJson(e, "customer_type_srno", "customer_type"),
          )
          .toList();
    }
    return [];
  }

  /// GROUP
  static Future<List<CommonModel>> getGroup() async {
    final res = await _postRequest(ApiConfig.getGroupUrl, {});
    if (res['status'] == 0) {
      return (res['data'] as List)
          .map((e) => CommonModel.fromJson(e, "group_srno", "group_name"))
          .toList();
    }
    return [];
  }

  static Future<List<CommonModel>> getCountry({
    required String userSrNo,
    required String regionSrNo,
    required String subregionSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getcountry.php",
      {
        "usersrno": userSrNo,
        "region_srno": regionSrNo,
        "subregion_srno": subregionSrNo,
      },
    );

    if (res['status'] == 0) {
      return (res['data'] as List)
          .map((e) => CommonModel.fromJson(e, "country_srno", "country_name"))
          .toList();
    }

    return [];
  }

  static Future<List<CommonModel>> getState({
    required String userSrNo,
    required String regionSrNo,
    required String subregionSrNo,
    required String countrySrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getstate.php",
      {
        "usersrno": userSrNo,
        "region_srno": regionSrNo,
        "subregion_srno": subregionSrNo,
        "country_srno": countrySrNo,
      },
    );

    if (res['status'] == 0) {
      return (res['data'] as List)
          .map((e) => CommonModel.fromJson(e, "state_srno", "state_name"))
          .toList();
    }

    return [];
  }

  static Future<List<CommonModel>> getDistrict({
    required String userSrNo,
    required String stateSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getdistrict.php",
      {"usersrno": userSrNo, "state_srno": stateSrNo},
    );

    if (res['status'] == 0) {
      return (res['data'] as List)
          .map((e) => CommonModel.fromJson(e, "district_srno", "district_name"))
          .toList();
    }

    return [];
  }

  static Future<List<CommonModel>> getCity({
    required String userSrNo,
    required String districtSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getcity.php",
      {"usersrno": userSrNo, "district_srno": districtSrNo},
    );

    if (res['status'] == 0) {
      return (res['data'] as List)
          .map((e) => CommonModel.fromJson(e, "city_srno", "city_name"))
          .toList();
    }

    return [];
  }

  static Future<List<CommonModel>> getArea({
    required String userSrNo,
    required String citySrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getarea.php",
      {"usersrno": userSrNo, "city_srno": citySrNo},
    );

    if (res['status'] == 0) {
      return (res['data'] as List)
          .map((e) => CommonModel.fromJson(e, "area_srno", "area_name"))
          .toList();
    }

    return [];
  }

  static Future<bool> addCustomer({
    required String regionSrNo,
    required String subregionSrNo,
    required String countrySrNo,
    required String stateSrNo,
    required String districtSrNo,
    required String citySrNo,
    required String areaSrNo,
    required String customerTypeSrNo,
    required String groupSrNo,
    required String companyName,
    required String customerName,
    required String mobileNo,
    required String landlineNo,
    required String email,
    required String website,
    required String designation,
    required String address,

    required String department,
    required String sourceSrNo,
    required String productSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/addcustomer.php",
      {
        'region_srno': regionSrNo,
        'subregion_srno': subregionSrNo,
        'country_srno': countrySrNo,
        'state_srno': stateSrNo,
        'district_srno': districtSrNo,
        'city_srno': citySrNo,
        'area_srno': areaSrNo,
        'customer_type_srno': customerTypeSrNo,
        'group_srno': groupSrNo,
        'company_name': companyName,
        'customer_name': customerName,
        'mobile_no': mobileNo,
        'landline_no': landlineNo,
        'email': email,
        'website': website,
        'designation': designation,
        'address': address,

        'department': department,
        'source_srno': sourceSrNo,
        'product_srno': productSrNo,
      },
    );

    return res['status'] == 0;
  }

  /// ADD TOUR PLAN
  static Future<bool> addTourPlan({
    required String userSrNo,
    required String customerSrNo,
    required String billDate,
    required String tourType,
    required String visitCall,
  }) async {
    final res = await _postRequest(ApiConfig.addTourPlanUrl, {
      'usersrno': userSrNo,
      'customer_srno': customerSrNo,
      'bill_date': billDate,
      'tour_type': tourType,
      'visit_call': visitCall,
    });

    return res['status'] == 0;
  }

  static Future<bool> addTourPlanYearly({
    required String userSrNo,
    required String customerSrNo,
    required String fromDate,
    required String toDate,
    required String tourType,
    required String visitCall,
  }) async {
    final res = await _postRequest(ApiConfig.addTourPlanYearlyUrl, {
      'usersrno': userSrNo,
      'customer_srno': customerSrNo,
      'from_date': fromDate,
      'to_date': toDate,
      'tour_type': tourType,
      'visit_call': visitCall,
    });

    return res['status'] == 0;
  }

  /// ATTENDANCE REPORT
  static Future<List<Map<String, dynamic>>> getAttendanceReport({
    required String usersrno,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(ApiConfig.getAttendanceReportUrl, {
      'usersrno': usersrno,
      'from_date': fromDate,
      'to_date': toDate,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return List<Map<String, dynamic>>.from(res['data']);
    }

    return [];
  }

  /// ADD ATTENDANCE REGULARIZE
  static Future<Map<String, dynamic>> addAttendanceRegularize({
    required String usersrno,
    required String srno,
  }) async {
    return await _postRequest(ApiConfig.addAttendanceRegularizeUrl, {
      'usersrno': usersrno,
      'srno': srno,
    });
  }

  // MARK ATTENDANCE (Punch In / Out)
  static Future<Map<String, dynamic>> markAttendance({
    required String usersrno,
    required String billDate,
    required String inOut,
    required String lat,
    required String lng,
  }) async {
    return await _postRequest(ApiConfig.markAttendanceUrl, {
      'usersrno': usersrno,
      'bill_date': billDate,
      'in_out': inOut,
      'lat': lat,
      'lng': lng,
    });
  }

  // GET ATTENDANCE STATUS

  static Future<Map<String, dynamic>> getAttendanceStatus({
    required String usersrno,
  }) async {
    return await _postRequest(ApiConfig.getAttendanceStatusUrl, {
      'usersrno': usersrno,
    });
  }

  //  SEND LIVE LOCATION
  static Future<void> sendLiveLocation({
    required String usersrno,
    required String lat,
    required String lng,
  }) async {
    await _postRequest(ApiConfig.addEmployeeLocationUrl, {
      'usersrno': usersrno,
      'lat': lat,
      'lng': lng,
    });
  }

  static Future<List<ProductModel>> getProducts() async {
    final res = await _postRequest(ApiConfig.getProductsUrl, {});

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<TourPlanDetailsModel?> getTourPlanDetails({
    required String tourPlanSrNo,
  }) async {
    final res = await _postRequest(ApiConfig.getTourPlanDetailsUrl, {
      'tour_plan_srno': tourPlanSrNo,
    });

    if (res['status'] == 0 && res['data'] != null && res['data'].isNotEmpty) {
      return TourPlanDetailsModel.fromJson(res['data'][0]);
    }

    return null;
  }

  static Future<TourPlanYearlyDetailsModel?> getTourPlanDetailsYearly({
    required String tourPlanSrNo,
  }) async {
    final res = await _postRequest(ApiConfig.getTourPlanDetailsYearlyUrl, {
      'tour_plan_srno': tourPlanSrNo,
    });

    if (res['status'] == 0 && res['data'] != null && res['data'].isNotEmpty) {
      return TourPlanYearlyDetailsModel.fromJson(res['data'][0]);
    }

    return null;
  }

  static Future<bool> addVisit({
    required String userSrNo,
    required String tourPlanSrNo,
    required String comments,
    String? followupDate,
    required String enquiryGenerated,
    String? productSrNo,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.addVisitUrl),
      );

      request.fields['usersrno'] = userSrNo;
      request.fields['tour_plan_srno'] = tourPlanSrNo;
      request.fields['comments'] = comments;
      request.fields['enquiry_generated'] = enquiryGenerated;

      if (followupDate != null) {
        request.fields['visit_followup_date'] = followupDate;
      }

      if (enquiryGenerated == "Yes" && productSrNo != null) {
        request.fields['product_srno'] = productSrNo;
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('img1', imageFile.path),
        );
      }

      final response = await request.send();

      final res = await response.stream.bytesToString();
      final data = jsonDecode(res);

      return data['status'] == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addEnquiry({
    required String userSrNo,
    required String customerSrNo,
    required String comments,
    required String productSrNo,
    required String billDate,
    required String followupDate,
  }) async {
    final res = await _postRequest(ApiConfig.addEnquiryUrl, {
      'usersrno': userSrNo,
      'customer_srno': customerSrNo,
      'comments': comments,
      'product_srno': productSrNo,
      'bill_date': billDate,
      'visit_followup_date': followupDate,
    });

    return res['status'] == 0;
  }

  static Future<List<EnquiryModel>> getEnquiry({
    required String usersrno,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getEnquiry.php",
      {'usersrno': usersrno, 'from_date': fromDate, 'to_date': toDate},
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => EnquiryModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<EnquiryDetailModel?> getEnquiryDetail({
    required String enquirySrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getEnquiryDetail.php",
      {'enquirysrno': enquirySrNo},
    );

    if (res['status'] == 0 && res['data'] != null && res['data'].isNotEmpty) {
      return EnquiryDetailModel.fromJson(res['data'][0]);
    }

    return null;
  }

  static Future<List<EnquiryFollowUpModel>> getEnquiryFollowUp({
    required String usersrno,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getEnquiryFollowup.php",
      {'usersrno': usersrno, 'from_date': fromDate, 'to_date': toDate},
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => EnquiryFollowUpModel.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<List<VisitFollowUpModel>> getVisitFollowUp({
    required String usersrno,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getVisitFollowup.php",
      {'usersrno': usersrno, 'from_date': fromDate, 'to_date': toDate},
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => VisitFollowUpModel.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getStatus() async {
    final response = await http.post(
      Uri.parse(
        "https://digitalspaceinc.com/positive_metering/ws/getStatus.php",
      ),
    );

    final json = jsonDecode(response.body);

    if (json['status'] == 0) {
      return List<Map<String, dynamic>>.from(json['data']);
    } else {
      return [];
    }
  }

  static Future<bool> addFollowupEnquiry({
    required String enquirySrNo,
    required String userSrNo,
    required String comments,
    required String customerSrNo,
    required String visitDate,
    required String statusSrNo,
    required String nextFollowup,
  }) async {
    final response = await http.post(
      Uri.parse(
        "https://digitalspaceinc.com/positive_metering/ws/addFollowupEnquiry.php",
      ),
      body: {
        "enquirysrno": enquirySrNo,
        "usersrno": userSrNo,
        "comments": comments,
        "customer_srno": customerSrNo,
        "visit_followup_date": visitDate,
        "status_srno": statusSrNo,
        "next_followup": nextFollowup,
      },
    );

    return jsonDecode(response.body)['status'] == 0;
  }

  static Future<bool> addFollowupVisit({
    required String tourPlanSrNo,
    required String userSrNo,
    required String comments,
    required String customerSrNo,
    required String visitDate,
    required String statusSrNo,
    required String nextFollowup,
    String? enquiryGenerated,
    String? productSrNo,
  }) async {
    final response = await http.post(
      Uri.parse(
        "https://digitalspaceinc.com/positive_metering/ws/addFollowupVisits.php",
      ),
      body: {
        "tour_plan_srno": tourPlanSrNo,
        "usersrno": userSrNo,
        "comments": comments,
        "customer_srno": customerSrNo,
        "visit_followup_date": visitDate,
        "status_srno": statusSrNo,
        "next_followup": nextFollowup,

        if (enquiryGenerated != null) "enquiry_generated": enquiryGenerated,

        if (enquiryGenerated == "Yes" && productSrNo != null)
          "product_srno": productSrNo,
      },
    );

    return jsonDecode(response.body)['status'] == 0;
  }

  static Future<List<Map<String, dynamic>>> getEnquiryFollowupDetails({
    required String enquirySrNo,
  }) async {
    final res = await http.post(
      Uri.parse(
        "https://digitalspaceinc.com/positive_metering/ws/getEnquiryFollowupDetails.php",
      ),
      body: {"enquirysrno": enquirySrNo},
    );

    final jsonData = json.decode(res.body);
    return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
  }

  static Future<List<Map<String, dynamic>>> getVisitFollowupDetails({
    required String tourPlanSrNo,
  }) async {
    final res = await http.post(
      Uri.parse(
        "https://digitalspaceinc.com/positive_metering/ws/getVisitFollowupDetails.php",
      ),
      body: {"tour_plan_srno": tourPlanSrNo},
    );

    final jsonData = json.decode(res.body);
    return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
  }

  static Future<List<TaskModel>> getMyTask({
    required String assignedByUserSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getMyTask.php",
      {'assigned_by_usersrno': assignedByUserSrNo},
    );

    if (res['status'] == 0 && res['data'] != null && res['data'] is List) {
      return (res['data'] as List).map((e) => TaskModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<List<TaskModel>> getMyTaskAssigned({
    required String assignedToUserSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getMyTaskAssigned.php",
      {'assigned_to_usersrno': assignedToUserSrNo},
    );

    if (res['status'] == 0 && res['data'] != null && res['data'] is List) {
      return (res['data'] as List).map((e) => TaskModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<bool> updateTaskStatus({
    required String taskSrNo,
    required String taskComments,
    required String status,
    required String assignedToUserSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/updatetaskstatus.php",
      {
        "task_srno": taskSrNo,
        "task_comments": taskComments,
        "status": status,
        "assigned_to_usersrno": assignedToUserSrNo,
      },
    );

    return res['status'] == 0;
  }

  static Future<List<UserModel>> getUsers() async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getusers.php",
      {},
    );

    if (res['status'] == 0) {
      return (res['data'] as List).map((e) => UserModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<bool> addTask({
    required String assignedByUserSrNo,
    required String assignedToUserSrNo,
    required String taskDetails,
    required String taskComments,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://digitalspaceinc.com/positive_metering/ws/addtask.php",
        ),
        body: {
          "assigned_by_usersrno": assignedByUserSrNo,
          "assigned_to_usersrno": assignedToUserSrNo,
          "task_details": taskDetails,
          "task_comments": taskComments,
        },
      );

      final data = jsonDecode(response.body);

      return data['status'] == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addLadleCustomer({
    required String userSrNo,
    required String customerSrNo,
    required String ladle,
  }) async {
    final response = await http.post(
      Uri.parse(
        "https://digitalspaceinc.com/positive_metering/ws/addladlecustomer.php",
      ),
      body: {
        "usersrno": userSrNo,
        "customer_srno": customerSrNo,
        "ladle": ladle,
      },
    );

    final data = jsonDecode(response.body);

    return data['status'] == 0;
  }

  static Future<List<CustomerContactModel>> getCustomerContacts({
    required String customerSrNo,
    required String userSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getcustomercontact.php",
      {'customer_srno': customerSrNo, 'usersrno': userSrNo},
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => CustomerContactModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<bool> addCustomerContact({
    required String customerSrNo,
    required String customerName,
    required String mobileNo,
    required String landlineNo,
    required String email,
    required String designation,
    required String address,
    required String userSrNo,

    required String department,
    required String sourceSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/addcustomercontact.php",
      {
        'customer_srno': customerSrNo,
        'customer_name': customerName,
        'mobile_no': mobileNo,
        'landline_no': landlineNo,
        'email': email,
        'designation': designation,
        'address': address,
        'usersrno': userSrNo,

        'department': department,
        'source_srno': sourceSrNo,
      },
    );

    return res['status'] == 0;
  }

  static Future<List<CustomerHistoryModel>> getCustomerHistory({
    required String customerSrNo,
    required String userSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getcustomerhistory.php",
      {'customer_srno': customerSrNo, 'usersrno': userSrNo},
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => CustomerHistoryModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<List<CommonModel>> getSource({required String userSrNo}) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getsource.php",
      {'usersrno': userSrNo},
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map(
            (e) => CommonModel(
              id: e['source_srno'].toString(),
              name: e['source'].toString(),
            ),
          )
          .toList();
    }

    return [];
  }

  static Future<DashboardModel?> getDashboard({
    required String userSrNo,
  }) async {
    try {
      final res = await _postRequest(
        "https://digitalspaceinc.com/positive_metering/ws/getdashboard.php",
        {"usersrno": userSrNo},
      );

      if (res['status'] == 0) {
        return DashboardModel.fromJson(res);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<CommonModel>> getSubregion({
    required String userSrNo,
    required String regionSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getsubregion.php",
      {'usersrno': userSrNo, 'region_srno': regionSrNo},
    );

    if (res['status'] == 0) {
      return (res['data'] as List)
          .map(
            (e) =>
                CommonModel(id: e['subregion_srno'], name: e['subregion_name']),
          )
          .toList();
    }

    return [];
  }

  static Future<LoginModel?> refreshLoginDetails({
    required String userSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getlogindetails.php",
      {"usersrno": userSrNo},
    );

    if (res["status"] == 0 &&
        res["data"] != null &&
        (res["data"] as List).isNotEmpty) {
      return LoginModel.fromJson(res);
    }

    return null;
  }

  static Future<List<HappyCallModel>> getHappyCalls({
    required String userSrNo,
    required String billDate,
  }) async {
    final res = await _postRequest(ApiConfig.getHappyCallsUrl, {
      "usersrno": userSrNo,
      "bill_date": billDate,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => HappyCallModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<bool> updateHappyCallStatus({
    required String userSrNo,
    required String happyCallSrNo,
    required String comments,
    required String status,
  }) async {
    final res = await _postRequest(ApiConfig.happyCallStatusUpdateUrl, {
      "usersrno": userSrNo,
      "happycalls_srno": happyCallSrNo,
      "happycalls_comments": comments,
      "status": status,
    });

    return res['status'] == 0;
  }

  static Future<List<IndustryModel>> getIndustry({
    required String userSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getindustry.php",
      {"usersrno": userSrNo},
    );

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => IndustryModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<List<CategoryModel>> getCategory({
    required String userSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getcategory.php",
      {"usersrno": userSrNo},
    );

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<List<ProjectStatusModel>> getProjectStatus({
    required String userSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getprojectstatus.php",
      {"usersrno": userSrNo},
    );

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => ProjectStatusModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<bool> addProject({
    required String userSrNo,
    required String projectTitle,
    required String projectValue,
    required String clientName,
    required String clientContactNumber,
    required String clientEmail,
    required String industrySrNo,
    required String statusSrNo,
    required String categorySrNo,
    required String regionSrNo,
    required String subregionSrNo,
    required String countrySrNo,
    required String stateSrNo,
    required String districtSrNo,
    required String citySrNo,
    required String areaSrNo,
    required String projectComments,
    required String projectDate,
    required String projectStartDate,
    required String followupDate,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/addproject.php",
      {
        "usersrno": userSrNo,
        "project_title": projectTitle,
        "project_value": projectValue,
        "client_name": clientName,
        "client_contact_number": clientContactNumber,
        "client_email": clientEmail,
        "industry_srno": industrySrNo,
        "status_srno": statusSrNo,
        "category_srno": categorySrNo,
        "region_srno": regionSrNo,
        "subregion_srno": subregionSrNo,
        "country_srno": countrySrNo,
        "state_srno": stateSrNo,
        "district_srno": districtSrNo,
        "city_srno": citySrNo,
        "area_srno": areaSrNo,
        "project_comments": projectComments,
        "project_date": projectDate,
        "project_start_date": projectStartDate,
        "followup_date": followupDate,
      },
    );

    return res["status"] == 0;
  }

  static Future<List<ProjectModel>> getProjects({
    required String userSrNo,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getProjects.php",
      {"usersrno": userSrNo, "from_date": fromDate, "to_date": toDate},
    );

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => ProjectModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<List<ProjectFollowUpModel>> getProjectFollowUp({
    required String usersrno,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getProjectFollowup.php",
      {"usersrno": usersrno, "from_date": fromDate, "to_date": toDate},
    );

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => ProjectFollowUpModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<bool> addProjectFollowup({
    required String projectSrNo,
    required String userSrNo,
    required String comments,
    required String projectFollowupDate,
    required String statusSrNo,
    required String nextFollowup,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/addProjectFollowup.php",
      {
        "project_srno": projectSrNo,
        "usersrno": userSrNo,
        "comments": comments,
        "project_followup_date": projectFollowupDate,
        "status_srno": statusSrNo,
        "next_followup": nextFollowup,
      },
    );

    return res["status"] == 0;
  }

  static Future<List<Map<String, dynamic>>> getProjectFollowupDetails({
    required String projectSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getProjectFollowupDetails.php",
      {"project_srno": projectSrNo},
    );

    if (res["status"] == 0 && res["data"] != null) {
      return List<Map<String, dynamic>>.from(res["data"]);
    }

    return [];
  }

  static Future<ProjectDetailModel?> getProjectDetail({
    required String projectSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getProjectDetail.php",
      {"project_srno": projectSrNo},
    );

    if (res["status"] == 0 &&
        res["data"] != null &&
        (res["data"] as List).isNotEmpty) {
      return ProjectDetailModel.fromJson(res["data"][0]);
    }

    return null;
  }

  static Future<List<ProjectContractorModel>> getProjectContractors({
    required String userSrNo,
    required String projectSrNo,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/getprojectcontractors.php",
      {"usersrno": userSrNo, "project_srno": projectSrNo},
    );

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => ProjectContractorModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<bool> addProjectContractor({
    required String userSrNo,
    required String projectSrNo,
    required String name,
    required String email,
    required String mobile,
    required String address,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/positive_metering/ws/addprojectcontractors.php",
      {
        "usersrno": userSrNo,
        "project_srno": projectSrNo,
        "name": name,
        "email": email,
        "mobile": mobile,
        "address": address,
      },
    );

    return res["status"] == 0;
  }
}

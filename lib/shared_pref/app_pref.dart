import 'dart:convert';

import 'package:positive_metering/model/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPref {
  static const String _isLoggedIn = "is_logged_in";
  static const String _userData = "user_data";

  static Future<void> saveUser(LoginModel user) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setBool(_isLoggedIn, true);

    await pref.setString(
      _userData,
      jsonEncode({
        "usersrno": user.userSrNo,
        "name": user.name,
        "email": user.email,
        "gender": user.gender,

        "region_srno": user.regionSrNo,
        "subregion_srno": user.subRegionSrNo,

        "attendance": user.attendance,

        "tour_plan_rmm_view": user.tourPlanRmmView,
        "tour_plan_rmm_add": user.tourPlanRmmAdd,

        "tour_plan_yearly_view": user.tourPlanYearlyView,
        "tour_plan_yearly_add": user.tourPlanYearlyAdd,

        "customer_view": user.customerView,
        "customer_add": user.customerAdd,

        "enquiry_view": user.enquiryView,
        "enquiry_add": user.enquiryAdd,

        "exhibition_view": user.exhibitionView,
        "exhibition_add": user.exhibitionAdd,

        "projects_view": user.projectsView,
        "projects_add": user.projectsAdd,

        "vendor_enlistment_view": user.vendorEnlistmentView,

        "vendor_enlistment_add": user.vendorEnlistmentAdd,

        "enquiryfollowup_view": user.enquiryfollowupView,

        "enquiryfollowup_add": user.enquiryfollowupAdd,

        "visitfollowup_view": user.visitfollowupView,

        "visitfollowup_add": user.visitfollowupAdd,

        "happy_calls_view": user.happyCallsView,

        "happy_calls_add": user.happyCallsAdd,

        "service_view": user.serviceView,

        "service_add": user.serviceAdd,
      }),
    );
  }

  static Future<void> updateUser(LoginModel user) async {
    await saveUser(user);
  }

  static Future<bool> isLoggedIn() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(_isLoggedIn) ?? false;
  }

  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString(_userData);

    if (data != null) {
      return jsonDecode(data);
    }

    return null;
  }

  static Future<String?> getUserSrNo() async {
    final user = await getUser();
    return user?['usersrno'];
  }
}

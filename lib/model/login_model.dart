class LoginModel {
  final String userSrNo;
  final String name;
  final String email;
  final String? gender;

  final String regionSrNo;
  final String subRegionSrNo;

  // ACCESS RIGHTS

  final String attendance;

  final String tourPlanRmmView;
  final String tourPlanRmmAdd;

  final String tourPlanYearlyView;
  final String tourPlanYearlyAdd;

  final String customerView;
  final String customerAdd;

  final String enquiryView;
  final String enquiryAdd;

  final String exhibitionView;
  final String exhibitionAdd;

  final String projectsView;
  final String projectsAdd;

  final String vendorEnlistmentView;
  final String vendorEnlistmentAdd;

  final String enquiryfollowupView;
  final String enquiryfollowupAdd;

  final String visitfollowupView;
  final String visitfollowupAdd;

  final String happyCallsView;
  final String happyCallsAdd;

  final String serviceView;
  final String serviceAdd;

  LoginModel({
    required this.userSrNo,
    required this.name,
    required this.email,
    this.gender,
    required this.regionSrNo,
    required this.subRegionSrNo,

    required this.attendance,

    required this.tourPlanRmmView,
    required this.tourPlanRmmAdd,

    required this.tourPlanYearlyView,
    required this.tourPlanYearlyAdd,

    required this.customerView,
    required this.customerAdd,

    required this.enquiryView,
    required this.enquiryAdd,

    required this.exhibitionView,
    required this.exhibitionAdd,

    required this.projectsView,
    required this.projectsAdd,

    required this.vendorEnlistmentView,
    required this.vendorEnlistmentAdd,

    required this.enquiryfollowupView,
    required this.enquiryfollowupAdd,

    required this.visitfollowupView,
    required this.visitfollowupAdd,

    required this.happyCallsView,
    required this.happyCallsAdd,

    required this.serviceView,
    required this.serviceAdd,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'][0];

    return LoginModel(
      userSrNo: data['usersrno'] ?? "",
      name: data['name'] ?? "",
      email: data['email'] ?? "",
      gender: data['gender'],

      regionSrNo: data['region_srno'] ?? "",
      subRegionSrNo: data['subregion_srno'] ?? "",

      attendance: data['attendance'] ?? "n",

      tourPlanRmmView: data['tour_plan_rmm_view'] ?? "n",
      tourPlanRmmAdd: data['tour_plan_rmm_add'] ?? "n",

      tourPlanYearlyView: data['tour_plan_yearly_view'] ?? "n",
      tourPlanYearlyAdd: data['tour_plan_yearly_add'] ?? "n",

      customerView: data['customer_view'] ?? "n",
      customerAdd: data['customer_add'] ?? "n",

      enquiryView: data['enquiry_view'] ?? "n",
      enquiryAdd: data['enquiry_add'] ?? "n",

      exhibitionView: data['exhibition_view'] ?? "n",
      exhibitionAdd: data['exhibition_add'] ?? "n",

      projectsView: data['projects_view'] ?? "n",
      projectsAdd: data['projects_add'] ?? "n",

      vendorEnlistmentView:
          data['vendor_enlistment_view'] ?? "n",

      vendorEnlistmentAdd:
          data['vendor_enlistment_add'] ?? "n",

      enquiryfollowupView:
          data['enquiryfollowup_view'] ?? "n",

      enquiryfollowupAdd:
          data['enquiryfollowup_add'] ?? "n",

      visitfollowupView:
          data['visitfollowup_view'] ?? "n",

      visitfollowupAdd:
          data['visitfollowup_add'] ?? "n",

      happyCallsView:
          data['happy_calls_view'] ?? "n",

      happyCallsAdd:
          data['happy_calls_add'] ?? "n",

      serviceView:
          data['service_view'] ?? "n",

      serviceAdd:
          data['service_add'] ?? "n",
    );
  }
}
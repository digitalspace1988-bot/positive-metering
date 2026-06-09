import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/screens/attendance/attendance_screen.dart';
import 'package:positive_metering/screens/calls/happy_call.dart';
import 'package:positive_metering/screens/customer_master/customer_master.dart';
import 'package:positive_metering/screens/enquiry/enquiry_screen.dart';
import 'package:positive_metering/screens/exhibition/exhibition_visit_plan_screen.dart';
import 'package:positive_metering/screens/expenses/expenses_screen.dart';
import 'package:positive_metering/screens/follow_up/follow_up_screen.dart';
import 'package:positive_metering/screens/plan/lean_plan/lean_plan_screen.dart';
import 'package:positive_metering/screens/login/login_screen.dart';
import 'package:positive_metering/screens/plan/tour_plan/tour_plan_screen.dart';
import 'package:positive_metering/screens/plan/tour_plan_yearly/tour_plan_yearly_screen.dart';
import 'package:positive_metering/screens/project_opportunity/project_opportunity_screen.dart';
import 'package:positive_metering/screens/services/service_call_screen.dart';
import 'package:positive_metering/screens/task/task_screen.dart';
import 'package:positive_metering/screens/vendor_view/vendor_view_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';

class CommonDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const CommonDrawer({super.key, required this.onClose});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  bool isFollowUpExpanded = false;
  Map<String, dynamic>? user;
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await AppPref.getUser();
    setState(() {});
  }

  void _navigate(BuildContext context, String menu) async {
    Navigator.pop(context);

    switch (menu) {
      case "Enquiry":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: EnquiryScreen()),
          (route) => route.isFirst,
        );
        break;

      case "Tour Plan RMM":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: PlanScreen(initialTab: PlanType.tour)),
          (route) => route.isFirst,
        );
        break;
      case "Tour Plan Yearly":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: TourPlanYearlyScreen()),
          (route) => route.isFirst,
        );
        break;

      // case "Lean Plan":
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     AnimatedPageRoute(page: LeanPlanScreen()),
      //   );
      //   break;

      case "Attendance":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: AttendanceScreen()),
          (route) => route.isFirst,
        );
        break;

      case "Service":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: ServiceCallScreen()),
          (route) => route.isFirst,
        );
        break;

      case "Task":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: TaskScreen()),
          (route) => route.isFirst,
        );
        break;
      // case "Expenses":
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     AnimatedPageRoute(page: ExpensesScreen()),
      //     (route) => route.isFirst,
      //   );
      //   break;
      case "Exibition":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: ExhibitionVisitPlanScreen()),
          (route) => route.isFirst,
        );
        break;

      case "Project Opportunity":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: ProjectOpportunityScreen()),
          (route) => route.isFirst,
        );
        break;
      case "Vendor Enlistment":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: VendorViewScreen()),
          (route) => route.isFirst,
        );
        break;
      case "Customer Master":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: CustomerMasterScreen()),
          (route) => route.isFirst,
        );
        break;
      case "Happy Call":
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: HappyCallScreen()),
          (route) => route.isFirst,
        );
        break;

      case "Logout":
        await AppPref.logout();
        Navigator.pushAndRemoveUntil(
          context,
          AnimatedPageRoute(page: const LoginScreen()),
          (route) => false,
        );
        break;
    }
  }

  Widget _followUpItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isFollowUpExpanded = !isFollowUpExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  Icons.update_outlined,
                  size: 26.sp,
                  color: AppColor.textDark,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    "Follow-up",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textDark,
                    ),
                  ),
                ),
                Icon(
                  isFollowUpExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),

        /// CHILD OPTIONS
        if (isFollowUpExpanded) ...[
          if (user?['enquiryfollowup_view'] == "y")
            _subDrawerItem(context, "Enquiry Follow-up", () {
              Navigator.pushAndRemoveUntil(
                context,
                AnimatedPageRoute(page: FollowUpScreen(type: "enquiry")),
                (route) => route.isFirst,
              );
            }),

          if (user?['visitfollowup_view'] == "y")
            _subDrawerItem(context, "Visit Follow-up", () {
              Navigator.pushAndRemoveUntil(
                context,
                AnimatedPageRoute(page: FollowUpScreen(type: "visit")),
                (route) => route.isFirst,
              );
            }),
          // if (user?['projectfollowup_view'] == "y")
          _subDrawerItem(context, "Project Follow-up", () {
            Navigator.pushAndRemoveUntil(
              context,
              AnimatedPageRoute(page: FollowUpScreen(type: "project")),
              (route) => route.isFirst,
            );
          }),
        ],
      ],
    );
  }

  Widget _subDrawerItem(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.only(left: 60.w, top: 10.h, bottom: 10.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColor.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Container(
                width: double.infinity,
                // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(color: AppColor.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// CLOSE ICON
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close,
                            color: AppColor.primaryBlue,
                            size: 25.sp,
                          ),
                        ),
                      ),
                    ),

                    /// LOGO
                    Center(
                      child: Image.asset(
                        'assets/images/Positive-Logo.png',
                        width: 100.w,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColor.black, thickness: 1.h),
              if (user?['tour_plan_rmm_view'] == "y")
                _drawerItem(context, Icons.map_outlined, "Tour Plan RMM"),

              if (user?['tour_plan_yearly_view'] == "y")
                _drawerItem(
                  context,
                  Icons.list_alt_outlined,
                  "Tour Plan Yearly",
                ),

              if (user?['enquiry_view'] == "y")
                _drawerItem(context, Icons.question_answer_outlined, "Enquiry"),

              if (user?['enquiryfollowup_view'] == "y" ||
                  user?['visitfollowup_view'] == "y")
                _followUpItem(context),

              // _drawerItem(context, Icons.list_alt_outlined, "Lean Plan"),
              if (user?['service_view'] == "y")
                _drawerItem(context, Icons.streetview_sharp, "Service"),

              _drawerItem(context, Icons.task_alt_outlined, "Task"),

              if (user?['attendance'] == "y")
                _drawerItem(context, Icons.fingerprint_outlined, "Attendance"),

              // _drawerItem(context, Icons.monetization_on_sharp, "Expenses"),
              if (user?['exhibition_view'] == "y")
                _drawerItem(
                  context,
                  Icons.local_activity_outlined,
                  "Exibition",
                ),

              if (user?['projects_view'] == "y")
                _drawerItem(
                  context,
                  Icons.business_center_outlined,
                  "Project Opportunity",
                ),

              if (user?['vendor_enlistment_view'] == "y")
                _drawerItem(
                  context,
                  Icons.store_mall_directory,
                  "Vendor Enlistment",
                ),

              if (user?['customer_view'] == "y")
                _drawerItem(context, Icons.people_alt_sharp, "Customer Master"),

              if (user?['happy_calls_view'] == "y")
                _drawerItem(context, Icons.call_outlined, "Happy Call"),

              SizedBox(height: 20.h),

              /// LOGOUT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: InkWell(
                  onTap: () => _navigate(context, "Logout"),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: AppColor.primaryRed,
                        size: 24.sp,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () => _navigate(context, title),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 26.sp, color: AppColor.textDark),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

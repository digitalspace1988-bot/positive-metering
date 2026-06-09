import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/dashboard_model.dart';

import 'package:positive_metering/screens/customer_master/add_customer_screen.dart';
import 'package:positive_metering/screens/customer_master/customer_master.dart';
import 'package:positive_metering/screens/enquiry/enquiry_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardModel? dashboard;

  bool isLoading = true;
  String userName = "";

  @override
  void initState() {
    super.initState();
    refreshUserAndLoadDashboard();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final user = await AppPref.getUser();

    setState(() {
      userName = user?['name'] ?? "";
    });
  }

  Future<void> refreshUserAndLoadDashboard() async {
    try {
      final userSrNo = await AppPref.getUserSrNo();

      print("USER SRNO = $userSrNo");

      if (userSrNo == null) {
        setState(() => isLoading = false);
        return;
      }

      final refreshedUser = await ApiService.refreshLoginDetails(
        userSrNo: userSrNo,
      );

      print("REFRESH USER = $refreshedUser");

      if (refreshedUser == null) {
        setState(() => isLoading = false);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Account Disabled"),
            content: const Text(
              "No records found. Your account has been disabled.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  SystemNavigator.pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );

        return;
      }

      await AppPref.updateUser(refreshedUser);

      await loadDashboard();
    } catch (e, s) {
      print("HOME ERROR = $e");
      print(s);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadDashboard() async {
    final userSrNo = await AppPref.getUserSrNo();

    final data = await ApiService.getDashboard(userSrNo: userSrNo ?? "");

    setState(() {
      dashboard = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 60.h,
                      width: 60.h,
                      decoration: BoxDecoration(
                        color: AppColor.primaryRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.exit_to_app_rounded,
                        color: AppColor.primaryRed,
                        size: 30.sp,
                      ),
                    ),

                    SizedBox(height: 18.h),

                    Text(
                      "Exit App?",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textDark,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      "Do you want to exit the app?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColor.grey,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context, false),
                            child: Container(
                              height: 46.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: AppColor.primaryRed),
                              ),
                              child: Text(
                                "No",
                                style: TextStyle(
                                  color: AppColor.primaryRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context, true),
                            child: Container(
                              height: 46.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColor.primaryRed,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },

      child: Scaffold(
        backgroundColor: AppColor.white,
        key: _scaffoldKey,

        drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

        appBar: CommonAppBar(
          scaffoldKey: _scaffoldKey,
          showDrawer: true,
          showAdd: false,
        ),

        body: RefreshIndicator(
          color: AppColor.primaryRed,

          onRefresh: () async {
            await refreshUserAndLoadDashboard();
          },
          child: isLoading
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 300),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// HEADER CARD
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColor.primaryBlue, AppColor.primaryRed],
                          ),
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hi ${userName.isEmpty ? 'User' : userName}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  SizedBox(height: 6.h),

                                  Text(
                                    "Welcome to Positive Metering.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AnimatedPageRoute(
                                    page: const AddCustomerScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Icon(
                                  Icons.person_add_alt_1,
                                  color: AppColor.primaryBlue,
                                  size: 28.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      /// DASHBOARD BLOCKS
                      Wrap(
                        spacing: 14.w,
                        runSpacing: 14.h,
                        children: [
                          if ((dashboard?.customerCount ?? 0) > 0)
                            _dashboardCard(
                              title: "Customers",
                              value: dashboard!.customerCount.toString(),
                              icon: Icons.groups_rounded,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AnimatedPageRoute(
                                    page: const CustomerMasterScreen(),
                                  ),
                                );
                              },
                            ),

                          if ((dashboard?.customerLadleCount ?? 0) > 0)
                            _dashboardCard(
                              title: "Ladle Customers",
                              value: dashboard!.customerLadleCount.toString(),
                              icon: Icons.favorite,
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AnimatedPageRoute(
                                    page: const CustomerMasterScreen(),
                                  ),
                                );
                              },
                            ),

                          if ((dashboard?.enquiryCount ?? 0) > 0)
                            _dashboardCard(
                              title: "Enquiries",
                              value: dashboard!.enquiryCount.toString(),
                              icon: Icons.description,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AnimatedPageRoute(
                                    page: const EnquiryScreen(),
                                  ),
                                );
                              },
                            ),

                          if ((dashboard?.visitPercentage ?? 0) > 0)
                            _dashboardCard(
                              title: "Visit %",
                              value:
                                  "${dashboard!.visitPercentage.toStringAsFixed(1)}%",
                              icon: Icons.location_on,
                              color: Colors.green,
                              onTap: () {},
                            ),
                        ],
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,

      child: Container(
        width: 160.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),

            SizedBox(height: 18.h),

            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textDark,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

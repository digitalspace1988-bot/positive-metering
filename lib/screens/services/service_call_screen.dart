import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/screens/services/client_complaint_screen.dart';
import 'package:positive_metering/screens/services/submit_visit_screen.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class ServiceCallScreen extends StatefulWidget {
  const ServiceCallScreen({super.key});

  @override
  State<ServiceCallScreen> createState() => _ServiceCallScreenState();
}

class _ServiceCallScreenState extends State<ServiceCallScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Service Call",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 16.h),

            /// FILTER ROW
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 24.h),

            /// SERVICE CALL CARD
            const _ServiceCallCard(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // DATE PICKERS
  // ------------------------------------------------------------------

  Future<void> _pickFromDate() async {
    final picked = await _showPicker(fromDate);
    if (picked != null) {
      setState(() {
        fromDate = picked;
        toDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await _showPicker(toDate, first: fromDate);
    if (picked != null) {
      setState(() => toDate = picked);
    }
  }

  Future<DateTime?> _showPicker(DateTime initial, {DateTime? first}) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColor.primaryRed),
          ),
          child: child!,
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // UI WIDGETS
  // ------------------------------------------------------------------

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatter.format(date)),
                  Icon(Icons.calendar_month, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton() {
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: AppColor.primaryRed,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "View",
          style: TextStyle(color: AppColor.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------------
/// SERVICE CALL CARD
/// --------------------------------------------------------------------

class _ServiceCallCard extends StatelessWidget {
  const _ServiceCallCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          AnimatedPageRoute(page: ClientComplaintScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.grey.withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LEFT RED BAR
            Container(
              width: 4.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColor.primaryRed,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Name", "Akanksha Ghotekar"),
                  _infoRow("Product", "ABC"),
                  _infoRow("Issues", "ABC"),

                  SizedBox(height: 10.h),

                  /// ACTION ICONS
                  Row(
                    children: [
                      _iconBox(Icons.remove_red_eye, AppColor.primaryBlue),
                      SizedBox(width: 10.w),
                      _iconBox(Icons.edit, AppColor.primaryBlue),
                      SizedBox(width: 10.w),
                      _iconBox(Icons.call, Colors.green),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  /// SUBMIT VISIT BUTTON
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          AnimatedPageRoute(page: SubmitVisitScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryRed,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "Confirm Visit",
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, color: AppColor.white, size: 16.sp),
    );
  }
}

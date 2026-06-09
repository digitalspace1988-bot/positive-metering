import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/screens/plan/add_tour_plan_screen.dart';
import 'package:positive_metering/screens/plan/mark_visit/mark_visit_screen.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';

import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';
import 'package:table_calendar/table_calendar.dart';

class LeanPlanScreen extends StatefulWidget {
  const LeanPlanScreen({super.key});

  @override
  State<LeanPlanScreen> createState() => _LeanPlanScreenState();
}

class _LeanPlanScreenState extends State<LeanPlanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: true,
        onAddTap: () {
          Navigator.push(context, AnimatedPageRoute(page: AddTourPlanScreen()));
        },
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),

          Text(
            "Lean Plan",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 10.h),

          /// CALENDAR
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: TableCalendar(
              firstDay: DateTime.utc(2000),
              lastDay: DateTime.utc(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.none,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: const Icon(Icons.chevron_left),
                rightChevronIcon: const Icon(Icons.chevron_right),
                titleTextStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 12.sp),
                weekendStyle: TextStyle(fontSize: 12.sp),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColor.primaryBlue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColor.primaryBlue,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(fontSize: 13.sp),
                weekendTextStyle: TextStyle(fontSize: 13.sp),
                outsideTextStyle: TextStyle(
                  fontSize: 13.sp,
                  color: AppColor.grey,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          /// LEAN PLAN BUTTON BAR
          Container(
            width: double.infinity,
            color: AppColor.primaryBlue,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "Lean Plan",
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          /// LIST
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: const [
                _LeanPlanCard(
                  status: "Approved",
                  statusColor: AppColor.primaryRed,
                  showCall: true,
                ),
                _LeanPlanCard(
                  status: "Visit",
                  statusColor: AppColor.primaryBlue,
                  showCall: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// LEAN PLAN CARD

class _LeanPlanCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final bool showCall;

  const _LeanPlanCard({
    required this.status,
    required this.statusColor,
    required this.showCall,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (status == "Approved" || status == "Pending") {
          // Navigator.push(context, AnimatedPageRoute(page: MarkVisitScreen()));
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// LEFT STATUS STRIP
            Container(
              width: 5.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Company Name: xyz",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.sp,
                          color: AppColor.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Region: Nashik",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColor.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// RIGHT ACTIONS
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (showCall) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Icon(
                            Icons.call,
                            color: AppColor.white,
                            size: 18.sp,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_double_arrow_right_sharp,
                          color: Colors.green,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

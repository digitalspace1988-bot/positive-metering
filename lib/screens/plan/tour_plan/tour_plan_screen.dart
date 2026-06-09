import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/tour_plan_model.dart';
import 'package:positive_metering/screens/plan/add_tour_plan_screen.dart';
import 'package:positive_metering/screens/plan/add_tour_plan_yearly_screen.dart';
import 'package:positive_metering/screens/plan/mark_visit/mark_visit_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';
import 'package:table_calendar/table_calendar.dart';

enum PlanType { tour, lean }

class PlanScreen extends StatefulWidget {
  final PlanType initialTab;

  const PlanScreen({super.key, required this.initialTab});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TourPlanModel> tourList = [];
  bool isLoading = false;
  Map<String, dynamic>? user;

  late PlanType selectedType;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> fetchTourPlan() async {
    setState(() => isLoading = true);

    final userSrNo = await AppPref.getUserSrNo();

    final data = await ApiService.getTourPlan(
      userSrNo: userSrNo ?? "",
      billDate: formatDate(_selectedDay),
      tourType: selectedType == PlanType.tour ? "Tour" : "Lean",
    );

    setState(() {
      tourList = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialTab;
    loadUser();
    fetchTourPlan();
  }

  Future<void> loadUser() async {
    user = await AppPref.getUser();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isTour = selectedType == PlanType.tour;

    return Scaffold(
      backgroundColor: AppColor.white,
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: user?['tour_plan_rmm_add'] == "y",
        onAddTap: () {
          Navigator.push(
            context,
            AnimatedPageRoute(page: const AddTourPlanScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10.h),

            /// TITLE
            Text(
              isTour ? "Tour Plan" : "Lean Plan",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 10.h),

            /// TOGGLE
            _planToggle(),

            SizedBox(height: 10.h),

            /// CALENDAR
            _calendar(),

            SizedBox(height: 12.h),

            /// BUTTON BAR
            _planBar(isTour),

            /// LIST
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              children: isLoading
                  ? [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ]
                  : tourList.isEmpty
                  ? [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Text("No Data Found"),
                        ),
                      ),
                    ]
                  : tourList.map((item) {
                      return _PlanCard(
                        companyName: item.companyName,
                        regionName: item.regionName,
                        name: item.name,
                        status: item.status,
                        tourPlanSrNo: item.tourPlanSrNo,
                        color: item.status == "Approved"
                            ? AppColor.green
                            : item.status == "Rejected"
                            ? Colors.red
                            : AppColor.primaryBlue,
                        comments: {
                          "Kajal": item.kajal ?? "",
                          "Ravi": item.ravi ?? "",
                          "Malhar": item.malhar ?? "",
                        },
                      );
                    }).toList(),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // TOGGLE
  // ------------------------------------------------------------------

  Widget _planToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColor.lightGrey,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          _toggleItem("Tour", PlanType.tour),
          _toggleItem("Lean", PlanType.lean),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, PlanType type) {
    final isSelected = selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => selectedType = type);
          fetchTourPlan();
        },
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColor.white : AppColor.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // CALENDAR
  // ------------------------------------------------------------------

  Widget _calendar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: TableCalendar(
        firstDay: DateTime.utc(2000),
        lastDay: DateTime.utc(2100),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.none,
        rowHeight: 36.h,
        daysOfWeekHeight: 18.h,

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          fetchTourPlan();
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
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
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // BUTTON BAR
  // ------------------------------------------------------------------

  Widget _planBar(bool isTour) {
    return Container(
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
            isTour ? "Tour Plan" : "Lean Plan",
            style: TextStyle(
              color: AppColor.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String status;
  final Color color;
  final bool showCall;
  final Map<String, String>? comments;
  final String companyName;
  final String regionName;
  final String tourPlanSrNo;
  final String name;

  const _PlanCard({
    required this.status,
    required this.color,
    this.showCall = false,
    this.comments,
    required this.companyName,
    required this.regionName,
    required this.tourPlanSrNo,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> allCommenters = ["Kajal", "Ravi", "Malhar"];

    final validComments = comments?.entries
        .where((e) => e.value.trim().isNotEmpty)
        .toList();

    return InkWell(
      onTap: () {
        if (status == "Approved" || status == "Pending") {
          Navigator.push(
            context,
            AnimatedPageRoute(
              page: MarkVisitScreen(tourPlanSrNo: tourPlanSrNo),
            ),
          );
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
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),

            /// CONTENT
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Company Name: ${companyName}",
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
                          Icons.person_outline,
                          size: 16.sp,
                          color: AppColor.primaryRed,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColor.primaryRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                          "Region: ${regionName}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColor.grey,
                          ),
                        ),
                      ],
                    ),

                    /// COMMENT SECTION (ALWAYS SHOW NAMES)
                    SizedBox(height: 8.h),

                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColor.lightGrey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: allCommenters.map((name) {
                          final commentText = comments?[name]?.trim();

                          return Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.textDark,
                                ),
                                children: [
                                  TextSpan(
                                    text: "$name: ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        (commentText != null &&
                                            commentText.isNotEmpty)
                                        ? commentText
                                        : "—",
                                    style: TextStyle(
                                      color: AppColor.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// RIGHT SIDE (STATUS + CALL)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Column(
                children: [
                  /// STATUS BADGE
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// CALL OPTION (LEAN → APPROVED ONLY)
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

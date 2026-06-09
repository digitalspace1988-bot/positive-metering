import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/tour_plan_yearly_model.dart';
import 'package:positive_metering/screens/plan/add_tour_plan_yearly_screen.dart';
import 'package:positive_metering/screens/plan/mark_visit/mark_visit_screen.dart';
import 'package:positive_metering/screens/plan/mark_visit/yearly_visit_detail.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class TourPlanYearlyScreen extends StatefulWidget {
  const TourPlanYearlyScreen({super.key});

  @override
  State<TourPlanYearlyScreen> createState() => _TourPlanYearlyScreenState();
}

class _TourPlanYearlyScreenState extends State<TourPlanYearlyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TourPlanYearlyModel> planList = [];
  bool isLoading = false;

  Map<String, dynamic>? user;

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> fetchPlans() async {
    setState(() => isLoading = true);

    final userSrNo = await AppPref.getUserSrNo();

    final data = await ApiService.getTourPlanYearly(
      userSrNo: userSrNo ?? "",
      tourType: selectedType,
      fromDate: formatDate(fromDate),
      toDate: formatDate(toDate),
    );

    setState(() {
      planList = data;
      isLoading = false;
    });
  }

  String selectedType = "Tour";
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  bool showResult = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    fetchPlans();
  }

  Future<void> loadUser() async {
    user = await AppPref.getUser();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      backgroundColor: AppColor.white,
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: user?['tour_plan_yearly_add'] == "y",
        onAddTap: () {
          Navigator.push(
            context,
            AnimatedPageRoute(page: const AddTourPlanYearlyScreen()),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Tour Plan Yearly",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 20.h),

            /// TYPE DROPDOWN
            _label("Tour Type"),
            _dropdown(),

            SizedBox(height: 18.h),

            /// DATE ROW
            Row(
              children: [
                _dateBox(
                  label: "From Date",
                  date: fromDate,
                  onTap: _pickFromDate,
                ),
                SizedBox(width: 12.w),
                _dateBox(label: "To Date", date: toDate, onTap: _pickToDate),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 24.h),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : planList.isEmpty
                  ? const Center(child: Text("No Data Found"))
                  : ListView.separated(
                      itemCount: planList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = planList[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              AnimatedPageRoute(
                                page: YearlyVisitDetail(
                                  tourPlanSrNo: item.tourPlanSrNo,
                                ),
                              ),
                            );
                          },
                          child: _planCard({
                            "company": item.companyName,
                            "name": item.name,
                            "region": item.regionName,
                            "status": item.status,
                            "type": item.type,
                            "comments": {
                              "Kajal": item.kajal ?? "",
                              "Ravi": item.ravi ?? "",
                              "Malhar": item.malhar ?? "",
                            },
                          }),
                        );
                      },
                    ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  /// DATE PICKERS

  Future<void> _pickFromDate() async {
    final selected = await _showDatePicker(fromDate, DateTime(2000));
    if (selected != null) {
      setState(() {
        fromDate = selected;
        toDate = selected;
      });
    }
  }

  Future<void> _pickToDate() async {
    final selected = await _showDatePicker(toDate, fromDate);
    if (selected != null) {
      setState(() => toDate = selected);
    }
  }

  Future<DateTime?> _showDatePicker(DateTime initial, DateTime first) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
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
  /// UI WIDGETS

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _dropdown() {
    final items = ["Tour", "Lean"];

    return Container(
      height: 46.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() => selectedType = v!);
            fetchPlans();
          },
        ),
      ),
    );
  }

  Widget _dateBox({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          SizedBox(height: 8.h),
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
                  Text(_dateFormat.format(date)),
                  const Icon(Icons.calendar_month),
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
      padding: EdgeInsets.only(top: 26.h),
      child: InkWell(
        onTap: fetchPlans,
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
            style: TextStyle(
              color: AppColor.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  /// PLAN CARD

  Widget _planCard(Map<String, dynamic> data) {
    final List<String> allCommenters = ["Kajal", "Ravi", "Malhar"];
    final statusColor = data["status"] == "Approved"
        ? AppColor.green
        : data["status"] == "Rejected"
        ? Colors.red
        : Colors.black;
    final Map<String, String> comments =
        (data["comments"] as Map<String, String>?) ?? {};

    {
      final isTour = data["type"] == "Tour";
      final chipColor = isTour ? AppColor.primaryRed : AppColor.primaryBlue;

      return Container(
        padding: EdgeInsets.all(14.w),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data["company"]!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                /// TYPE CHIP (TOP RIGHT)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    data["type"]!,
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
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
                Text("Region: ${data["region"]}"),
              ],
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
                    "${data["name"]}",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColor.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
                  final text = comments[name]?.trim();

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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: (text != null && text.isNotEmpty)
                                ? text
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

            SizedBox(height: 10.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// STATUS
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    data["status"]!,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),

                /// CALL ICON → ONLY FOR LEAN
                if (!isTour)
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
            ),
          ],
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

import 'attendance_regularize_form.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  List<Map<String, dynamic>> reportList = [];
  bool isLoading = false;
  String? usersrno;

  String _extractDay(String dateStr) => dateStr.split("-")[0];

  String _extractMonth(String dateStr) {
    const monthNames = {
      "01": "JAN",
      "02": "FEB",
      "03": "MAR",
      "04": "APR",
      "05": "MAY",
      "06": "JUN",
      "07": "JUL",
      "08": "AUG",
      "09": "SEP",
      "10": "OCT",
      "11": "NOV",
      "12": "DEC",
    };
    return monthNames[dateStr.split("-")[1]] ?? "--";
  }

  String _extractTime(String str) {
    if (str.isEmpty) return "--:--";
    return str.split(" ").last;
  }

  Color _getColor(String status) {
    if (status.toLowerCase().contains("present")) return Colors.green;
    if (status.toLowerCase().contains("half")) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    usersrno = await AppPref.getUserSrNo();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    if (usersrno == null) return;

    setState(() => isLoading = true);

    final data = await ApiService.getAttendanceReport(
      usersrno: usersrno!,
      fromDate: _formatter.format(fromDate),
      toDate: _formatter.format(toDate),
    );

    setState(() {
      reportList = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: const CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Center(
              child: Text(
                "Attendance Report",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 20.h),

            /// FILTER
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
                SizedBox(width: 12.w),
                GestureDetector(onTap: _fetchReport, child: _viewButton()),
              ],
            ),

            SizedBox(height: 20.h),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportList.isEmpty
                  ? const Center(child: Text("No data found"))
                  : ListView.builder(
                      itemCount: reportList.length,
                      itemBuilder: (context, index) {
                        final item = reportList[index];

                        return _AttendanceCard(
                          day: _extractDay(item["date"]),
                          month: _extractMonth(item["date"]),
                          color: Colors.red, // no status in API
                          punchIn: _extractTime(item["punch_in_time"] ?? ""),
                          punchOut: _extractTime(item["punch_out_time"] ?? ""),
                          srno: item["srno"],
                          attendanceRegularize:
                              item["attendance_regularize"] ?? "",
                          onRefresh: _fetchReport, // 👈 IMPORTANT
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

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 44.h,
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
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.primaryRed,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: const Text("View", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await _showPicker(fromDate, DateTime(2000));
    if (picked != null) {
      setState(() {
        fromDate = picked;
        if (toDate.isBefore(picked)) toDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await _showPicker(toDate, fromDate);
    if (picked != null) setState(() => toDate = picked);
  }

  Future<DateTime?> _showPicker(DateTime initial, DateTime first) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final String day;
  final String month;
  final Color color;
  final String punchIn;
  final String punchOut;
  final String srno;
  final String attendanceRegularize;
  final Function()? onRefresh;

  const _AttendanceCard({
    required this.day,
    required this.month,
    required this.color,
    required this.punchIn,
    required this.punchOut,
    required this.srno,
    required this.attendanceRegularize,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool isApproved = attendanceRegularize == "Approved";
    final bool isRequested = attendanceRegularize == "Request";

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          /// DATE BADGE
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          /// PUNCH IN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punchIn,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Punch In",
                  style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
                ),
              ],
            ),
          ),

          /// PUNCH OUT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punchOut,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Punch Out",
                  style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
                ),
              ],
            ),
          ),

          /// REGULARIZE
          GestureDetector(
            onTap: isApproved
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceRegularizeForm(srno: srno),
                      ),
                    );

                    if (result == true && onRefresh != null) {
                      onRefresh!();
                    }
                  },
            child: Column(
              children: [
                Icon(
                  Icons.edit_calendar,
                  color: isApproved
                      ? Colors.green
                      : isRequested
                      ? Colors.orange
                      : AppColor.primaryRed,
                ),
                SizedBox(height: 4.h),
                Text(
                  isApproved
                      ? "Approved"
                      : isRequested
                      ? "Request Sent"
                      : "Not Requested",
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

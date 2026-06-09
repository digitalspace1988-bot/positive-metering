import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/screens/expenses/add_expenses_screen.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String showEntries = "10";

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
          Navigator.push(context, AnimatedPageRoute(page: AddExpensesScreen()));
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Center(
              child: Text(
                "Expenses",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 16.h),

            /// DATE FILTER
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 20.h),

            Divider(color: AppColor.grey.withOpacity(0.4)),

            SizedBox(height: 10.h),

            /// SHOW ENTRIES + SEARCH
            Row(
              children: [
                Row(
                  children: [
                    Text("Show ", style: TextStyle(fontSize: 13.sp)),
                    _smallDropdown(showEntries, [
                      "10",
                      "25",
                      "50",
                    ], (v) => setState(() => showEntries = v)),
                    Text(" entries", style: TextStyle(fontSize: 13.sp)),
                  ],
                ),
                const Spacer(),
                _searchBox(),
              ],
            ),

            SizedBox(height: 16.h),

            /// LIST
            Expanded(child: ListView(children: const [_ExpenseCard()])),
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

  Widget _smallDropdown(
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      height: 32.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 36.h,
      width: 130.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18.sp),
          SizedBox(width: 6.w),
          const Expanded(child: Text("Search")),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------------
/// EXPENSE CARD
/// ------------------------------------------------------------------

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          /// LEFT RED BAR
          Container(
            width: 4.w,
            height: 90.h,
            decoration: BoxDecoration(
              color: AppColor.primaryRed,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Type: Cash", style: TextStyle(fontSize: 13.sp)),
                  SizedBox(height: 4.h),
                  Text("Date: 25-01-2026", style: TextStyle(fontSize: 13.sp)),
                  SizedBox(height: 4.h),
                  Text("Amount: 5000.00", style: TextStyle(fontSize: 13.sp)),
                  SizedBox(height: 4.h),
                  Text("Description: xyz", style: TextStyle(fontSize: 13.sp)),
                ],
              ),
            ),
          ),

          /// ACTIONS
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Column(
              children: [
                Text(
                  "Action",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    _actionIcon(Icons.remove_red_eye, AppColor.primaryRed),
                    SizedBox(width: 6.w),
                    _actionIcon(Icons.edit, AppColor.primaryBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, size: 16.sp, color: AppColor.white),
    );
  }
}

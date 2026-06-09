import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String? product;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: const CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            Center(
              child: Text(
                "Service History",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 20.h),

            /// FILTERS
            Row(
              children: [
                _dateBox("From Date", fromDate, (d) {
                  setState(() => fromDate = d);
                }),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, (d) {
                  setState(() => toDate = d);
                }),
              ],
            ),

            SizedBox(height: 16.h),

            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    "Select the Products",
                    product,
                    (v) => setState(() => product = v),
                  ),
                ),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 14.h),

            /// DIVIDER
            Divider(color: AppColor.grey.withOpacity(0.5)),

            /// SHOW + SEARCH
            Row(
              children: [
                Text("Show", style: TextStyle(fontSize: 13.sp)),
                SizedBox(width: 6.w),
                _entriesDropdown(),
                SizedBox(width: 6.w),
                Text("entries", style: TextStyle(fontSize: 13.sp)),
                const Spacer(),
                _searchBox(),
              ],
            ),

            SizedBox(height: 16.h),

            /// LIST
            Expanded(child: ListView(children: const [_ServiceHistoryCard()])),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // UI COMPONENTS
  // ------------------------------------------------------------------

  Widget _dateBox(String label, DateTime? date, Function(DateTime) onPicked) {
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
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColor.primaryRed,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) onPicked(picked);
            },
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
                  Text(
                    date == null ? "" : _formatter.format(date),
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  const Icon(Icons.calendar_month),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String hint, String? value, Function(String?) onChanged) {
    final items = ["Product 1", "Product 2", "Product 3"];

    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _viewButton() {
    return Container(
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
    );
  }

  Widget _entriesDropdown() {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: "10",
          items: const [
            DropdownMenuItem(value: "10", child: Text("10")),
            DropdownMenuItem(value: "25", child: Text("25")),
          ],
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 32.h,
      width: 120.w,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 16),
          SizedBox(width: 6.w),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------------
/// SERVICE HISTORY CARD
/// ------------------------------------------------------------------

class _ServiceHistoryCard extends StatelessWidget {
  const _ServiceHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Motor Diagnostic & Repair",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10.h),
          _infoRow("Service Date", "30-01-2026"),
          _infoRow("Customer Name", "Vinod Takekar"),
          _infoRow("Customer Phone", "9822090099"),
          _infoRow("Products", "Dosing Pump"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text("$label :", style: TextStyle(fontSize: 13.sp)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

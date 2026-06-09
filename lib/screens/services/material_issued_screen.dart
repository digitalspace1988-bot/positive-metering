import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/screens/services/add_material_issued_screen.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class MaterialIssuedScreen extends StatefulWidget {
  const MaterialIssuedScreen({super.key});

  @override
  State<MaterialIssuedScreen> createState() => _MaterialIssuedScreenState();
}

class _MaterialIssuedScreenState extends State<MaterialIssuedScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String issuedTo = "ALL";
  String showEntries = "10";

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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Materiel Issued",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 16.h),

            /// FILTER ROW 1
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
              ],
            ),

            SizedBox(height: 16.h),

            /// FILTER ROW 2
            Row(
              children: [
                Expanded(
                  child: _dropdownBox("Issued To", issuedTo, [
                    "ALL",
                    "Ketan",
                    "XYZ",
                  ], (v) => setState(() => issuedTo = v)),
                ),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 16.h),

            Divider(color: AppColor.grey.withOpacity(0.4)),

            SizedBox(height: 10.h),

            /// SHOW ENTRIES + SEARCH
            Row(
              children: [
                Row(
                  children: [
                    Text(
                      "Show ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _smallDropdown(showEntries, [
                      "10",
                      "25",
                      "50",
                    ], (v) => setState(() => showEntries = v)),
                    Text(
                      " entries",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _searchBox(),
              ],
            ),

            SizedBox(height: 16.h),

            /// LIST
            Expanded(child: ListView(children: const [_MaterialIssuedCard()])),

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
  // UI HELPERS
  // ------------------------------------------------------------------

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
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

  Widget _dropdownBox(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp)),
        SizedBox(height: 6.h),
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColor.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _viewButton() {
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
          onChanged: (val) => onChanged(val!),
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
/// MATERIAL ISSUED CARD
/// ------------------------------------------------------------------

class _MaterialIssuedCard extends StatelessWidget {
  const _MaterialIssuedCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AnimatedPageRoute(page: AddMaterialIssuedScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.grey.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            /// LEFT RED STRIP
            Container(
              width: 4.w,
              height: 110.h,
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
                  _row("Material Issued Date :", "29-01-2026"),
                  _row("Customer Name :", "Vinod Takekar"),
                  _row("Customer Phone :", "9822090099"),
                  _row("Products :", "Dosing Pump"),
                  _row("Assign To :", "Ketan"),

                  SizedBox(height: 10.h),

                  Row(
                    children: [
                      _iconBox(Icons.remove_red_eye, AppColor.primaryRed),
                      SizedBox(width: 10.w),
                      _iconBox(Icons.edit, AppColor.primaryBlue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13.sp)),
          ),
          Text(value, style: TextStyle(fontSize: 13.sp)),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/screens/vendor_view/vendor_registration_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class VendorViewScreen extends StatefulWidget {
  const VendorViewScreen({super.key});

  @override
  State<VendorViewScreen> createState() => _VendorViewScreenState();
}

class _VendorViewScreenState extends State<VendorViewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String status = "ALL";
  String companyName = "ALL";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      /// APP BAR
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: user?['vendor_enlistment_add'] == "y",
        onAddTap: () {
          Navigator.push(
            context,
            AnimatedPageRoute(page: VendorRegistrationScreen()),
          );
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
                "Vendor Enlistment Details",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 16.h),

            /// DATE FILTER ROW
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
              ],
            ),

            SizedBox(height: 16.h),

            /// STATUS + COMPANY NAME
            Row(
              children: [
                _dropdownBox("Status", status, [
                  "ALL",
                  "Active",
                  "Inactive",
                ], (v) => setState(() => status = v)),
                SizedBox(width: 12.w),
                _dropdownBox("Company Name", companyName, [
                  "ALL",
                  "Bhagwati foundation",
                  "XYZ",
                ], (v) => setState(() => companyName = v)),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(color: AppColor.black),
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
                    _smallDropdown("10", ["10", "25", "50"], (_) {}),
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
            const _VendorCard(),
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
    if (picked != null) setState(() => toDate = picked);
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

  Widget _dropdownBox(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
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
                onChanged: (v) => onChanged(v!),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
/// VENDOR CARD
/// ------------------------------------------------------------------

class _VendorCard extends StatelessWidget {
  const _VendorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey),
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
                _row("Date :", "29-01-2026"),
                _row("Company Name :", "Bhagwati foundation"),
                _row("Phone No. :", "9822090099"),
                _row("Products :", "Dosing Pump"),
                _row("Address :", "xyz, Nashik,422222"),
                _row("Status :", "XYZ"),
                SizedBox(height: 10.h),

                /// ACTION BUTTONS
                Row(
                  children: [
                    _icon(Icons.remove_red_eye, AppColor.primaryRed),
                    SizedBox(width: 10.w),
                    _icon(Icons.edit, AppColor.primaryBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, Color color) {
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

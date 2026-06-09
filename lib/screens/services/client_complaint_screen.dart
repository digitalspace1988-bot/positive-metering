import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/screens/services/material_issued_screen.dart';
import 'package:positive_metering/screens/services/service_history_screen.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ClientComplaintScreen extends StatefulWidget {
  const ClientComplaintScreen({super.key});

  @override
  State<ClientComplaintScreen> createState() => _ClientComplaintScreenState();
}

class _ClientComplaintScreenState extends State<ClientComplaintScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String? name;
  String? product;

  final TextEditingController issueCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: const CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: false,
      ),

      /// FIXED BUTTONS
      bottomNavigationBar: _actionButtons(),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Text(
              "Service Complaint",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Date"),
                      _dateField(),

                      SizedBox(height: 18.h),
                      _label("Name"),
                      _dropdown(
                        "Select the Region",
                        name,
                        (v) => setState(() => name = v),
                      ),

                      SizedBox(height: 18.h),
                      _label("Products"),
                      _dropdown(
                        "Select the Products",
                        product,
                        (v) => setState(() => product = v),
                      ),

                      SizedBox(height: 18.h),
                      _label("Issues"),
                      _textField(issueCtrl, "Enter Issue"),

                      SizedBox(height: 18.h),
                      _label("Comments"),
                      _textField(commentsCtrl, "Description"),

                      SizedBox(height: 26.h),

                      /// EXTRA ACTION BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: _outlineButton(
                              "Material Issued",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AnimatedPageRoute(
                                    page: MaterialIssuedScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _outlineButton(
                              "Service History",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AnimatedPageRoute(
                                    page: ServiceHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // UI HELPERS
  // ------------------------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        height: 46.h,
        margin: EdgeInsets.only(top: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColor.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? "Select Date"
                  : _formatter.format(selectedDate!),
              style: TextStyle(fontSize: 14.sp),
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, Function(String?) onChanged) {
    final items = ["Option 1", "Option 2", "Option 3"];

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

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      height: 80.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: null,
        validator: (value) {
          if (controller == commentsCtrl &&
              (value == null || value.trim().isEmpty)) {
            return "Comments are required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _outlineButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColor.primaryRed),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: AppColor.primaryRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // DATE PICKER
  // ------------------------------------------------------------------

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ------------------------------------------------------------------
  // ACTION BUTTONS
  // ------------------------------------------------------------------

  Widget _actionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 50.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Complaint Saved")),
                  );

                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: AppColor.primaryBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Text(
                "Reset",
                style: TextStyle(
                  color: AppColor.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

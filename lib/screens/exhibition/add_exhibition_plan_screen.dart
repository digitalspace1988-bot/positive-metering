import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddExhibitionPlanScreen extends StatefulWidget {
  const AddExhibitionPlanScreen({super.key});

  @override
  State<AddExhibitionPlanScreen> createState() =>
      _AddExhibitionPlanScreenState();
}

class _AddExhibitionPlanScreenState extends State<AddExhibitionPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  DateTime? tentativeDate;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  final TextEditingController exhibitionCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();

  String? personType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,

      /// APP BAR
      appBar: const CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: false,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            /// TITLE
            Text(
              "Add Exhibition Plan",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 20.h),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Date"),
                      _dateField(
                        selectedDate,
                        "Select Date",
                        (d) => setState(() => selectedDate = d),
                      ),

                      SizedBox(height: 18.h),
                      _label("Exhibition Name"),
                      _textField(exhibitionCtrl, "Enter Name"),

                      SizedBox(height: 18.h),
                      _label("Location"),
                      _textField(locationCtrl, "Enter the Location"),

                      SizedBox(height: 18.h),
                      _label("Tentative Date"),
                      _dateField(
                        tentativeDate,
                        "Select Date",
                        (d) => setState(() => tentativeDate = d),
                      ),

                      SizedBox(height: 18.h),
                      _label("Comments"),
                      _commentsField(),

                      SizedBox(height: 18.h),
                      _label("Person Type"),
                      _dropdown(
                        "Select the Type",
                        personType,
                        (v) => setState(() => personType = v),
                      ),

                      SizedBox(height: 30.h),

                      /// ACTION BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              text: "Save",
                              color: AppColor.primaryRed,
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _actionButton(
                              text: "Reset",
                              color: AppColor.primaryBlue,
                              onTap: _resetForm,
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

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      height: 46.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget _commentsField() {
    return Container(
      height: 80.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextFormField(
        controller: commentsCtrl,
        maxLines: null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Comments are required";
          }
          return null;
        },
        decoration: const InputDecoration(
          hintText: "Description",
          border: InputBorder.none,
          errorStyle: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _dateField(DateTime? date, String hint, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () => _pickDate(date, onPicked),
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
              date == null ? hint : _formatter.format(date),
              style: TextStyle(fontSize: 14.sp),
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, Function(String?) onChanged) {
    final items = ["Visitor", "Exhibitor", "Vendor"];

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

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: AppColor.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // LOGIC
  // ------------------------------------------------------------------

  Future<void> _pickDate(DateTime? current, Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
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

    if (picked != null) onPicked(picked);
  }

  void _resetForm() {
    setState(() {
      selectedDate = null;
      tentativeDate = null;
      personType = null;
      exhibitionCtrl.clear();
      locationCtrl.clear();
      commentsCtrl.clear();
    });
  }
}

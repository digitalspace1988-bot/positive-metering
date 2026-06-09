import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  DateTime? selectedDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String? expenseType;
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();

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
              "Add Expenses",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 20.h),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DATE
                    _label("Date"),
                    _dateField(),

                    SizedBox(height: 18.h),

                    /// EXPENSE TYPE
                    _label("Expenses Type"),
                    _dropdown(
                      "Select the type",
                      expenseType,
                      (v) => setState(() => expenseType = v),
                    ),

                    SizedBox(height: 18.h),

                    /// AMOUNT
                    _label("Amount"),
                    _textField(
                      amountCtrl,
                      "Enter the Amount",
                      keyboardType: TextInputType.number,
                    ),

                    SizedBox(height: 18.h),

                    /// COMMENTS
                    _label("Comments"),
                    _commentsField(),

                    SizedBox(height: 18.h),

                    /// IMAGE PICKER
                    GestureDetector(
                      onTap: _openCamera,
                      child: Container(
                        height: 110.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.lightGrey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColor.grey.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16.w),
                              child: Text(
                                "Click the photo of an\nIssues",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColor.textDark,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20.w),
                              child: Container(
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryBlue,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: AppColor.white,
                                  size: 28.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: _onSubmit,
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColor.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------

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
    final items = ["Travel", "Food", "Accommodation", "Other"];

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

  Widget _textField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        keyboardType: keyboardType,
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
      child: TextField(
        controller: commentsCtrl,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: "Description",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // LOGIC
  // --------------------------------------------------

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

  void _openCamera() {
    // integrate image_picker / camera here
  }

  void _onSubmit() {
    Navigator.pop(context); // back to expenses list
  }
}

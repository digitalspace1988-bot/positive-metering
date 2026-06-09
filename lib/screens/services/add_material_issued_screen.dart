import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddMaterialIssuedScreen extends StatefulWidget {
  const AddMaterialIssuedScreen({super.key});

  @override
  State<AddMaterialIssuedScreen> createState() =>
      _AddMaterialIssuedScreenState();
}

class _AddMaterialIssuedScreenState extends State<AddMaterialIssuedScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String? customerName;
  String? issuedTo;
  String? material;
  final TextEditingController qtyCtrl = TextEditingController();
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
      bottomNavigationBar: _actionButtons(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Text(
              "Material Issued",
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
                      _label("Customer Name"),
                      _dropdown(
                        "Customer Name",
                        customerName,
                        (v) => setState(() => customerName = v),
                      ),

                      SizedBox(height: 18.h),
                      _label("Issued To"),
                      _dropdown(
                        "Select",
                        issuedTo,
                        (v) => setState(() => issuedTo = v),
                      ),

                      SizedBox(height: 22.h),

                      /// MATERIAL TABLE
                      _materialTable(),

                      SizedBox(height: 12.h),

                      /// ADD MORE
                      _addMoreBtn(),

                      SizedBox(height: 20.h),
                      _label("Comments"),
                      _textField(commentsCtrl, "Description"),
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

  // --------------------------------------------------
  // UI COMPONENTS
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
          if (value == null || value.trim().isEmpty) {
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

  // --------------------------------------------------
  // MATERIAL TABLE
  // --------------------------------------------------

  Widget _materialTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            decoration: BoxDecoration(
              color: AppColor.primaryRed,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            child: Row(
              children: [
                _headerCell("Material Issued"),
                _headerCell("Required\nQTY"),
              ],
            ),
          ),

          /// ROW
          Row(
            children: [
              _bodyCell(
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text("Select"),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "Item1", child: Text("Item1")),
                      DropdownMenuItem(value: "Item2", child: Text("Item2")),
                    ],
                    onChanged: (v) {},
                  ),
                ),
              ),
              _bodyCell(
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _bodyCell(Widget child) {
    return Expanded(
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColor.grey),
            right: BorderSide(color: AppColor.grey),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _addMoreBtn() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColor.primaryRed,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        "Add More",
        style: TextStyle(color: AppColor.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  // --------------------------------------------------
  // ACTION BUTTONS
  // --------------------------------------------------

  Widget _actionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 50.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Material Issued Saved",
                        style: TextStyle(color: AppColor.white),
                      ),
                      backgroundColor: AppColor.primaryRed,
                    ),
                  );
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

  // --------------------------------------------------
  // DATE PICKER
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
}

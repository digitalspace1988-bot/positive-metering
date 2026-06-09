import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/utils/app_colors.dart';

class AddCustomerPopup extends StatefulWidget {
  const AddCustomerPopup({super.key});

  @override
  State<AddCustomerPopup> createState() => _AddCustomerPopupState();
}

class _AddCustomerPopupState extends State<AddCustomerPopup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();

  String? customerType;
  String? group;

  DateTime? birthDate;

  final customerTypes = ["OEM", "Consultant", "User", "Contractor EPC"];

  final groups = [
    "Water",
    "Oil & Gas",
    "Chemicals",
    "Consumer",
    "Food",
    "Beverages",
    "Textile",
    "Construction",
  ];

  Widget _field({
    required String hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,

        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(10.r),
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

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
      setState(() => birthDate = picked);
    }
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickBirthDate,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.grey),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              birthDate == null
                  ? "Birth Date"
                  : "${birthDate!.day.toString().padLeft(2, '0')}-"
                        "${birthDate!.month.toString().padLeft(2, '0')}-"
                        "${birthDate!.year}",
              style: TextStyle(
                fontSize: 16.sp,
                color: birthDate == null
                    ? AppColor.textDark
                    : AppColor.textDark,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                "Add New Customer",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 16.h),

              _field(hint: "Company Name"),

              _field(
                hint: "Name *",
                controller: nameCtrl,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),

              _field(hint: "Mobile Number"),
              _dateField(),
              _field(hint: "Landline Number"),
              _field(hint: "Email Address"),
              _field(hint: "Website"),
              _field(hint: "Designation"),
              _field(hint: "Address Details"),
              _field(hint: "Sub Region"),

              _dropdown(
                hint: "Customer Type",
                value: customerType,
                items: customerTypes,
                onChanged: (v) => setState(() => customerType = v),
              ),

              _dropdown(
                hint: "Group",
                value: group,
                items: groups,
                onChanged: (v) => setState(() => group = v),
              ),

              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryRed,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, nameCtrl.text.trim());
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryBlue,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35.h),
            ],
          ),
        ),
      ),
    );
  }
}

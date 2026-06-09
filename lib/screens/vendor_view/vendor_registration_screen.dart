import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/add_customer_popup.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String? customerName;
  String? product;
  String? status;

  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();

  final List<String> customers = [
    "Add New",
    "Customer A",
    "Customer B",
    "Customer C",
  ];

  Future<void> _openAddCustomerPopup() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => const AddCustomerPopup(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        customerName = result;
      });
    }
  }

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
            SizedBox(height: 12.h),

            /// TITLE
            Text(
              "Vendor Registration",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),

            /// FORM
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
                      _label("Company Name"),
                      _textField(companyCtrl, "Enter Company Name"),

                      SizedBox(height: 18.h),
                      _label("Customer Name"),
                      _dropdown(
                        "Select Customer",
                        customers.contains(customerName) ? customerName : null,
                        (v) {
                          if (v == "Add New") {
                            _openAddCustomerPopup();
                          } else {
                            setState(() => customerName = v);
                          }
                        },
                        items: customers,
                        displayValue: customerName,
                      ),

                      SizedBox(height: 18.h),
                      _label("Product List"),
                      _dropdown(
                        "Select the Tour Type",
                        product,
                        (v) => setState(() => product = v),
                      ),

                      SizedBox(height: 18.h),
                      _label("Address"),
                      _textField(addressCtrl, "Enter Address"),

                      SizedBox(height: 18.h),
                      _label("Mobile No"),
                      _textField(mobileCtrl, "Enter Mobile No."),

                      SizedBox(height: 18.h),
                      _label("Status"),
                      _dropdown(
                        "Select Status",
                        status,
                        (v) => setState(() => status = v),
                      ),

                      SizedBox(height: 18.h),
                      _label("Comments"),
                      _commentField(),
                    ],
                  ),
                ),
              ),
            ),

            /// SUBMIT BUTTON
            Padding(
              padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 50.h),
              child: SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                    } else {
                      print("Validation Failed");
                    }
                  },

                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColor.white,
                    ),
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
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
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

  Widget _commentField() {
    return Container(
      height: 100.h,
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

  Widget _dropdown(
    String hint,
    String? value,
    Function(String?) onChanged, {
    List<String>? items,
    String? displayValue,
  }) {
    final dropdownItems = items ?? ["Option 1", "Option 2", "Option 3"];

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
          value: items != null && items.contains(value) ? value : null,
          hint: Text(displayValue ?? hint),
          isExpanded: true,
          items: dropdownItems
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
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
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/customer_model.dart';
import 'package:positive_metering/model/product_model.dart';
import 'package:positive_metering/screens/enquiry/enquiry_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/add_customer_popup.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddEnquiryScreen extends StatefulWidget {
  const AddEnquiryScreen({super.key});

  @override
  State<AddEnquiryScreen> createState() => _AddEnquiryScreenState();
}

class _AddEnquiryScreenState extends State<AddEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoadingProducts = false;

  bool isSubmitting = false;

  List<CustomerModel> customerList = [];
  List<ProductModel> productList = [];

  String? selectedCustomerSrNo;
  final Set<String> selectedProductSrNos = {};

  DateTime? billDate;
  DateTime? followupDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  // String? selectedCompany;
  // String? selectedSector;

  // final List<String> sectors = ["Pharma", "Water Treatment", "Chemical"];

  final Set<String> selectedProducts = {};

  final TextEditingController commentCtrl = TextEditingController();

  Future<void> _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCustomerSrNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.primaryBlue,
          content: Text(
            "Select Company",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    if (selectedProductSrNos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.primaryBlue,
          content: Text(
            "Select Product",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final userSrNo = await AppPref.getUserSrNo();

    setState(() => isSubmitting = true);

    try {
      final success = await ApiService.addEnquiry(
        userSrNo: userSrNo ?? "",
        customerSrNo: selectedCustomerSrNo!,
        comments: commentCtrl.text,
        productSrNo: selectedProductSrNos.join(","),
        billDate: _formatter.format(billDate ?? DateTime.now()),
        followupDate: followupDate != null
            ? _formatter.format(followupDate!)
            : "",
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColor.green,
            content: Text(
              "Enquiry Added",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => EnquiryScreen()),
          (route) => false,
        );
      } else {
        throw Exception();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.primaryBlue,
          content: Text("Failed", style: TextStyle(color: Colors.white)),
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final user = await AppPref.getUser();

    customerList = await ApiService.getCustomerList(
      userSrNo: user?['usersrno'],
      regionSrNo: user?['region_srno'],
      subregionSrNo: user?['subregion_srno'],
    );

    setState(() => isLoadingProducts = true);

    productList = await ApiService.getProducts();

    setState(() => isLoadingProducts = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CommonAppBar(showBack: true, showDrawer: false, showAdd: false),

      bottomNavigationBar: _actionButtons(),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Text(
              "Add Enquiry",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
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
                        billDate ?? DateTime.now(),
                        () => _pickDate(isFollowup: false),
                      ),

                      SizedBox(height: 22.h),
                      _label("Company Name"),
                      // _dropdownField(
                      //   hint: "Select Company",
                      //   value: selectedCompany,
                      //   items: customerList.map((e) => e.companyName).toList(),
                      //   onChanged: (val) {
                      //     final selected = customerList.firstWhere(
                      //       (e) => e.companyName == val,
                      //     );

                      //     setState(() {
                      //       selectedCompany = val;
                      //       selectedCustomerSrNo = selected.customerSrNo;
                      //     });
                      //   },
                      // ),
                      _companyDropdown(),

                      // SizedBox(height: 22.h),

                      // _label("Sector"),
                      // _dropdownField(
                      //   hint: "Select the Sector",
                      //   value: selectedSector,
                      //   items: sectors,
                      //   onChanged: (val) {
                      //     setState(() => selectedSector = val);
                      //   },
                      // ),
                      SizedBox(height: 22.h),
                      _label("Product"),
                      SizedBox(height: 10.h),
                      _productGrid(),

                      SizedBox(height: 22.h),
                      _label("Comments"),
                      _textField(),
                      SizedBox(height: 22.h),
                      _label("Next Follow-up Date (optional)"),
                      _dateField(
                        followupDate,
                        () => _pickDate(isFollowup: true),
                      ),

                      SizedBox(height: 22.h),
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

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateField(DateTime? date, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50.h,
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColor.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null ? "Select Date" : _formatter.format(date)),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  Widget _companyDropdown() {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCustomerSrNo,
          hint: Text(
            "Select Company",
            style: TextStyle(fontSize: 14.sp, color: AppColor.grey),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: customerList.map((customer) {
            return DropdownMenuItem<String>(
              value: customer.customerSrNo, // UNIQUE VALUE
              child: Text(
                customer.companyName
                    .replaceAll('\n', ' ')
                    .replaceAll('\r', '')
                    .trim(),
              ),
            );
          }).toList(),
          onChanged: (srno) {
            setState(() {
              selectedCustomerSrNo = srno;
            });
          },
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(
            value ?? hint,
            style: TextStyle(fontSize: 14.sp, color: AppColor.grey),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 14.sp)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField() {
    return Container(
      height: 90.h,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextFormField(
        controller: commentCtrl,
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

  Widget _productGrid() {
    if (isLoadingProducts) {
      return Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (productList.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Text("No products available"),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, index) {
        final item = productList[index];
        final isSelected = selectedProductSrNos.contains(item.productSrNo);

        return InkWell(
          onTap: () {
            setState(() {
              isSelected
                  ? selectedProductSrNos.remove(item.productSrNo)
                  : selectedProductSrNos.add(item.productSrNo);
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? AppColor.primaryRed : AppColor.grey,
              ),
            ),
            child: Text(item.productName),
          ),
        );
      },
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 35.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: isSubmitting ? null : _submitEnquiry,

              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        "Save",
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColor.primaryBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Text(
                "Reset",
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------

  Future<void> _pickDate({required bool isFollowup}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFollowup) {
          followupDate = picked;
        } else {
          billDate = picked;
        }
      });
    }
  }
}

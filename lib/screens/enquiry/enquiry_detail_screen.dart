import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/customer_model.dart';
import 'package:positive_metering/model/product_model.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class EnquiryDetailScreen extends StatefulWidget {
  final String enquirySrNo;

  const EnquiryDetailScreen({super.key, required this.enquirySrNo});

  @override
  State<EnquiryDetailScreen> createState() => _EnquiryDetailScreenState();
}

class _EnquiryDetailScreenState extends State<EnquiryDetailScreen> {
  bool isLoading = true;

  DateTime? billDate;
  DateTime? followupDate;

  String? companyName;
  List<String> selectedProducts = [];
  String rmmName = "";

  List<CustomerModel> customerList = [];
  List<ProductModel> productList = [];

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  final TextEditingController commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      productList = await ApiService.getProducts();

      final details = await ApiService.getEnquiryDetail(
        enquirySrNo: widget.enquirySrNo,
      );

      if (details != null) {
        /// BILL DATE
        try {
          if (details.billDate.isNotEmpty) {
            billDate = DateFormat('dd-MMM-yyyy').parse(details.billDate);
          }
        } catch (e) {
          billDate = null;
        }

        /// FOLLOWUP DATE
        try {
          if (details.followupDate != null &&
              details.followupDate!.isNotEmpty) {
            followupDate = DateFormat(
              'dd-MMM-yyyy',
            ).parse(details.followupDate!);
          }
        } catch (e) {
          followupDate = null;
        }

        /// COMPANY NAME
        companyName = details.companyName;
        rmmName = details.name;

        /// PRODUCTS
        if (details.productSrNo.isNotEmpty) {
          selectedProducts = details.productSrNo
              .split(",")
              .map((e) => e.trim())
              .toList();
        }

        // COMMENTS
        // commentCtrl.text = details.comments ?? "";
      }
    } catch (e) {
      debugPrint("ENQUIRY DETAIL ERROR: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: const CommonAppBar(showBack: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: const CommonAppBar(showBack: true),

      /// ❌ NO BUTTONS HERE
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              Center(
                child: Text(
                  "Enquiry Detail",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 22.h),

              _label("Date"),
              _dateField(billDate),

              SizedBox(height: 20.h),

              _label("Company Name"),
              _readonlyField(companyName),

              SizedBox(height: 20.h),

              _label("RMM Name"),
              _readonlyField(rmmName),

              SizedBox(height: 20.h),

              _label("Product"),
              SizedBox(height: 10.h),
              _productGrid(),

              SizedBox(height: 20.h),

              // _label("Comments"),
              // _readonlyField(commentCtrl.text),

              /// ✅ SHOW ONLY IF AVAILABLE
              if (followupDate != null) ...[
                SizedBox(height: 20.h),
                _label("Next Follow-up Date"),
                _dateField(followupDate),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateField(DateTime? date) {
    return Container(
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
          Text(date == null ? "-" : _formatter.format(date)),
          const Icon(Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _readonlyField(String? value) {
    return Container(
      height: 46.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      alignment: Alignment.centerLeft,
      child: Text(value ?? "-"),
    );
  }

  Widget _productGrid() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: productList.map((p) {
        final isSelected = selectedProducts.contains(p.productSrNo);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: isSelected ? AppColor.primaryRed : AppColor.lightGrey,
          ),
          child: Text(
            p.productName,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        );
      }).toList(),
    );
  }
}

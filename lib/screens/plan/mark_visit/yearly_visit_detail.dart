import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/common_model.dart';
import 'package:positive_metering/model/customer_model.dart';
import 'package:positive_metering/screens/plan/mark_visit/submit_visit_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class YearlyVisitDetail extends StatefulWidget {
  final String tourPlanSrNo;
  const YearlyVisitDetail({super.key, required this.tourPlanSrNo});

  @override
  State<YearlyVisitDetail> createState() => _YearlyVisitDetailState();
}

class _YearlyVisitDetailState extends State<YearlyVisitDetail> {
  DateTime? fromDate;
  DateTime? toDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String? customerName;
  String? tourType;
  String? visitCall;
  String? region;
  String? customerType;
  String? group;
  String? rmmName;

  List<CustomerModel> customerList = [];
  List<CommonModel> regionList = [];
  List<CommonModel> typeList = [];
  List<CommonModel> groupList = [];

  CustomerModel? selectedCustomer;

  bool isLoading = false;

  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    final user = await AppPref.getUser();

    customerList = await ApiService.getCustomerList(
      userSrNo: user?['usersrno'],
      regionSrNo: user?['region_srno'],
      subregionSrNo: user?['subregion_srno'],
    );

    regionList = await ApiService.getRegion();
    typeList = await ApiService.getCustomerType();
    groupList = await ApiService.getGroup();

    final details = await ApiService.getTourPlanDetailsYearly(
      tourPlanSrNo: widget.tourPlanSrNo,
    );

    if (details != null) {
      fromDate = DateFormat('dd-MM-yyyy').parse(details.fromDate);
      toDate = DateFormat('dd-MM-yyyy').parse(details.toDate);

      tourType = details.tourType;
      visitCall = details.visitCall;
      rmmName = details.name;

      /// FIND CUSTOMER
      final customer = customerList.firstWhere(
        (e) => e.customerSrNo == details.customerSrNo,
      );

      selectedCustomer = customer;
      customerName = customer.customerName;
      companyCtrl.text = customer.companyName;
      nameCtrl.text = customer.customerName;
      mobileCtrl.text = customer.mobileNo;

      /// REGION
      final regionObj = regionList.firstWhere(
        (e) => e.id == details.regionSrNo,
      );
      region = regionObj.name;

      /// TYPE
      final typeObj = typeList.firstWhere(
        (e) => e.id == details.customerTypeSrNo,
      );
      customerType = typeObj.name;

      /// GROUP
      final groupObj = groupList.firstWhere((e) => e.id == details.groupSrNo);
      group = groupObj.name;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColor.white,
        appBar: const CommonAppBar(
          showBack: true,
          showDrawer: false,
          showAdd: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColor.white,
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

            Text(
              "Mark Visit",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),

            /// FORM
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("From Date"),
                    _dateField(fromDate),

                    SizedBox(height: 18.h),

                    _label("To Date"),
                    _dateField(toDate),

                    SizedBox(height: 18.h),
                    _label("Company Name"),
                    _textField(companyCtrl, "Enter Company Name"),

                    SizedBox(height: 18.h),

                    _label("RMM Name"),
                    _textField(
                      TextEditingController(text: rmmName ?? ""),
                      "RMM Name",
                    ),

                    SizedBox(height: 18.h),
                    _label("Tour Type"),
                    _dropdown(
                      "Select the Tour Type",
                      tourType,
                      null,
                      items: const ["Tour", "Lean"],
                    ),

                    SizedBox(height: 18.h),
                    _label("Visit/Call"),
                    _dropdown(
                      "Select the Visit/Call",
                      visitCall,
                      null,
                      items: const ["Visit", "Call"],
                    ),

                    SizedBox(height: 18.h),
                    _label("Customer Name"),
                    _dropdown(
                      "Select the Customer Name",
                      customerName,
                      null,
                      items: customerList.map((e) => e.customerName).toList(),
                    ),

                    SizedBox(height: 18.h),
                    _label("Mobile No"),
                    _textField(mobileCtrl, "Enter Mobile No."),

                    SizedBox(height: 18.h),
                    _label("Region"),
                    _dropdown(
                      "Select the Region",
                      region,
                      null,
                      items: regionList.map((e) => e.name).toList(),
                    ),

                    SizedBox(height: 18.h),
                    _label("Customer Type"),
                    _dropdown(
                      "Select the type",
                      customerType,
                      null,
                      items: typeList.map((e) => e.name).toList(),
                    ),

                    SizedBox(height: 18.h),
                    _label("Group"),
                    _dropdown(
                      "Select the Group",
                      group,
                      null,
                      items: groupList.map((e) => e.name).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // UI HELPERS

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
          Text(
            date == null ? "Select Date" : _formatter.format(date),
            style: TextStyle(fontSize: 14.sp),
          ),
          const Icon(Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _dropdown(
    String hint,
    String? value,
    Function(String?)? onChanged, {
    List<String>? items,
  }) {
    final dropdownItems = items ?? [];

    final cleanItems = dropdownItems.map((e) => e.trim()).toList();
    final cleanValue = value?.trim();

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
          value: cleanItems.contains(cleanValue) ? cleanValue : null,
          hint: Text(hint),
          isExpanded: true,
          items: cleanItems
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged, // can be null (readonly)
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
        readOnly: true,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  // DATE PICKER
}

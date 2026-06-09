import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/common_model.dart';
import 'package:positive_metering/model/customer_model.dart';
import 'package:positive_metering/screens/plan/lean_plan/lean_plan_screen.dart';
import 'package:positive_metering/screens/plan/tour_plan/tour_plan_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/add_customer_popup.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddTourPlanScreen extends StatefulWidget {
  const AddTourPlanScreen({super.key});

  @override
  State<AddTourPlanScreen> createState() => _AddTourPlanScreenState();
}

class _AddTourPlanScreenState extends State<AddTourPlanScreen> {
  DateTime? selectedDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  bool isSaving = false;

  List<CustomerModel> customerList = [];
  List<CommonModel> regionList = [];
  List<CommonModel> typeList = [];
  List<CommonModel> groupList = [];

  CustomerModel? selectedCustomer;
  String? selectedCustomerSrNo;

  String? selectedRegionId;
  String? selectedTypeId;
  String? selectedGroupId;

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

    regionList = await ApiService.getRegion();
    typeList = await ApiService.getCustomerType();
    groupList = await ApiService.getGroup();

    if (!mounted) return;

    setState(() {});
  }

  String? customerName;
  String? tourType;
  String? visitCall;
  String? region;
  String? customerType;
  String? group;

  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();

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

    setState(() {
      customerName = result;
    });
  }

  void _onSaveTap() async {
    if (selectedCustomer == null ||
        selectedDate == null ||
        tourType == null ||
        visitCall == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isSaving = true);

    final userSrNo = await AppPref.getUserSrNo();

    final success = await ApiService.addTourPlan(
      userSrNo: userSrNo ?? "",
      customerSrNo: selectedCustomer!.customerSrNo,
      billDate: _formatter.format(selectedDate!),
      tourType: tourType!,
      visitCall: visitCall!,
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        AnimatedPageRoute(
          page: PlanScreen(
            initialTab: tourType == "Tour" ? PlanType.tour : PlanType.lean,
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save")));
    }
  }

  void _resetForm() {
    setState(() {
      selectedDate = null;

      selectedCustomer = null;
      selectedCustomerSrNo = null;
      customerName = null;

      tourType = null;
      visitCall = null;

      region = null;
      customerType = null;
      group = null;

      selectedRegionId = null;
      selectedTypeId = null;
      selectedGroupId = null;

      companyCtrl.clear();
      nameCtrl.clear();
      mobileCtrl.clear();
    });
  }

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
              "Add Tour Plan",
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
                    _label("Date"),
                    _dateField(),

                    SizedBox(height: 18.h),
                    _label("Company Name"),
                    // _dropdown(
                    //   "Select Company",
                    //   companyCtrl.text.isEmpty ? null : companyCtrl.text,
                    //   (v) {
                    //     // if (v == "Add New") {
                    //     //   _openAddCustomerPopup();
                    //     //   return;
                    //     // }

                    //     final customer = customerList.firstWhere(
                    //       (e) =>
                    //           e.companyName.replaceAll('\n', ' ').trim() ==
                    //           v?.replaceAll('\n', ' ').trim(),
                    //     );

                    //     setState(() {
                    //       selectedCustomer = customer;

                    //       companyCtrl.text = customer.companyName;
                    //       customerName = customer.customerName;

                    //       nameCtrl.text = customer.customerName;
                    //       mobileCtrl.text = customer.mobileNo;

                    //       selectedRegionId = customer.regionSrNo;
                    //       selectedTypeId = customer.customerTypeSrNo;
                    //       selectedGroupId = customer.groupSrNo;

                    //       region = regionList
                    //           .firstWhere((e) => e.id == selectedRegionId)
                    //           .name
                    //           .trim();

                    //       customerType = typeList
                    //           .firstWhere((e) => e.id == selectedTypeId)
                    //           .name
                    //           .trim();

                    //       group = groupList
                    //           .firstWhere((e) => e.id == selectedGroupId)
                    //           .name
                    //           .trim();
                    //     });
                    //   },
                    //   items: customerList
                    //       .map(
                    //         (e) => e.companyName.replaceAll('\n', ' ').trim(),
                    //       )
                    //       .toList(),
                    // ),
                    _companyDropdown(),

                    SizedBox(height: 18.h),
                    _label("Tour Type"),
                    _dropdown(
                      "Select the Tour Type",
                      tourType,
                      (v) => setState(() => tourType = v),
                      items: const ["Tour", "Lean"],
                    ),

                    SizedBox(height: 18.h),
                    _label("Visit/Call"),
                    _dropdown(
                      "Select the Visit/Call",
                      visitCall,
                      (v) => setState(() => visitCall = v),
                      items: const ["Visit", "Call"],
                    ),

                    SizedBox(height: 18.h),
                    _label("Customer Name"),
                    _textField(nameCtrl, "Customer Name"),

                    // SizedBox(height: 18.h),
                    // _label("Name"),
                    // _textField(nameCtrl, "Enter Name"),
                    SizedBox(height: 18.h),
                    _label("Mobile No"),
                    _textField(mobileCtrl, "Enter Mobile No."),

                    SizedBox(height: 18.h),
                    _label("Region"),
                    _dropdown(
                      "Select the Region",
                      region,
                      (v) {
                        final selected = regionList.firstWhere(
                          (e) => e.name == v,
                        );
                        setState(() {
                          region = v;
                          selectedRegionId = selected.id;
                        });
                      },
                      items: regionList.map((e) => e.name).toList(),
                    ),

                    SizedBox(height: 18.h),
                    _label("Customer Type"),
                    _dropdown(
                      "Select the type",
                      customerType,
                      (v) {
                        final selected = typeList.firstWhere(
                          (e) => e.name == v,
                        );
                        setState(() {
                          customerType = v;
                          selectedTypeId = selected.id;
                        });
                      },
                      items: typeList.map((e) => e.name).toList(),
                    ),

                    SizedBox(height: 18.h),
                    _label("Group"),
                    _dropdown(
                      "Select the Group",
                      group,
                      (v) {
                        final selected = groupList.firstWhere(
                          (e) => e.name == v,
                        );
                        setState(() {
                          group = v;
                          selectedGroupId = selected.id;
                        });
                      },
                      items: groupList.map((e) => e.name).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI WIDGETS

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
              _formatter.format(selectedDate ?? DateTime.now()),
              style: TextStyle(fontSize: 14.sp),
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(
    String hint,
    String? value,
    Function(String?) onChanged, {
    List<String>? items,
  }) {
    final dropdownItems = items ?? ["Option 1", "Option 2", "Option 3"];

    /// 🔥 CLEAN VALUES (important)
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
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _companyDropdown() {
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
          value: selectedCustomerSrNo,
          hint: const Text("Select Company"),
          isExpanded: true,
          items: customerList.map((customer) {
            return DropdownMenuItem<String>(
              value: customer.customerSrNo, // UNIQUE
              child: Text(
                customer.companyName
                    .replaceAll('\n', ' ')
                    .replaceAll('\r', '')
                    .trim(),
              ),
            );
          }).toList(),
          onChanged: (srno) {
            final customer = customerList.firstWhere(
              (e) => e.customerSrNo == srno,
            );

            setState(() {
              selectedCustomerSrNo = srno;
              selectedCustomer = customer;

              companyCtrl.text = customer.companyName
                  .replaceAll('\n', ' ')
                  .replaceAll('\r', '')
                  .trim();

              customerName = customer.customerName
                  .replaceAll('\n', ' ')
                  .replaceAll('\r', '')
                  .trim();

              nameCtrl.text = customer.customerName
                  .replaceAll('\n', ' ')
                  .replaceAll('\r', '')
                  .trim();

              mobileCtrl.text = customer.mobileNo;

              selectedRegionId = customer.regionSrNo;
              selectedTypeId = customer.customerTypeSrNo;
              selectedGroupId = customer.groupSrNo;

              region = regionList
                  .firstWhere((e) => e.id == selectedRegionId)
                  .name
                  .trim();

              customerType = typeList
                  .firstWhere((e) => e.id == selectedTypeId)
                  .name
                  .trim();

              group = groupList
                  .firstWhere((e) => e.id == selectedGroupId)
                  .name
                  .trim();
            });
          },
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

  // DATE PICKER

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

  // ACTION BUTTONS

  Widget _actionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 50.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: isSaving ? null : _onSaveTap,
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: isSaving
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          color: AppColor.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
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
            child: InkWell(
              onTap: _resetForm,
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
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/customer_model.dart';
import 'package:positive_metering/screens/plan/tour_plan/tour_plan_screen.dart';
import 'package:positive_metering/screens/plan/tour_plan_yearly/tour_plan_yearly_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/add_customer_popup.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddTourPlanYearlyScreen extends StatefulWidget {
  const AddTourPlanYearlyScreen({super.key});

  @override
  State<AddTourPlanYearlyScreen> createState() =>
      _AddTourPlanYearlyScreenState();
}

// ONLY CHANGED / ADDED PARTS ARE MARKED

class _AddTourPlanYearlyScreenState extends State<AddTourPlanYearlyScreen> {
  DateTime? selectedWeekDate;
  String? tourType;
  String? visitCall;

  bool isSaving = false;

  final DateFormat _apiFormatter = DateFormat('dd-MM-yyyy');
  final DateFormat _formatter = DateFormat('dd MMM yyyy');

  List<CustomerModel> customerList = [];
  CustomerModel? selectedCustomer;
  String? selectedCustomerSrNo;

  String? customerName;
  String? region;

  final TextEditingController companyCtrl = TextEditingController();

  final Set<String> selectedCustomers = {};

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  // LOAD CUSTOMER LIST
  Future<void> loadCustomers() async {
    final user = await AppPref.getUser();

    customerList = await ApiService.getCustomerList(
      userSrNo: user?['usersrno'],
      regionSrNo: user?['region_srno'],
      subregionSrNo: user?['subregion_srno'],
    );

    setState(() {});
  }

  // --------------------------------------------------
  String get weekText {
    if (selectedWeekDate == null) return "Select Week";

    final monday = selectedWeekDate!;
    final sunday = monday.add(const Duration(days: 6));

    return "${_formatter.format(monday)} - ${_formatter.format(sunday)}";
  }

  // --------------------------------------------------
  DateTime get monday => selectedWeekDate!;
  DateTime get sunday => monday.add(const Duration(days: 6));

  // --------------------------------------------------
  void _onSaveTap() async {
    if (selectedWeekDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select week")));
      return;
    }

    if (selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select company")));
      return;
    }

    if (tourType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select tour type")));
      return;
    }

    if (visitCall == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select visit/call type")),
      );
      return;
    }

    setState(() => isSaving = true);

    final userSrNo = await AppPref.getUserSrNo();

    final success = await ApiService.addTourPlanYearly(
      userSrNo: userSrNo ?? "",
      customerSrNo: selectedCustomer!.customerSrNo,
      fromDate: _apiFormatter.format(monday),
      toDate: _apiFormatter.format(sunday),
      tourType: tourType!,
      visitCall: visitCall!,
    );

    setState(() => isSaving = false);

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        AnimatedPageRoute(page: const TourPlanYearlyScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed")));
    }
  }

  void _resetForm() {
    setState(() {
      selectedWeekDate = null;
      tourType = null;
      visitCall = null;

      selectedCustomer = null;
      selectedCustomerSrNo = null;
      customerName = null;
      region = null;

      companyCtrl.clear();
    });
  }

  // --------------------------------------------------
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
              "Add Tour Plan (Yearly)",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 20.h),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Week"),
                    _weekField(),

                    SizedBox(height: 18.h),

                    // CUSTOMER DROPDOWN (REPLACED)
                    _label("Company Name"),
                    // _dropdown(
                    //   "Select Company",
                    //   companyCtrl.text.isEmpty ? null : companyCtrl.text,
                    //   customerList
                    //       .map(
                    //         (e) => e.companyName.replaceAll('\n', ' ').trim(),
                    //       )
                    //       .toList(),
                    //   (v) async {
                    //     // if (v == "Add New") {
                    //     //   final result = await showModalBottomSheet<String>(
                    //     //     context: context,
                    //     //     isScrollControlled: true,
                    //     //     shape: RoundedRectangleBorder(
                    //     //       borderRadius: BorderRadius.vertical(
                    //     //         top: Radius.circular(16.r),
                    //     //       ),
                    //     //     ),
                    //     //     builder: (_) => const AddCustomerPopup(),
                    //     //   );

                    //     //   if (result != null && result.isNotEmpty) {
                    //     //     setState(() {
                    //     //       companyCtrl.text = result;
                    //     //     });
                    //     //   }
                    //     //   return;
                    //     // }

                    //     final customer = customerList.firstWhere(
                    //       (e) =>
                    //           e.companyName.replaceAll('\n', ' ').trim() ==
                    //           v?.replaceAll('\n', ' ').trim(),
                    //     );

                    //     setState(() {
                    //       selectedCustomer = customer;

                    //       companyCtrl.text = customer.companyName
                    //           .replaceAll('\n', ' ')
                    //           .trim();

                    //       customerName = customer.customerName
                    //           .replaceAll('\n', ' ')
                    //           .trim();

                    //       region = customer.regionSrNo;
                    //     });
                    //   },
                    // ),
                    _companyDropdown(),
                    SizedBox(height: 18.h),

                    SizedBox(height: 18.h),

                    _label("Customer Name"),
                    _textField(
                      TextEditingController(text: customerName ?? ""),
                      "Customer Name",
                    ),

                    SizedBox(height: 18.h),

                    _label("Tour Type"),
                    _dropdown(
                      "Select Tour Type",
                      tourType,
                      ["Tour", "Lean"],
                      (v) => setState(() => tourType = v),
                    ),

                    SizedBox(height: 18.h),

                    // NEW FIELD
                    _label("Visit/Call"),
                    _dropdown(
                      "Select Visit/Call",
                      visitCall,
                      ["Visit", "Call"],
                      (v) => setState(() => visitCall = v),
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

  // --------------------------------------------------
  Widget _dropdown(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final cleanItems = items.map((e) => e.trim()).toList();
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
              value: customer.customerSrNo, // UNIQUE VALUE
              child: Text(customer.companyName.replaceAll('\n', ' ').trim()),
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
                  .trim();

              customerName = customer.customerName.replaceAll('\n', ' ').trim();

              region = customer.regionSrNo;
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

  // --------------------------------------------------
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

  Widget _weekField() {
    return InkWell(
      onTap: _pickWeek,
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
            Text(weekText, style: TextStyle(fontSize: 14.sp)),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  void _pickWeek() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? tempSelectedMonday = selectedWeekDate;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select Week",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    SizedBox(
                      height: 400.h,
                      child: SfDateRangePicker(
                        selectionMode: DateRangePickerSelectionMode.single,
                        showNavigationArrow: true,

                        selectableDayPredicate: (date) {
                          return date.weekday == DateTime.monday;
                        },

                        onSelectionChanged: (args) {
                          if (args.value is DateTime) {
                            setDialogState(() {
                              tempSelectedMonday = args.value;
                            });
                          }
                        },

                        monthViewSettings: DateRangePickerMonthViewSettings(
                          dayFormat: 'EEE',

                          specialDates: tempSelectedMonday == null
                              ? []
                              : List.generate(
                                  7,
                                  (index) => tempSelectedMonday!.add(
                                    Duration(days: index),
                                  ),
                                ),
                        ),

                        monthCellStyle: DateRangePickerMonthCellStyle(
                          specialDatesDecoration: BoxDecoration(
                            color: AppColor.primaryRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          specialDatesTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        selectionColor: AppColor.primaryRed,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedWeekDate = tempSelectedMonday;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }
}

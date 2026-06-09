import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/customer_model.dart';
import 'package:positive_metering/model/product_model.dart';
import 'package:positive_metering/screens/follow_up/follow_up_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ViewAddFollowUpScreen extends StatefulWidget {
  final String type;
  final String? enquirySrNo;
  final String? tourPlanSrNo;
  final String customerSrNo;
  final String companyName;
  const ViewAddFollowUpScreen({
    super.key,
    required this.type,
    this.enquirySrNo,
    this.tourPlanSrNo,
    required this.customerSrNo,
    required this.companyName,
  });

  @override
  State<ViewAddFollowUpScreen> createState() => _ViewAddFollowUpScreenState();
}

class _ViewAddFollowUpScreenState extends State<ViewAddFollowUpScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> historyData = [];
  bool isHistoryLoading = true;

  DateTime? enquiryDate;
  DateTime? followUpDate;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String? company;
  String? sector;
  String? status;
  String? lostReason;
  String? followUpDoneBy;
  String rmmName = "";
  String? enquiryGenerated;

  List<ProductModel> productList = [];
  bool isLoadingProducts = false;

  final Set<String> selectedProducts = {};

  final List<String> products = ["Dosing Pumps", "SC Pumps", "ED Pumps"];

  final TextEditingController commentCtrl1 = TextEditingController();
  final TextEditingController commentCtrl2 = TextEditingController();

  List<Map<String, dynamic>> statusList = [];
  String? selectedStatusSrNo;

  List<CustomerModel> customerList = [];

  bool isLoading = true;
  bool isSaving = false;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadData();
    if (widget.type == "visit") {
      fetchProducts();
    }
  }

  Future<void> loadUser() async {
    user = await AppPref.getUser();
    setState(() {});
  }

  Future<void> fetchProducts() async {
    setState(() => isLoadingProducts = true);

    final data = await ApiService.getProducts();

    setState(() {
      productList = data;
      isLoadingProducts = false;
    });
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    final user = await AppPref.getUser();

    customerList = await ApiService.getCustomerList(
      userSrNo: user?['usersrno'],
      regionSrNo: user?['region_srno'],
      subregionSrNo: user?['subregion_srno'],
    );

    statusList = await ApiService.getStatus();

    setState(() {
      isLoading = false;

      if (statusList.isNotEmpty) {
        selectedStatusSrNo = statusList.first['status_srno'].toString();
      }
    });

    await fetchFollowUpHistory();
  }

  Future<void> fetchFollowUpHistory() async {
    try {
      isHistoryLoading = true;
      setState(() {});

      List<Map<String, dynamic>> data = [];

      if (widget.type == "enquiry") {
        data = await ApiService.getEnquiryFollowupDetails(
          enquirySrNo: widget.enquirySrNo!,
        );
      } else {
        data = await ApiService.getVisitFollowupDetails(
          tourPlanSrNo: widget.tourPlanSrNo!,
        );
      }

      /// RMM NAME
      if (data.isNotEmpty) {
        rmmName = (data.first['name'] ?? "")
            .toString()
            .replaceAll('\n', ' ')
            .replaceAll('\r', '')
            .trim();
      }

      historyData = data;
    } catch (e) {
      historyData = [];
      rmmName = "";
    }

    isHistoryLoading = false;

    setState(() {});
  }

  String? _getSelectedStatusName() {
    final selected = statusList.firstWhere(
      (e) => e['status_srno'].toString() == selectedStatusSrNo,
      orElse: () => {},
    );

    return selected['status_name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CommonAppBar(showBack: true, showDrawer: false, showAdd: false),

      /// FIXED BUTTONS
      // bottomNavigationBar: _actionButtons(),
      bottomNavigationBar: user == null
          ? null
          : widget.type == "enquiry"
          ? user!['enquiryfollowup_add'] == "y"
                ? _actionButtons()
                : null
          : user!['visitfollowup_add'] == "y"
          ? _actionButtons()
          : null,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Text(
              "View and Add Follow-up",
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
                      _dateField(
                        enquiryDate ?? DateTime.now(),
                        (d) => enquiryDate = d,
                      ),

                      SizedBox(height: 20.h),
                      _label("Company Name"),
                      Container(
                        height: 46.h,
                        margin: EdgeInsets.only(top: 6.h),
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(widget.companyName),
                      ),

                      SizedBox(height: 20.h),

                      _label("RMM Name"),

                      Container(
                        height: 46.h,
                        margin: EdgeInsets.only(top: 6.h),
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(rmmName),
                      ),

                      // SizedBox(height: 20.h),
                      // _label("Sector"),
                      // _dropdown("Select the Sector", sector, (v) {
                      //   setState(() => sector = v);
                      // }),
                      // SizedBox(height: 20.h),
                      // _label("Product"),
                      // _productGrid(),
                      SizedBox(height: 24.h),

                      /// FOLLOW-UP HISTORY
                      _followUpHistory(),

                      SizedBox(height: 24.h),
                      _label("Status"),
                      _statusDropdown(),

                      if (widget.type == "visit" &&
                          _getSelectedStatusName()?.toLowerCase() == "won") ...[
                        SizedBox(height: 20.h),
                        _label("Enquiry Generated"),
                        _enquiryDropdown(),
                      ],
                      if (widget.type == "visit" &&
                          _getSelectedStatusName()?.toLowerCase() == "won" &&
                          enquiryGenerated == "Yes") ...[
                        SizedBox(height: 20.h),
                        _label("Product"),
                        _productGrid(),
                      ],

                      // SizedBox(height: 20.h),
                      // _label("Lost Reason"),
                      // _dropdown("Select", lostReason, (v) {
                      //   setState(() => lostReason = v);
                      // }),

                      // SizedBox(height: 20.h),
                      // _label("Follow-up Done By"),
                      // _dropdown("Select", followUpDoneBy, (v) {
                      //   setState(() => followUpDoneBy = v);
                      // }),
                      SizedBox(height: 20.h),
                      _label("Next Follow-up Date"),
                      _dateField(followUpDate, (d) => followUpDate = d),

                      SizedBox(height: 20.h),
                      _label("Comments"),
                      _textField(commentCtrl2, "Description"),
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

  Widget _enquiryDropdown() {
    final items = ["Yes", "No"];

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
          value: enquiryGenerated,
          hint: const Text("Select"),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              enquiryGenerated = val;

              if (val != "Yes") {
                selectedProducts.clear();
              }
            });
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateField(DateTime? date, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
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
        if (picked != null) setState(() => onPicked(picked));
      },
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
            Text(date == null ? "Select Date" : _formatter.format(date)),
            const Icon(Icons.calendar_month),
          ],
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

  Widget _productGrid() {
    if (isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productList.isEmpty) {
      return const Text("No products available");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 10.h),
      itemCount: productList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, index) {
        final item = productList[index];
        final isSelected = selectedProducts.contains(item.productSrNo);

        return InkWell(
          onTap: () {
            setState(() {
              isSelected
                  ? selectedProducts.remove(item.productSrNo)
                  : selectedProducts.add(item.productSrNo);
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? AppColor.primaryRed : AppColor.grey,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              item.productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: isSelected ? AppColor.primaryRed : AppColor.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _followUpHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Follow-up History",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textDark,
          ),
        ),
        SizedBox(height: 10.h),

        if (isHistoryLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: CircularProgressIndicator(),
            ),
          )
        else if (historyData.isEmpty)
          const Center(child: Text("No History Found"))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: DataTable(
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppColor.grey),
                  verticalInside: BorderSide(color: AppColor.grey),
                ),
                headingRowColor: MaterialStateProperty.all(AppColor.primaryRed),
                columnSpacing: 24.w,

                columns: const [
                  DataColumn(
                    label: Text(
                      "Followup Date",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Comments",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Status",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Next Followup Date",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],

                rows: historyData.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item["followup_date"] ?? "")),
                      DataCell(
                        SizedBox(
                          width: 160.w,
                          child: Text(
                            item["followup_comment"] ?? "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          (item["status"] ?? "").toString().replaceAll(
                            "\n",
                            " ",
                          ),
                        ),
                      ),
                      DataCell(Text(item["next_followup"] ?? "")),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusDropdown() {
    if (isLoading) {
      return Container(
        height: 46.h,
        alignment: Alignment.center,
        child: SizedBox(
          height: 20.h,
          width: 20.h,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

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
          value: selectedStatusSrNo,
          hint: const Text("Select Status"),
          isExpanded: true,
          items: statusList.map((e) {
            return DropdownMenuItem<String>(
              value: e['status_srno'].toString(),
              child: Text(e['status_name'] ?? ""),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedStatusSrNo = val;

              enquiryGenerated = null;
              selectedProducts.clear();
            });
          },
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 50.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: isSaving
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;

                      setState(() => isSaving = true);

                      final userSrNo = await AppPref.getUserSrNo();
                      if (_getSelectedStatusName()?.toLowerCase() == "won") {
                        if (enquiryGenerated == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Select enquiry type")),
                          );
                          return;
                        }

                        if (enquiryGenerated == "Yes" &&
                            selectedProducts.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Select at least one product"),
                            ),
                          );
                          return;
                        }
                      }

                      try {
                        bool success = false;

                        if (widget.type == "enquiry") {
                          success = await ApiService.addFollowupEnquiry(
                            enquirySrNo: widget.enquirySrNo!,
                            userSrNo: userSrNo ?? "",
                            comments: commentCtrl2.text,
                            customerSrNo: widget.customerSrNo,
                            visitDate: _formatter.format(
                              enquiryDate ?? DateTime.now(),
                            ),
                            statusSrNo: selectedStatusSrNo ?? "",
                            nextFollowup: followUpDate != null
                                ? _formatter.format(followUpDate!)
                                : "",
                          );
                        } else {
                          success = await ApiService.addFollowupVisit(
                            tourPlanSrNo: widget.tourPlanSrNo!,
                            userSrNo: userSrNo ?? "",
                            comments: commentCtrl2.text,
                            customerSrNo: widget.customerSrNo,
                            visitDate: _formatter.format(
                              enquiryDate ?? DateTime.now(),
                            ),
                            statusSrNo: selectedStatusSrNo ?? "",
                            nextFollowup: _formatter.format(
                              followUpDate ?? DateTime.now(),
                            ),

                            enquiryGenerated: enquiryGenerated,

                            productSrNo:
                                (enquiryGenerated == "Yes" &&
                                    selectedProducts.isNotEmpty)
                                ? selectedProducts.join(",")
                                : null,
                          );
                        }

                        setState(() => isSaving = false);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                "Follow-up Added",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FollowUpScreen(type: widget.type),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        setState(() => isSaving = false);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColor.primaryBlue,
                            content: Text(
                              "Failed",
                              style: TextStyle(color: Colors.white),
                            ),
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
}

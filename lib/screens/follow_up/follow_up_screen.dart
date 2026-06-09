import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/enquiry_followup_model.dart';
import 'package:positive_metering/model/project_followup_model.dart';
import 'package:positive_metering/model/visit_followup_model.dart';
import 'package:positive_metering/screens/follow_up/project_view_add_followup_screen.dart';
import 'package:positive_metering/screens/follow_up/view_add_follow_up_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class FollowUpScreen extends StatefulWidget {
  final String type;
  const FollowUpScreen({super.key, required this.type});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, String> productMap = {};

  List<EnquiryFollowUpModel> enquiryList = [];
  List<VisitFollowUpModel> visitList = [];
  List<ProjectFollowUpModel> projectList = [];
  List<ProjectFollowUpModel> filteredProjectList = [];
  bool isLoading = false;

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  final DateFormat _apiFormatter = DateFormat('dd-MMM-yyyy');

  TextEditingController searchController = TextEditingController();

  List<EnquiryFollowUpModel> filteredEnquiryList = [];
  List<VisitFollowUpModel> filteredVisitList = [];

  String getProductNames(String productSrNos) {
    if (productSrNos.isEmpty || productSrNos == "0") return "-";

    final ids = productSrNos.split(",");

    return ids
        .map((id) {
          return productMap[id.trim()] ?? id;
        })
        .join(", ");
  }

  Future<void> fetchFollowUps() async {
    final products = await ApiService.getProducts();

    productMap = {for (var p in products) p.productSrNo: p.productName};
    setState(() => isLoading = true);

    final userSrNo = await AppPref.getUserSrNo();

    final apiFormatter = DateFormat('dd-MMM-yyyy');

    if (widget.type == "enquiry") {
      enquiryList = await ApiService.getEnquiryFollowUp(
        usersrno: userSrNo ?? "",
        fromDate: apiFormatter.format(fromDate),
        toDate: apiFormatter.format(toDate),
      );

      filteredEnquiryList = enquiryList;
    } else if (widget.type == "visit") {
      visitList = await ApiService.getVisitFollowUp(
        usersrno: userSrNo ?? "",
        fromDate: apiFormatter.format(fromDate),
        toDate: apiFormatter.format(toDate),
      );

      filteredVisitList = visitList;
    } else {
      projectList = await ApiService.getProjectFollowUp(
        usersrno: userSrNo ?? "",
        fromDate: apiFormatter.format(fromDate),
        toDate: apiFormatter.format(toDate),
      );

      filteredProjectList = projectList;
    }

    setState(() => isLoading = false);
  }

  void _onSearch(String value) {
    if (widget.type == "enquiry") {
      filteredEnquiryList = enquiryList.where((item) {
        final name = item.companyName.toLowerCase();
        final mobile = item.mobileNo.toLowerCase();
        final query = value.toLowerCase();

        return name.contains(query) || mobile.contains(query);
      }).toList();
    } else if (widget.type == "visit") {
      filteredVisitList = visitList.where((item) {
        final name = item.companyName.toLowerCase();
        final mobile = item.mobileNo.toLowerCase();
        final query = value.toLowerCase();

        return name.contains(query) || mobile.contains(query);
      }).toList();
    } else {
      filteredProjectList = projectList.where((item) {
        final query = value.toLowerCase();

        return item.projectTitle.toLowerCase().contains(query) ||
            item.clientName.toLowerCase().contains(query) ||
            item.clientContactNumber.toLowerCase().contains(query);
      }).toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    fetchFollowUps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              "Follow-Up",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),

            /// DATE FILTER
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 16.h),

            // /// STATUS + SALES PERSON
            // Row(
            //   children: [
            //     _dropdownBox("Status", status, [
            //       "ALL",
            //       "Open",
            //       "Closed",
            //     ], (val) => setState(() => status = val)),
            //     SizedBox(width: 12.w),
            //     _dropdownBox(
            //       "Sales Person",
            //       salesPerson,
            //       ["ALL", "XYZ", "Ketan"],
            //       (val) => setState(() => salesPerson = val),
            //     ),
            //     SizedBox(width: 12.w),
            //     _viewButton(),
            //   ],
            // ),
            SizedBox(height: 10.h),

            Divider(height: 32.h, color: AppColor.black),

            SizedBox(height: 10.h),

            /// SHOW ENTRIES + SEARCH
            _searchBox(),

            SizedBox(height: 16.h),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : widget.type == "enquiry"
                  ? filteredEnquiryList.isEmpty
                        ? const Center(child: Text("No Data Found"))
                        : ListView.builder(
                            itemCount: filteredEnquiryList.length,
                            itemBuilder: (context, index) {
                              final item = filteredEnquiryList[index];

                              return FollowUpCard(
                                followupDate: item.followupDate,
                                companyName: item.companyName,
                                name: item.name,
                                mobile: item.mobileNo,
                                product: getProductNames(item.product),
                                status: item.status,
                                type: "enquiry",
                                enquirySrNo: item.enquirySrNo,
                                customerSrNo: item.customerSrNo,
                              );
                            },
                          )
                  : widget.type == "visit"
                  ? filteredVisitList.isEmpty
                        ? const Center(child: Text("No Data Found"))
                        : ListView.builder(
                            itemCount: filteredVisitList.length,
                            itemBuilder: (context, index) {
                              final item = filteredVisitList[index];

                              return FollowUpCard(
                                followupDate: item.followupDate,
                                companyName: item.companyName,
                                name: item.name,
                                mobile: item.mobileNo,
                                product: "-",
                                status: item.status,
                                type: "visit",
                                tourPlanSrNo: item.tourPlanSrNo,
                                customerSrNo: item.customerSrNo,
                              );
                            },
                          )
                  : filteredProjectList.isEmpty
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      itemCount: filteredProjectList.length,
                      itemBuilder: (context, index) {
                        final item = filteredProjectList[index];

                        return ProjectFollowUpCard(
                          followupDate: item.followupDate,
                          projectTitle: item.projectTitle,
                          regionName: item.regionName,
                          projectValue: item.projectValue,
                          clientName: item.clientName,
                          clientContactNumber: item.clientContactNumber,
                          projectSrNo: item.projectSrNo,
                        );
                      },
                    ),
            ),
            SizedBox(height: 45.h),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_apiFormatter.format(date)),
                  Icon(Icons.calendar_month, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownBox(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => onChanged(val!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton() {
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: InkWell(
        onTap: isLoading ? null : fetchFollowUps, // ✅ THIS WAS MISSING
        child: Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColor.primaryRed,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  height: 18.h,
                  width: 18.h,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Text(
                  "View",
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _smallDropdown(
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 36.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextField(
        controller: searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          icon: Icon(Icons.search, size: 18.sp),
          hintText: "Search by name or mobile",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------

  Future<void> _pickFromDate() async {
    final picked = await _showPicker(fromDate, first: DateTime(2000));

    if (picked != null) {
      setState(() {
        fromDate = picked;
        toDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await _showPicker(toDate, first: fromDate);
    if (picked != null) {
      setState(() => toDate = picked);
    }
  }

  Future<DateTime?> _showPicker(DateTime initial, {DateTime? first}) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime.now(),
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
  }
}

/// --------------------------------------------------------------------
/// FOLLOW UP CARD
/// --------------------------------------------------------------------

class FollowUpCard extends StatefulWidget {
  final String followupDate;
  final String companyName;
  final String mobile;
  final String product;
  final String status;
  final String type;
  final String? enquirySrNo;
  final String? tourPlanSrNo;
  final String customerSrNo;
  final String name;

  const FollowUpCard({
    super.key,
    required this.followupDate,
    required this.companyName,
    required this.mobile,
    required this.product,
    required this.status,
    required this.type,
    this.enquirySrNo,
    this.tourPlanSrNo,
    required this.customerSrNo,
    required this.name,
  });

  @override
  State<FollowUpCard> createState() => _FollowUpCardState();
}

class _FollowUpCardState extends State<FollowUpCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("Follow-up Date :", widget.followupDate),
            _row("Company Name :", widget.companyName),
            _row("RMM Name :", widget.name),
            _row("Customer Phone :", widget.mobile),
            if (widget.type.toLowerCase().trim() != "visit" &&
                widget.product.isNotEmpty &&
                widget.product != "-")
              _productRow("Products :", widget.product),
            _row("Status :", widget.status),

            SizedBox(height: 12.h),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  AnimatedPageRoute(
                    page: ViewAddFollowUpScreen(
                      type: widget.type,
                      enquirySrNo: widget.enquirySrNo,
                      tourPlanSrNo: widget.tourPlanSrNo,
                      customerSrNo: widget.customerSrNo,
                      companyName: widget.companyName,
                    ),
                  ),
                );
              },
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "View and Add Follow-up",
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150.w, // fixed width for label
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          Expanded(
            child: Text(value, softWrap: true, overflow: TextOverflow.visible),
          ),
        ],
      ),
    );
  }

  Widget _productRow(String label, String value) {
    final products = value.split(",");

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),

          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: products.map((p) {
              final text = p.trim();

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.primaryRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ProjectFollowUpCard extends StatelessWidget {
  final String followupDate;
  final String projectTitle;
  final String regionName;
  final String projectValue;
  final String clientName;
  final String clientContactNumber;
  final String projectSrNo;

  const ProjectFollowUpCard({
    super.key,
    required this.followupDate,
    required this.projectTitle,
    required this.regionName,
    required this.projectValue,
    required this.clientName,
    required this.clientContactNumber,
    required this.projectSrNo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("Follow-up Date :", followupDate),
            _row("Project Title :", projectTitle),
            _row("Region :", regionName),
            _row("Project Value :", projectValue),
            _row("Client Name :", clientName),
            _row("Contact Number :", clientContactNumber),

            SizedBox(height: 12.h),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  AnimatedPageRoute(
                    page: ProjectViewAddFollowUpScreen(
                      projectSrNo: projectSrNo,
                      projectTitle: projectTitle,
                    ),
                  ),
                );
              },
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "View and Add Follow-up",
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 150.w,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

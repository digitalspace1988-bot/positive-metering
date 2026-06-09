import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/happy_call_model.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class HappyCallScreen extends StatefulWidget {
  const HappyCallScreen({super.key});

  @override
  State<HappyCallScreen> createState() => _HappyCallScreenState();
}

class _HappyCallScreenState extends State<HappyCallScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<HappyCallModel> contacts = [];
  List<HappyCallModel> filteredContacts = [];

  bool isLoading = false;

  final TextEditingController searchCtrl = TextEditingController();

  Map<String, dynamic>? user;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadUser();
    loadHappyCalls();
    filteredContacts = List.from(contacts);
    searchCtrl.addListener(_onSearch);
  }

  Future<void> loadHappyCalls() async {
    setState(() => isLoading = true);

    final userSrNo = await AppPref.getUserSrNo();

    contacts = await ApiService.getHappyCalls(
      userSrNo: userSrNo ?? "",
      billDate: DateFormat('dd-MM-yyyy').format(selectedDate),
    );

    filteredContacts = List.from(contacts);

    setState(() => isLoading = false);
  }

  Future<void> loadUser() async {
    user = await AppPref.getUser();

    setState(() {});
  }

  void _onSearch() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((c) {
        return c.customerName.toLowerCase().contains(query) ||
            c.companyName.toLowerCase().contains(query) ||
            c.mobileNo.toLowerCase().contains(query);
      }).toList();
    });
  }

  // ---------------------------------------------------------------
  Future<void> _makeCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unable to open dialer")));
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      backgroundColor: AppColor.white,

      /// COMMON APP BAR
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: false,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            /// TITLE
            Text(
              "Happy Call",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColor.primaryRed,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          height: 46.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColor.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd-MM-yyyy').format(selectedDate),
                              ),
                              Icon(Icons.calendar_month, size: 18.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                Padding(
                  padding: EdgeInsets.only(top: 22.h),
                  child: InkWell(
                    onTap: isLoading ? null : loadHappyCalls,
                    child: Container(
                      height: 46.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: AppColor.primaryRed,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: isLoading
                          ? SizedBox(
                              height: 18.h,
                              width: 18.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
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
                ),
              ],
            ),
            SizedBox(height: 16.h),

            /// SEARCH BAR
            Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColor.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => _onSearch(), // ensures live update
                      decoration: const InputDecoration(
                        hintText: "Search by name or mobile",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (searchCtrl.text.isNotEmpty)
                    InkWell(
                      onTap: () {
                        searchCtrl.clear();
                      },
                      child: const Icon(Icons.close, size: 18),
                    ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            /// CONTACT LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredContacts.isEmpty
                  ? const Center(child: Text("No Data Found"))
                  : ListView.separated(
                      itemCount: filteredContacts.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final data = filteredContacts[index];
                        return _contactCard(data);
                      },
                    ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  Widget _contactCard(HappyCallModel data) {
    return InkWell(
      onTap: () => _showStatusDialog(data),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.primaryBlue),
        ),
        child: Row(
          children: [
            /// DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.companyName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textDark,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    data.customerName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColor.primaryBlue,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.mobileNo,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.textDark,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: data.status.toLowerCase() == "complete"
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          data.status,
                          style: TextStyle(
                            color: data.status.toLowerCase() == "complete"
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// CALL ICON
            InkWell(
              onTap: () => _makeCall(data.mobileNo),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(Icons.call, color: AppColor.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusDialog(HappyCallModel item) async {
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Update Happy Call Status",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 16.h),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColor.grey),
                  ),
                  child: TextField(
                    controller: commentCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Enter Comments",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (commentCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter comments"),
                              ),
                            );
                            return;
                          }

                          await _updateStatus(
                            item.happycallsSrNo,
                            commentCtrl.text.trim(),
                            "Pending",
                          );
                        },
                        child: Container(
                          height: 46.h,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Pending",
                            style: TextStyle(
                              color: AppColor.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (commentCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter comments"),
                              ),
                            );
                            return;
                          }

                          await _updateStatus(
                            item.happycallsSrNo,
                            commentCtrl.text.trim(),
                            "Complete",
                          );
                        },
                        child: Container(
                          height: 46.h,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Complete",
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

                SizedBox(height: 10.h),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: AppColor.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(
    String happyCallSrNo,
    String comment,
    String status,
  ) async {
    final userSrNo = await AppPref.getUserSrNo();

    final success = await ApiService.updateHappyCallStatus(
      userSrNo: userSrNo ?? "",
      happyCallSrNo: happyCallSrNo,
      comments: comment,
      status: status,
    );

    Navigator.pop(context);

    if (success) {
      await loadHappyCalls();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("$status Updated Successfully"),
        ),
      );

      setState(() {});
    }
  }
}

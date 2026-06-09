import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/project_contractor_model.dart';
import 'package:positive_metering/screens/project_opportunity/bidder/add_bidder_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';

import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ViewBidderScreen extends StatefulWidget {
  final String projectSrNo;
  const ViewBidderScreen({super.key, required this.projectSrNo});

  @override
  State<ViewBidderScreen> createState() => _ViewBidderScreenState();
}

class _ViewBidderScreenState extends State<ViewBidderScreen> {
  List<ProjectContractorModel> bidderList = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadBidders();
  }

  Future<void> loadBidders() async {
    setState(() => isLoading = true);

    final userSrNo = await AppPref.getUserSrNo();

    bidderList = await ApiService.getProjectContractors(
      userSrNo: userSrNo ?? "",
      projectSrNo: widget.projectSrNo,
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,

      appBar: CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: true,
        onAddTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddBidderScreen(projectSrNo: widget.projectSrNo),
            ),
          );
        },
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            Text(
              "Bidders",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bidderList.isEmpty
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      itemCount: bidderList.length,
                      itemBuilder: (context, index) {
                        final item = bidderList[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColor.grey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _row("Name", item.name),
                              _row("Email", item.email),
                              _row("Mobile", item.mobile),
                              _row("Address", item.address),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              "$label :",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}

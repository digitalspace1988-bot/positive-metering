import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/customer_history_model.dart';
import 'package:positive_metering/screens/enquiry/enquiry_detail_screen.dart';
import 'package:positive_metering/screens/follow_up/view_add_follow_up_screen.dart';
import 'package:positive_metering/screens/plan/mark_visit/mark_visit_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final String customerSrNo;
  final String companyName;

  const CustomerHistoryScreen({
    super.key,
    required this.customerSrNo,
    required this.companyName,
  });

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  List<CustomerHistoryModel> historyList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final userSrNo = await AppPref.getUserSrNo();

    final data = await ApiService.getCustomerHistory(
      customerSrNo: widget.customerSrNo,
      userSrNo: userSrNo ?? "",
    );

    setState(() {
      historyList = data;
      isLoading = false;
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

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Text(
              "Customer History",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 6.h),

            Text(
              widget.companyName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColor.grey),
            ),

            SizedBox(height: 18.h),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : historyList.isEmpty
                  ? const Center(child: Text("No History Found"))
                  : ListView.separated(
                      itemCount: historyList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, index) {
                        final data = historyList[index];

                        return InkWell(
                          onTap: () {
                            final type = data.transactionType
                                .toLowerCase()
                                .trim();

                            /// ENQUIRY DETAIL
                            if (type == "enquiry") {
                              Navigator.push(
                                context,
                                AnimatedPageRoute(
                                  page: EnquiryDetailScreen(
                                    enquirySrNo: data.transactionSrNo,
                                  ),
                                ),
                              );
                            }
                            /// ENQUIRY FOLLOW-UP
                            else if (type == "enquiry follow up") {
                              Navigator.push(
                                context,
                                AnimatedPageRoute(
                                  page: ViewAddFollowUpScreen(
                                    type: "enquiry",
                                    enquirySrNo: data.transactionSrNo,
                                    customerSrNo: widget.customerSrNo,
                                    companyName: widget.companyName,
                                  ),
                                ),
                              );
                            }
                            /// VISIT FOLLOW-UP
                            else if (type == "visit follow up") {
                              Navigator.push(
                                context,
                                AnimatedPageRoute(
                                  page: ViewAddFollowUpScreen(
                                    type: "visit",
                                    tourPlanSrNo: data.transactionSrNo,
                                    customerSrNo: widget.customerSrNo,
                                    companyName: widget.companyName,
                                  ),
                                ),
                              );
                            }
                            /// VISIT / TOUR DETAILS
                            else if (type == "tour") {
                              Navigator.push(
                                context,
                                AnimatedPageRoute(
                                  page: MarkVisitScreen(
                                    tourPlanSrNo: data.transactionSrNo,
                                  ),
                                ),
                              );
                            }
                          },

                          borderRadius: BorderRadius.circular(12.r),

                          child: Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColor.primaryBlue),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _row("Type:", data.transactionType),

                                SizedBox(height: 8.h),

                                _row("Date:", data.date),

                                SizedBox(height: 8.h),

                                _row("Transaction ID:", data.transactionSrNo),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textDark,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: AppColor.textDark),
          ),
        ),
      ],
    );
  }
}

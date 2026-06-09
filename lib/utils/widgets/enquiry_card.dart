import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/utils/app_colors.dart';

class EnquiryCard extends StatelessWidget {
  final String enquirySrNo;
  final String date;
  final String companyName;
  final String name;

  const EnquiryCard({
    super.key,
    required this.enquirySrNo,
    required this.date,
    required this.companyName,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          /// LEFT RED BAR (SAME)
          Container(
            width: 4.w,
            height: 110.h,
            decoration: BoxDecoration(
              color: AppColor.primaryRed,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP ROW (SAME UI)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "EnquirySrno: $enquirySrNo",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColor.grey,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Action",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              _actionIcon(
                                Icons.remove_red_eye,
                                AppColor.primaryRed,
                              ),
                              // SizedBox(width: 8.w),
                              // _actionIcon(Icons.edit, AppColor.primaryBlue),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  /// DATE (dynamic)
                  Text("Date: $date", style: TextStyle(fontSize: 14.sp)),

                  SizedBox(height: 6.h),

                  /// COMPANY NAME (dynamic)
                  Text(
                    "Customer Name: $companyName",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 6.h),

                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: AppColor.primaryRed,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColor.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(7.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, size: 18.sp, color: AppColor.white),
    );
  }
}

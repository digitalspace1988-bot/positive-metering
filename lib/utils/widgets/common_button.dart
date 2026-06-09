import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/utils/app_colors.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading; // NEW

  const CommonButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false, // default
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // disable click when loading
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColor.primaryRed,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.white,
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/screens/home/home_screen.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                /// Logo
                Center(
                  child: Image.asset(
                    'assets/images/Positive-Logo.png',
                    width: screenWidth * 0.4,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 50.h),

                /// Enter OTP Text
                Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.black,
                  ),
                ),

                SizedBox(height: 6.h),

                /// OTP Field
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Enter your OTP",
                    hintStyle: TextStyle(color: AppColor.grey, fontSize: 13.sp),
                    filled: true,
                    fillColor: AppColor.lightGrey,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 50.h),

                /// Submit Button
                CommonButton(
                  title: "Login",
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      AnimatedPageRoute(page: HomeScreen()),
                    );
                  },
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

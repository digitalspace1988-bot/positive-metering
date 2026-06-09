import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/screens/home/home_screen.dart';
import 'package:positive_metering/screens/login/otp/otp_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isOtpSent = false;
  bool isLoading = false;

  void handleSendOtp() async {
    setState(() => isLoading = true);

    bool success = await ApiService.sendOtp(emailController.text.trim());

    setState(() => isLoading = false);

    if (success) {
      setState(() => isOtpSent = true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send OTP")));
    }
  }

  void handleLogin() async {
    setState(() => isLoading = true);

    final user = await ApiService.login(
      email: emailController.text.trim(),
      otp: otpController.text.trim(),
    );

    setState(() => isLoading = false);

    if (user != null) {
      await AppPref.saveUser(user);

      Navigator.pushReplacement(context, AnimatedPageRoute(page: HomeScreen()));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Failed")));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
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
            padding: EdgeInsets.symmetric(horizontal: 34.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                /// Logo
                Center(
                  child: Image.asset(
                    'assets/images/Positive-Logo.png',
                    width: screenWidth * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),

                /// Email
                _titleText("Email Address"),
                SizedBox(height: 6.h),
                _inputField(
                  controller: emailController,
                  hint: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                ),
                if (isOtpSent) ...[
                  SizedBox(height: 20.h),

                  _titleText("Enter OTP"),
                  SizedBox(height: 6.h),

                  _inputField(
                    controller: otpController,
                    hint: "Enter OTP",
                    keyboardType: TextInputType.number,
                  ),
                ],

                SizedBox(height: 50.h),

                /// Submit Button
                CommonButton(
                  title: isOtpSent ? "Login" : "Send OTP",
                  onTap: isOtpSent ? handleLogin : handleSendOtp,
                  isLoading: isLoading,
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.black,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColor.grey, fontSize: 13.sp),
        filled: true,
        fillColor: AppColor.lightGrey,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

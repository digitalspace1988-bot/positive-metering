import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:positive_metering/screens/home/home_screen.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class SubmitVisitScreen extends StatefulWidget {
  const SubmitVisitScreen({super.key});

  @override
  State<SubmitVisitScreen> createState() => _SubmitVisitScreenState();
}

class _SubmitVisitScreenState extends State<SubmitVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController commentsCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,

      /// APP BAR
      appBar: const CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: false,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            /// TITLE
            Text(
              "Confirm Visit",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textDark,
              ),
            ),

            SizedBox(height: 24.h),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// IMAGE UPLOAD BOX
                      GestureDetector(
                        onTap: _openCamera,
                        child: Container(
                          height: 120.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.lightGrey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColor.grey.withOpacity(0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16.w),
                                child: Text(
                                  "Click the photo of an\nIssues",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColor.textDark,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.w),
                                child: Container(
                                  padding: EdgeInsets.all(14.w),
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryBlue,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: AppColor.white,
                                    size: 28.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      /// COMMENTS
                      Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 80.h,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        child: TextFormField(
                          controller: commentsCtrl,
                          maxLines: null,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Comments are required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Description",
                            border: InputBorder.none,
                            errorStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      /// SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: _onSubmit,
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
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

  /// SUBMIT HANDLER
  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
      (route) => false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ProjectContactScreen extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;
  final String userSrNo;
  final String projectSrNo;

  const ProjectContactScreen({
    super.key,
    required this.onSubmit,
    required this.userSrNo,
    required this.projectSrNo,
  });

  @override
  State<ProjectContactScreen> createState() => _ProjectContactScreenState();
}

class _ProjectContactScreenState extends State<ProjectContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController(text: "");
  final emailCtrl = TextEditingController(text: "");
  final mobCtrl = TextEditingController(text: "");
  final addrCtrl = TextEditingController(text: "");
  final desCtrl = TextEditingController(text: "");

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    mobCtrl.dispose();
    addrCtrl.dispose();
    desCtrl.dispose();
    super.dispose();
  }

  void resetForm() {
    nameCtrl.clear();
    emailCtrl.clear();
    mobCtrl.clear();
    addrCtrl.clear();
    desCtrl.clear();
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.textDark,
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
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
            SizedBox(height: 16.h),
            Text(
              "Add Contact Information",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textDark,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Full Name"),
                      _textField(nameCtrl, "Enter Contact Name"),

                      SizedBox(height: 18.h),
                      _label("Email Address"),
                      _textField(
                        emailCtrl,
                        "Enter Email Address",
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 18.h),
                      _label("Mobile Phone Number"),
                      _textField(
                        mobCtrl,
                        "Enter Contact Number",
                        keyboardType: TextInputType.phone,
                      ),

                      SizedBox(height: 18.h),
                      _label("Address"),
                      _textField(addrCtrl, "Enter Address", maxLines: 4),

                      SizedBox(height: 18.h),
                      _label("Designation"),
                      _textField(desCtrl, "Enter Designation"),

                      SizedBox(height: 30.h),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                Navigator.pop(context);
                                widget.onSubmit({
                                  'usersrno': widget.userSrNo,
                                  'project_srno': widget.projectSrNo,
                                  'name': nameCtrl.text.trim(),
                                  'email': emailCtrl.text.trim(),
                                  'mobile': mobCtrl.text.trim(),
                                  'address': addrCtrl.text.trim(),
                                  'designation': desCtrl.text.trim(),
                                });
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
                            child: InkWell(
                              onTap: resetForm,
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
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
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
}

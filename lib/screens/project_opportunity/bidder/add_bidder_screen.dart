import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddBidderScreen extends StatefulWidget {
  final String projectSrNo;
  const AddBidderScreen({super.key, required this.projectSrNo});

  @override
  State<AddBidderScreen> createState() => _AddBidderScreenState();
}

class _AddBidderScreenState extends State<AddBidderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  final TextEditingController bidderNameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  @override
  void dispose() {
    bidderNameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  void resetForm() {
    bidderNameCtrl.clear();
    mobileCtrl.clear();
    emailCtrl.clear();
    addressCtrl.clear();
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
              "Add Bidder",
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
                      _label("Bidder Name"),
                      _textField(bidderNameCtrl, "Enter Bidder Name"),

                      SizedBox(height: 18.h),

                      _label("Contact Number"),
                      _textField(
                        mobileCtrl,
                        "Enter Contact Number",
                        keyboardType: TextInputType.phone,
                      ),

                      SizedBox(height: 18.h),

                      _label("Email"),
                      _textField(
                        emailCtrl,
                        "Enter Email",
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 18.h),

                      _label("Address"),
                      _textField(addressCtrl, "Enter Address", maxLines: 4),

                      SizedBox(height: 30.h),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: isSaving
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      setState(() => isSaving = true);

                                      final userSrNo =
                                          await AppPref.getUserSrNo();

                                      final success =
                                          await ApiService.addProjectContractor(
                                            userSrNo: userSrNo ?? "",
                                            projectSrNo: widget.projectSrNo,
                                            name: bidderNameCtrl.text.trim(),
                                            email: emailCtrl.text.trim(),
                                            mobile: mobileCtrl.text.trim(),
                                            address: addressCtrl.text.trim(),
                                          );

                                      setState(() => isSaving = false);

                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                              "Bidder Added Successfully",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );

                                        Navigator.pop(context, true);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              "Failed To Add Bidder",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              child: isSaving
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Container(
                                      height: 46.h,
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryRed,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
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

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
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
}

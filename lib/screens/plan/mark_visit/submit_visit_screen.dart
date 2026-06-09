import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/product_model.dart';
import 'package:positive_metering/screens/enquiry/enquiry_screen.dart';
import 'package:positive_metering/screens/home/home_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';

import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class SubmitVisitScreen extends StatefulWidget {
  final String tourPlanSrNo;
  const SubmitVisitScreen({super.key, required this.tourPlanSrNo});

  @override
  State<SubmitVisitScreen> createState() => _SubmitVisitScreenState();
}

class _SubmitVisitScreenState extends State<SubmitVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  DateTime? followupDate;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  String? enquiryGenerated;
  final TextEditingController commentsCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? issueImage;

  final Set<String> selectedProducts = {};

  List<ProductModel> productList = [];
  bool isLoadingProducts = false;

  Future<void> _openCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        issueImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoadingProducts = true);

    final data = await ApiService.getProducts();

    setState(() {
      productList = data;
      isLoadingProducts = false;
    });
  }

  Future<File?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 60,
    );

    if (result == null) return null;

    final compressedFile = File("${file.path}_compressed.jpg")
      ..writeAsBytesSync(result);

    return compressedFile;
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
              "Submit Visit",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 24.h),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// IMAGE PICKER BOX
                      _imageBox(),

                      SizedBox(height: 20.h),

                      _label("Comments"),
                      _textField(commentsCtrl, "Description"),

                      SizedBox(height: 20.h),

                      _label("Follow-up Date (Optional)"),
                      _followupDateField(),

                      SizedBox(height: 20.h),

                      _label("Enquiry Generated"),
                      _dropdown(
                        "Select the type",
                        enquiryGenerated,
                        (v) => setState(() => enquiryGenerated = v),
                      ),

                      if (enquiryGenerated == "Yes") ...[
                        SizedBox(height: 20.h),
                        _label("Product"),
                        _productGrid(),
                      ],

                      SizedBox(height: 30.h),

                      _submitButton(),
                      SizedBox(height: 40.h),
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

  Widget _followupDateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() => followupDate = picked);
        }
      },
      child: Container(
        height: 46.h,
        margin: EdgeInsets.only(top: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColor.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              followupDate == null
                  ? "Select Date"
                  : _formatter.format(followupDate!),
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  Widget _productGrid() {
    if (isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productList.isEmpty) {
      return const Text("No products available");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 10.h),
      itemCount: productList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, index) {
        final item = productList[index];
        final isSelected = selectedProducts.contains(item.productSrNo);

        return InkWell(
          onTap: () {
            setState(() {
              isSelected
                  ? selectedProducts.remove(item.productSrNo)
                  : selectedProducts.add(item.productSrNo);
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? AppColor.primaryRed : AppColor.grey,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              item.productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: isSelected ? AppColor.primaryRed : AppColor.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  // UI WIDGETS

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _imageBox() {
    return InkWell(
      onTap: _openCamera,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.lightGrey,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColor.grey.withOpacity(0.4)),
        ),
        child: issueImage == null
            ? Row(
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
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.file(
                  issueImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      height: 80.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Comments are required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, Function(String?) onChanged) {
    final items = ["Yes", "No"];

    return Container(
      height: 46.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // SUBMIT BUTTON

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed: isSubmitting ? null : _onSubmit, // 🚫 disable click
        child: isSubmitting
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Submit",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                ),
              ),
      ),
    );
  }

  // NAVIGATION LOGIC

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (enquiryGenerated == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Select enquiry type")));
      return;
    }

    if (enquiryGenerated == "Yes" && selectedProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Select at least one product")));
      return;
    }

    setState(() => isSubmitting = true); // START LOADING

    try {
      File? compressedImage;

      if (issueImage != null) {
        compressedImage = await compressImage(issueImage!);
      }

      final userSrNo = await AppPref.getUserSrNo();

      final success = await ApiService.addVisit(
        userSrNo: userSrNo ?? "",
        tourPlanSrNo: widget.tourPlanSrNo,
        comments: commentsCtrl.text,
        followupDate: followupDate != null
            ? _formatter.format(followupDate!)
            : null,
        enquiryGenerated: enquiryGenerated!,
        productSrNo: enquiryGenerated == "Yes"
            ? selectedProducts.join(",")
            : null,
        imageFile: compressedImage,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColor.green,
            content: Text("Visit Marked Successfully"),
          ),
        );

        if (enquiryGenerated == "Yes") {
          Navigator.pushAndRemoveUntil(
            context,
            AnimatedPageRoute(page: EnquiryScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            AnimatedPageRoute(page: HomeScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColor.primaryBlue,
            content: Text(
              "Failed to submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.primaryBlue,
          content: Text(
            "Something went wrong",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false); //  STOP LOADING
      }
    }
  }
}

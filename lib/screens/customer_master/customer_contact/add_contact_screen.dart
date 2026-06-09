import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/common_model.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddContactScreen extends StatefulWidget {
  final String customerSrNo;

  const AddContactScreen({super.key, required this.customerSrNo});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final landlineCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();

  List<CommonModel> sourceList = [];

  String? selectedSource;

  bool isLoadingSource = true;

  bool isSaving = false;

  Future<void> saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final userSrNo = await AppPref.getUserSrNo();

    if (selectedSource == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select source")));

      setState(() => isSaving = false);

      return;
    }

    final success = await ApiService.addCustomerContact(
      customerSrNo: widget.customerSrNo,
      customerName: nameCtrl.text,
      mobileNo: mobileCtrl.text,
      landlineNo: landlineCtrl.text,
      email: emailCtrl.text,
      designation: designationCtrl.text,
      address: addressCtrl.text,
      userSrNo: userSrNo ?? "",
      department: departmentCtrl.text,
      sourceSrNo: selectedSource!,
    );

    setState(() => isSaving = false);

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Contact Added Successfully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadSources();
  }

  Future<void> loadSources() async {
    final userSrNo = await AppPref.getUserSrNo();

    sourceList = await ApiService.getSource(userSrNo: userSrNo ?? "");

    setState(() {
      isLoadingSource = false;
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
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(nameCtrl, "Customer Name"),
                _field(mobileCtrl, "Mobile No"),
                _field(landlineCtrl, "Landline No"),
                _field(emailCtrl, "Email"),
                _field(designationCtrl, "Designation"),
                _field(departmentCtrl, "Department"),
                _field(addressCtrl, "Address", maxLines: 3),
                Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSource,
                        hint: const Text("Select Source"),
                        isExpanded: true,
                        items: sourceList.map((e) {
                          return DropdownMenuItem(
                            value: e.id,
                            child: Text(e.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedSource = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryBlue,
                    ),
                    onPressed: isSaving ? null : saveContact,
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Add Contact",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      ),
    );
  }
}

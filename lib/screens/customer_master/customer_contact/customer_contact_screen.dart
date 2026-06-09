import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/customer_contact_model.dart';
import 'package:positive_metering/screens/customer_master/customer_contact/add_contact_screen.dart';

import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class CustomerContactScreen extends StatefulWidget {
  final String customerSrNo;
  final String companyName;

  const CustomerContactScreen({
    super.key,
    required this.customerSrNo,
    required this.companyName,
  });

  @override
  State<CustomerContactScreen> createState() => _CustomerContactScreenState();
}

class _CustomerContactScreenState extends State<CustomerContactScreen> {
  List<CustomerContactModel> contactList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final userSrNo = await AppPref.getUserSrNo();

    final data = await ApiService.getCustomerContacts(
      customerSrNo: widget.customerSrNo,
      userSrNo: userSrNo ?? "",
    );

    setState(() {
      contactList = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,

      appBar: CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: true,
        onAddTap: () {
          Navigator.push(
            context,
            AnimatedPageRoute(
              page: AddContactScreen(customerSrNo: widget.customerSrNo),
            ),
          ).then((_) => loadContacts());
        },
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Text(
              widget.companyName,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contactList.isEmpty
                  ? const Center(child: Text("No Contacts Found"))
                  : ListView.separated(
                      itemCount: contactList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, index) {
                        final data = contactList[index];

                        return Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColor.primaryBlue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _row("Name:", data.customerName),
                              SizedBox(height: 6.h),

                              _row("Mobile:", data.mobileNo),
                              SizedBox(height: 6.h),

                              _row("Landline:", data.landlineNo),
                              SizedBox(height: 6.h),

                              _row("Email:", data.email),
                              SizedBox(height: 6.h),

                              _row("Designation:", data.designation),
                              SizedBox(height: 6.h),

                              _row("Department:", data.department),
                              SizedBox(height: 6.h),

                              _row("Source:", data.source),
                              SizedBox(height: 6.h),

                              _row("Address:", data.address),
                            ],
                          ),
                        );
                      },
                    ),
            ),
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
          width: 95.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ),

        Expanded(
          child: Text(value, style: TextStyle(fontSize: 14.sp)),
        ),
      ],
    );
  }
}

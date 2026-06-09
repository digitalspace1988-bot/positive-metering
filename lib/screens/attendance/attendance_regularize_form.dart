import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_button.dart';

class AttendanceRegularizeForm extends StatefulWidget {
  final String srno;

  const AttendanceRegularizeForm({super.key, required this.srno});

  @override
  State<AttendanceRegularizeForm> createState() =>
      _AttendanceRegularizeFormState();
}

class _AttendanceRegularizeFormState extends State<AttendanceRegularizeForm> {
  DateTime? attendanceDate;
  final TextEditingController commentController = TextEditingController();
  bool isLoading = false;
  String? usersrno;

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  bool get isValid =>
      attendanceDate != null && commentController.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: attendanceDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primaryRed,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => attendanceDate = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    usersrno = await AppPref.getUserSrNo();
  }

  void _submit() async {
    if (!isValid || usersrno == null || isLoading) return;

    setState(() => isLoading = true);

    final res = await ApiService.addAttendanceRegularize(
      usersrno: usersrno!,
      srno: widget.srno,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res['status'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.green,
          content: Text(
            "Request submitted successfully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.green,
          content: Text(
            res['message'] ?? "Failed",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: const CommonAppBar(showBack: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              "Attendance Regularize",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 20.h),

            InkWell(
              onTap: _pickDate,
              child: Container(
                height: 45.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      attendanceDate == null
                          ? "Select Date"
                          : formatter.format(attendanceDate!),
                    ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            TextField(
              controller: commentController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "Enter reason...",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: SizedBox(
                width: double.infinity,
                child: SizedBox(
                  width: double.infinity,
                  child: Opacity(
                    opacity: isValid ? 1 : 0.4,
                    child: IgnorePointer(
                      ignoring: !isValid,
                      child: CommonButton(
                        title: "Submit",
                        isLoading: isLoading,
                        onTap: _submit,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 35.h),
          ],
        ),
      ),
    );
  }
}

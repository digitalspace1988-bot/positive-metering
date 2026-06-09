import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/project_followup_detail_model.dart';
import 'package:positive_metering/model/project_followup_model.dart';
import 'package:positive_metering/model/project_status_model.dart';
import 'package:positive_metering/screens/follow_up/follow_up_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ProjectViewAddFollowUpScreen extends StatefulWidget {
  final String projectSrNo;
  final String projectTitle;

  const ProjectViewAddFollowUpScreen({
    super.key,
    required this.projectSrNo,
    required this.projectTitle,
  });

  @override
  State<ProjectViewAddFollowUpScreen> createState() =>
      _ProjectViewAddFollowUpScreenState();
}

class _ProjectViewAddFollowUpScreenState
    extends State<ProjectViewAddFollowUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  // ── form state ────────────────────────────────────────────────────────
  DateTime? followupDate;
  DateTime? nextFollowupDate;

  final TextEditingController commentCtrl = TextEditingController();

  List<ProjectStatusModel> statusList = [];
  String? selectedStatusSrNo;

  // ── history ───────────────────────────────────────────────────────────
  List<ProjectFollowupDetailModel> historyData = [];
  bool isHistoryLoading = true;

  // ── misc ──────────────────────────────────────────────────────────────
  bool isLoading = true;
  bool isSaving = false;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadData();
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    user = await AppPref.getUser();
    setState(() {});
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    final userSrNo = await AppPref.getUserSrNo();

    statusList = await ApiService.getProjectStatus(userSrNo: userSrNo ?? "");

    setState(() {
      isLoading = false;
      if (statusList.isNotEmpty) {
        selectedStatusSrNo = statusList.first.statusSrNo;
      }
    });

    await fetchFollowUpHistory();
  }

  Future<void> fetchFollowUpHistory() async {
    setState(() => isHistoryLoading = true);

    try {
      final raw = await ApiService.getProjectFollowupDetails(
        projectSrNo: widget.projectSrNo,
      );
      historyData =
          raw.map((e) => ProjectFollowupDetailModel.fromJson(e)).toList();
    } catch (e) {
      historyData = [];
    }

    setState(() => isHistoryLoading = false);
  }

  void _reset() {
    setState(() {
      followupDate = null;
      nextFollowupDate = null;
      commentCtrl.clear();
      if (statusList.isNotEmpty) {
        selectedStatusSrNo = statusList.first.statusSrNo;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final userSrNo = await AppPref.getUserSrNo();

    try {
      final success = await ApiService.addProjectFollowup(
        projectSrNo: widget.projectSrNo,
        userSrNo: userSrNo ?? "",
        comments: commentCtrl.text.trim(),
        projectFollowupDate:
            _formatter.format(followupDate ?? DateTime.now()),
        statusSrNo: selectedStatusSrNo ?? "",
        nextFollowup: nextFollowupDate != null
            ? _formatter.format(nextFollowupDate!)
            : "",
      );

      setState(() => isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text(
              "Follow-up Added",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const FollowUpScreen(type: "project"),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.primaryBlue,
          content: const Text(
            "Failed",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CommonAppBar(showBack: true, showDrawer: false, showAdd: false),
      bottomNavigationBar: _actionButtons(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Text(
              "View and Add Follow-up",
              style:
                  TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Date ──────────────────────────────────────────
                      _label("Date"),
                      _dateField(
                        followupDate ?? DateTime.now(),
                        (d) => followupDate = d,
                      ),

                      SizedBox(height: 20.h),

                      // ── Project Title (read-only, like Company Name) ───
                      _label("Project Title"),
                      Container(
                        height: 46.h,
                        margin: EdgeInsets.only(top: 6.h),
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(widget.projectTitle),
                      ),

                      SizedBox(height: 24.h),

                      // ── Follow-up History ─────────────────────────────
                      _followUpHistory(),

                      SizedBox(height: 24.h),

                      // ── Status ────────────────────────────────────────
                      _label("Status"),
                      _statusDropdown(),

                      SizedBox(height: 20.h),

                      // ── Next Follow-up Date ───────────────────────────
                      _label("Next Follow-up Date"),
                      _dateField(nextFollowupDate, (d) => nextFollowupDate = d),

                      SizedBox(height: 20.h),

                      // ── Comments ──────────────────────────────────────
                      _label("Comments"),
                      _textField(commentCtrl, "Description"),
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

  // ── widgets (identical style to ViewAddFollowUpScreen) ────────────────

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateField(DateTime? date, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme:
                    ColorScheme.light(primary: AppColor.primaryRed),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => onPicked(picked));
      },
      child: Container(
        height: 46.h,
        margin: EdgeInsets.only(top: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColor.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null ? "Select Date" : _formatter.format(date)),
            const Icon(Icons.calendar_month),
          ],
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

  Widget _statusDropdown() {
    if (isLoading) {
      return Container(
        height: 46.h,
        alignment: Alignment.center,
        child: SizedBox(
          height: 20.h,
          width: 20.h,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

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
          value: selectedStatusSrNo,
          hint: const Text("Select Status"),
          isExpanded: true,
          items: statusList.map((s) {
            return DropdownMenuItem<String>(
              value: s.statusSrNo,
              child: Text(s.statusName),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedStatusSrNo = val),
        ),
      ),
    );
  }

  Widget _followUpHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Follow-up History",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textDark,
          ),
        ),
        SizedBox(height: 10.h),

        if (isHistoryLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: const CircularProgressIndicator(),
            ),
          )
        else if (historyData.isEmpty)
          const Center(child: Text("No History Found"))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: DataTable(
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppColor.grey),
                  verticalInside: BorderSide(color: AppColor.grey),
                ),
                headingRowColor:
                    MaterialStateProperty.all(AppColor.primaryRed),
                columnSpacing: 24.w,
                columns: const [
                  DataColumn(
                    label: Text(
                      "Followup Date",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Comments",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Status",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Next Followup Date",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Added By",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                rows: historyData.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.followupDate)),
                      DataCell(
                        SizedBox(
                          width: 160.w,
                          child: Text(
                            item.followupComment,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.status
                              .replaceAll("\n", " ")
                              .replaceAll("\r", ""),
                        ),
                      ),
                      DataCell(Text(item.nextFollowup)),
                      DataCell(Text(item.name)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 50.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: isSaving ? null : _save,
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: isSaving
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                            color: Colors.white),
                      )
                    : Text(
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
              onTap: _reset,
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
    );
  }
}
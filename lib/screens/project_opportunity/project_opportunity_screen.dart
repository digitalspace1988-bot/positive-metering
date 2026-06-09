import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/project_model.dart';
import 'package:positive_metering/screens/project_opportunity/bidder/add_bidder_screen.dart';
import 'package:positive_metering/screens/project_opportunity/add_project_plan_screen.dart';
import 'package:positive_metering/screens/project_opportunity/project_detail_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class ProjectOpportunityScreen extends StatefulWidget {
  const ProjectOpportunityScreen({super.key});

  @override
  State<ProjectOpportunityScreen> createState() =>
      _ProjectOpportunityScreenState();
}

class _ProjectOpportunityScreenState extends State<ProjectOpportunityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchCtrl = TextEditingController();

  List<ProjectModel> filteredProjectList = [];

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  List<ProjectModel> projectList = [];
  bool isLoading = false;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadProjects();
    searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      filteredProjectList = projectList.where((item) {
        return item.projectTitle.toLowerCase().contains(query) ||
            item.regionName.toLowerCase().contains(query) ||
            item.clientName.toLowerCase().contains(query) ||
            item.clientContactNumber.toLowerCase().contains(query) ||
            item.projectValue.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> loadProjects() async {
    setState(() => isLoading = true);
    final userSrNo = await AppPref.getUserSrNo();
    projectList = await ApiService.getProjects(
      userSrNo: userSrNo ?? "",
      fromDate: _formatter.format(fromDate),
      toDate: _formatter.format(toDate),
    );
    filteredProjectList = List.from(projectList);
    setState(() => isLoading = false);
  }

  Future<void> loadUser() async {
    user = await AppPref.getUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: user?['projects_add'] == "y",
        onAddTap: () {
          Navigator.push(
            context,
            AnimatedPageRoute(page: AddProjectPlanScreen()),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Project Opportunity",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColor.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (searchCtrl.text.isNotEmpty)
                    InkWell(
                      onTap: () => searchCtrl.clear(),
                      child: const Icon(Icons.close, size: 18),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProjectList.isEmpty
                  ? const Center(child: Text("No Data Found"))
                  : ListView.builder(
                      itemCount: filteredProjectList.length,
                      itemBuilder: (context, index) {
                        return _ProjectOpportunityCard(
                          project: filteredProjectList[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await _showPicker(fromDate);
    if (picked != null) {
      setState(() {
        fromDate = picked;
        toDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await _showPicker(toDate, first: fromDate);
    if (picked != null) {
      setState(() => toDate = picked);
    }
  }

  Future<DateTime?> _showPicker(DateTime initial, {DateTime? first}) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColor.primaryRed),
          ),
          child: child!,
        );
      },
    );
  }

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatter.format(date)),
                  Icon(Icons.calendar_month, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton() {
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: InkWell(
        onTap: isLoading ? null : loadProjects,
        child: Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            color: AppColor.primaryRed,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  height: 18.h,
                  width: 18.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "View",
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------------
/// PROJECT OPPORTUNITY CARD
/// ------------------------------------------------------------------
class _ProjectOpportunityCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectOpportunityCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          AnimatedPageRoute(
            page: ProjectDetailScreen(projectSrNo: project.projectSrNo),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          // Darkened opportunity card border layout bit to match specifications
          border: Border.all(color: AppColor.grey.withOpacity(0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: AppColor.primaryRed,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _infoRow("Project Name", project.projectTitle),
                      ),
                      InkWell(
                        onTap: () async {
                          final String? userSrNo = await AppPref.getUserSrNo();
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              AnimatedPageRoute(
                                page: ProjectContactsDetailScreen(
                                  userSrNo: userSrNo ?? "1",
                                  projectSrNo: project.projectSrNo.toString(),
                                  projectName: project.projectTitle,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColor.primaryBlue,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.person_add,
                            color: AppColor.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _infoRow("Region", project.regionName),
                  _infoRow("Project Value", project.projectValue),
                  _infoRow("Client Name", project.clientName),
                  _infoRow("Contact Number", project.clientContactNumber),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            AnimatedPageRoute(
                              page: ProjectDetailScreen(
                                projectSrNo: project.projectSrNo,
                              ),
                            ),
                          );
                        },
                        child: _iconBox(
                          Icons.remove_red_eye,
                          AppColor.primaryRed,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddBidderScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 30.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: AppColor.primaryBlue,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Add Bidder",
                            style: TextStyle(color: AppColor.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: AppColor.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, color: AppColor.white, size: 16.sp),
    );
  }
}

/// ------------------------------------------------------------------
/// NEW SUB-SCREEN: DETAILED CUSTOMER CONTACTS VIEWPORT
/// ------------------------------------------------------------------
class ProjectContactsDetailScreen extends StatefulWidget {
  final String userSrNo;
  final String projectSrNo;
  final String projectName;

  const ProjectContactsDetailScreen({
    super.key,
    required this.userSrNo,
    required this.projectSrNo,
    required this.projectName,
  });

  @override
  State<ProjectContactsDetailScreen> createState() =>
      _ProjectContactsDetailScreenState();
}

class _ProjectContactsDetailScreenState
    extends State<ProjectContactsDetailScreen> {
  List<dynamic> contactsList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    setState(() => isLoading = true);
    final String url =
        "https://digitalspaceinc.com/positive_metering/ws/getprojectcontacts.php?usersrno=${widget.userSrNo}&project_srno=${widget.projectSrNo}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List<dynamic> rawList = [];

        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map) {
          if (decodedData.containsKey('data')) {
            rawList = decodedData['data'];
          } else if (decodedData.containsKey('contacts')) {
            rawList = decodedData['contacts'];
          }
        }

        final seenRecords = <String>{};
        final List<dynamic> distinctContacts = [];

        for (var item in rawList) {
          if (item is Map) {
            final String nameKey = (item['name'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            final String phoneKey = (item['mobile'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            final String compositeUniqueKey = "${nameKey}_$phoneKey";

            if (!seenRecords.contains(compositeUniqueKey) &&
                compositeUniqueKey != "_") {
              seenRecords.add(compositeUniqueKey);
              distinctContacts.add(item);
            }
          }
        }

        contactsList = distinctContacts;
      }
    } catch (e) {
      debugPrint("GET Request Exception: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> addContact(Map<String, String> bodyData) async {
    setState(() => isLoading = true);
    final String url =
        "https://digitalspaceinc.com/positive_metering/ws/addprojectcontacts.php";

    try {
      final response = await http.post(Uri.parse(url), body: bodyData);
      final decoded = json.decode(response.body);

      if (decoded['status'] == 0 || decoded['message'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Contact Profile Saved Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server message: ${decoded['message']}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submission Failure: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
            MaterialPageRoute(
              builder: (_) => AddContactFormPage(
                onSubmit: (formData) => addContact(formData),
                userSrNo: widget.userSrNo,
                projectSrNo: widget.projectSrNo,
              ),
            ),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Center(
              child: Text(
                widget.projectName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textDark,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contactsList.isEmpty
                  ? const Center(
                      child: Text("No Stakeholder Contacts Assigned"),
                    )
                  : ListView.builder(
                      itemCount: contactsList.length,
                      itemBuilder: (context, idx) {
                        final item = contactsList[idx] is Map
                            ? contactsList[idx]
                            : {};

                        // --- REMOVED THE GENERIC NAME HEADER BLOCK VIEW ENTRIES ---
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(
                              12.r,
                            ), // Darkened to 12.r constraint bounds
                            border: Border.all(
                              color: AppColor.grey.withOpacity(0.6),
                            ), // Darkened bit border mask opacity to 0.6
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoLabelRow(
                                "Name",
                                item['name']?.toString() ?? '-',
                              ),
                              _infoLabelRow(
                                "Role",
                                item['designation']?.toString() ?? '-',
                              ),
                              _infoLabelRow(
                                "Mobile",
                                item['mobile']?.toString() ?? '-',
                              ),
                              _infoLabelRow(
                                "Email",
                                item['email']?.toString() ?? '-',
                              ),
                              _infoLabelRow(
                                "Address",
                                item['address']?.toString() ?? '-',
                              ),
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

  Widget _infoLabelRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.textDark,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: AppColor.grey),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------------
/// MATCHED PURE WHITE FULL SCREEN FORM PAGE COMPONENT
/// ------------------------------------------------------------------
class AddContactFormPage extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;
  final String userSrNo;
  final String projectSrNo;

  const AddContactFormPage({
    super.key,
    required this.onSubmit,
    required this.userSrNo,
    required this.projectSrNo,
  });

  @override
  State<AddContactFormPage> createState() => _AddContactFormPageState();
}

class _AddContactFormPageState extends State<AddContactFormPage> {
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

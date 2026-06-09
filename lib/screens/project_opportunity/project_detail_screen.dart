import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/project_detail_model.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectSrNo;

  const ProjectDetailScreen({super.key, required this.projectSrNo});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool isLoading = true;

  ProjectDetailModel? project;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    project = await ApiService.getProjectDetail(
      projectSrNo: widget.projectSrNo,
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CommonAppBar(showBack: true, showDrawer: false, showAdd: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : project == null
          ? const Center(child: Text("No Data Found"))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),

                  Center(
                    child: Text(
                      "Project Details",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  _label("Project Date"),
                  _readOnlyField(project!.projectDate),

                  SizedBox(height: 16.h),

                  _label("Project Title"),
                  _readOnlyField(project!.projectTitle),

                  SizedBox(height: 16.h),

                  _label("Project Value"),
                  _readOnlyField(project!.projectValue),

                  SizedBox(height: 16.h),

                  _label("Client Name"),
                  _readOnlyField(project!.clientName),

                  SizedBox(height: 16.h),

                  _label("Client Contact Number"),
                  _readOnlyField(project!.clientContactNumber),

                  SizedBox(height: 16.h),

                  _label("Client Email"),
                  _readOnlyField(project!.clientEmail),

                  SizedBox(height: 16.h),

                  _label("Industry"),
                  _readOnlyField(project!.industrySrNo),

                  SizedBox(height: 16.h),

                  _label("Project Status"),
                  _readOnlyField(project!.statusSrNo),

                  SizedBox(height: 16.h),

                  _label("Category"),
                  _readOnlyField(project!.categorySrNo),

                  SizedBox(height: 16.h),

                  _label("Region"),
                  _readOnlyField(project!.regionSrNo),

                  SizedBox(height: 16.h),

                  _label("Sub Region"),
                  _readOnlyField(project!.subregionSrNo),

                  SizedBox(height: 16.h),

                  _label("Country"),
                  _readOnlyField(project!.countrySrNo),

                  SizedBox(height: 16.h),

                  _label("State"),
                  _readOnlyField(project!.stateSrNo),

                  SizedBox(height: 16.h),

                  _label("District"),
                  _readOnlyField(project!.districtSrNo),

                  SizedBox(height: 16.h),

                  _label("City"),
                  _readOnlyField(project!.citySrNo),

                  SizedBox(height: 16.h),

                  _label("Area"),
                  _readOnlyField(project!.areaSrNo),

                  SizedBox(height: 75.h),
                ],
              ),
            ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.black,
      ),
    );
  }

  Widget _readOnlyField(String value) {
    return Container(
      height: 46.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value.isEmpty ? "-" : value,
        style: TextStyle(fontSize: 14.sp, color: AppColor.textDark),
      ),
    );
  }
}

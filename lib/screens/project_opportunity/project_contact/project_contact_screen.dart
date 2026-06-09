import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class ProjectContactScreen extends StatefulWidget {
  const ProjectContactScreen({super.key});

  @override
  State<ProjectContactScreen> createState() => _ProjectContactScreenState();
}

class _ProjectContactScreenState extends State<ProjectContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,

      appBar: CommonAppBar(
        showBack: true,
        showDrawer: false,
        showAdd: true,
        onAddTap: () {},
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(children: [
            
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/utils/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool showAdd;
  final bool showDrawer;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onAddTap;

  const CommonAppBar({
    super.key,
    this.scaffoldKey,
    this.showAdd = false,
    this.showDrawer = true,
    this.showBack = false,
    this.onBack,
    this.onAddTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1.h, color: AppColor.black.withOpacity(0.4)),
      ),

      /// LEADING
      leading: showBack
          ? IconButton(
              icon: CircleAvatar(
                backgroundColor: AppColor.lightGrey,
                child: Icon(Icons.arrow_back, color: AppColor.textDark),
              ),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : showDrawer
          ? IconButton(
              icon: CircleAvatar(
                backgroundColor: AppColor.lightGrey,
                child: Icon(Icons.menu, color: AppColor.textDark),
              ),
              onPressed: () => scaffoldKey?.currentState?.openDrawer(),
            )
          : null,

      centerTitle: true,
      title: Image.asset('assets/images/Positive-Logo.png', width: 100.w),

      /// ACTIONS
      actions: [
        IconButton(
          icon: CircleAvatar(
            backgroundColor: AppColor.lightGrey,
            child: Icon(Icons.notifications_none, color: AppColor.textDark),
          ),
          onPressed: () {},
        ),
        if (showAdd)
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: InkWell(
              onTap: onAddTap,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryRed,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.add, color: AppColor.white, size: 20.sp),
              ),
            ),
          ),
      ],
    );
  }
}

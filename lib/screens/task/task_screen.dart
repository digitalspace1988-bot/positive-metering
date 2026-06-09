import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/task_model.dart';
import 'package:positive_metering/screens/task/add_task_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isAssignedTask = true;

  bool isLoading = true;

  List<TaskModel> taskList = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() => isLoading = true);

    final userSrNo = await AppPref.getUserSrNo();

    List<TaskModel> data = [];

    if (isAssignedTask) {
      data = await ApiService.getMyTaskAssigned(
        assignedToUserSrNo: userSrNo ?? "",
      );
    } else {
      data = await ApiService.getMyTask(assignedByUserSrNo: userSrNo ?? "");
    }

    setState(() {
      taskList = data;
      isLoading = false;
    });
  }

  Future<void> updateStatus(TaskModel task, bool value) async {
    final TextEditingController commentCtrl = TextEditingController();

    final status = value ? "Completed" : "Pending";

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 55.h,
                  width: 55.h,
                  decoration: BoxDecoration(
                    color: AppColor.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.task_alt,
                    color: AppColor.primaryRed,
                    size: 28.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  value ? "Mark Task as Completed?" : "Mark Task as Pending?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textDark,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  "Add comment before updating task status",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                  ),
                ),

                SizedBox(height: 18.h),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.grey),
                  ),
                  child: TextField(
                    controller: commentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter comments",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14.w),
                    ),
                  ),
                ),

                SizedBox(height: 22.h),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                        child: Container(
                          height: 46.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: AppColor.primaryRed),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: AppColor.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        child: Container(
                          height: 46.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColor.primaryRed,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    /// CURRENTLY API RESPONSE DOES NOT RETURN task_srno
    /// SO TEMPORARY EMPTY STRING
    /// ONCE BACKEND SENDS task_srno REPLACE HERE

    final userSrNo = await AppPref.getUserSrNo();

    final success = await ApiService.updateTaskStatus(
      taskSrNo: task.taskSrNo,
      taskComments: commentCtrl.text,
      status: status,
      assignedToUserSrNo: userSrNo ?? "",
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Task Updated Successfully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      loadTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to update task",
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
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      appBar: CommonAppBar(
        scaffoldKey: _scaffoldKey,
        showDrawer: true,
        showAdd: true,
        onAddTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          ).then((value) {
            loadTasks();
          });
        },
      ),

      body: Column(
        children: [
          SizedBox(height: 16.h),

          /// TOGGLE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isAssignedTask = true;
                      });

                      loadTasks();
                    },
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isAssignedTask
                            ? AppColor.primaryRed
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColor.primaryRed),
                      ),
                      child: Text(
                        "Task Assigned To Me",
                        style: TextStyle(
                          color: isAssignedTask
                              ? Colors.white
                              : AppColor.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isAssignedTask = false;
                      });

                      loadTasks();
                    },
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !isAssignedTask
                            ? AppColor.primaryRed
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColor.primaryRed),
                      ),
                      child: Text(
                        "Task Assigned By Me",
                        style: TextStyle(
                          color: !isAssignedTask
                              ? Colors.white
                              : AppColor.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskList.isEmpty
                ? Center(
                    child: Text(
                      isAssignedTask
                          ? "No Assigned Tasks Found"
                          : "No My Tasks Found",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: taskList.length,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemBuilder: (_, index) {
                      final task = taskList[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.taskDetails,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 12.h),

                            Text(
                              "Comments : ${task.taskComments}",
                              style: TextStyle(fontSize: 14.sp),
                            ),

                            SizedBox(height: 12.h),

                            if (isAssignedTask)
                              Text(
                                "Assigned By : ${task.assignedBy}",
                                style: TextStyle(fontSize: 14.sp),
                              ),

                            if (!isAssignedTask)
                              Text(
                                "Assigned To : ${task.assignedTo}",
                                style: TextStyle(fontSize: 14.sp),
                              ),

                            SizedBox(height: 16.h),

                            if (isAssignedTask)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Status : ${task.status}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          task.status.toLowerCase() ==
                                              "completed"
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),

                                  Switch(
                                    value:
                                        task.status.toLowerCase() ==
                                        "completed",
                                    onChanged: (value) {
                                      updateStatus(task, value);
                                    },
                                  ),
                                ],
                              )
                            else
                              Text(
                                "Status : ${task.status}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      task.status.toLowerCase() == "completed"
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/user_model.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isSaving = false;

  List<UserModel> userList = [];

  String? selectedUser;

  final TextEditingController taskCtrl = TextEditingController();
  final TextEditingController commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    userList = await ApiService.getUsers();

    setState(() => isLoading = false);
  }

  Future<void> saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select User")));
      return;
    }

    setState(() => isSaving = true);

    try {
      final userSrNo = await AppPref.getUserSrNo();

      final success = await ApiService.addTask(
        assignedByUserSrNo: userSrNo ?? "",
        assignedToUserSrNo: selectedUser!,
        taskDetails: taskCtrl.text.trim(),
        taskComments: commentCtrl.text.trim(),
      );

      setState(() => isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task Added"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to Add Task"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);

      debugPrint("ADD TASK ERROR : $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColor.grey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedUser,
                          hint: const Text("Select User"),
                          isExpanded: true,
                          items: userList.map((e) {
                            return DropdownMenuItem(
                              value: e.userSrNo,
                              child: Text(e.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUser = value;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    TextFormField(
                      controller: taskCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Task Details",
                      ),
                    ),

                    SizedBox(height: 16.h),

                    TextFormField(
                      controller: commentCtrl,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: "Comments"),
                    ),

                    SizedBox(height: 30.h),

                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryRed,
                        ),
                        onPressed: isSaving ? null : saveTask,
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Add Task",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

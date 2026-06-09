import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';
import 'package:positive_metering/model/category_model.dart';
import 'package:positive_metering/model/common_model.dart';
import 'package:positive_metering/model/industry_model.dart';
import 'package:positive_metering/model/project_status_model.dart';
import 'package:positive_metering/screens/project_opportunity/bidder/add_bidder_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddProjectPlanScreen extends StatefulWidget {
  const AddProjectPlanScreen({super.key});

  @override
  State<AddProjectPlanScreen> createState() => _AddProjectPlanScreenState();
}

class _AddProjectPlanScreenState extends State<AddProjectPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? date;
  DateTime? startDate;
  DateTime? followupDate;
  bool isLoading = true;
  bool isSaving = false;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  final TextEditingController projectNameCtrl = TextEditingController();
  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();
  final TextEditingController projectValueCtrl = TextEditingController();
  final TextEditingController ownerNameCtrl = TextEditingController();
  final TextEditingController ownerMobileCtrl = TextEditingController();
  final TextEditingController ownerEmailCtrl = TextEditingController();
  final TextEditingController projectOwnerCtrl = TextEditingController();
  final TextEditingController clientContactCtrl = TextEditingController();
  final TextEditingController clientEmailCtrl = TextEditingController();

  List<CommonModel> countryList = [];
  List<CommonModel> stateList = [];
  List<CommonModel> districtList = [];
  List<CommonModel> cityList = [];
  List<CommonModel> areaList = [];
  List<CommonModel> regionList = [];
  List<CommonModel> subregionList = [];
  List<IndustryModel> industryList = [];
  List<CategoryModel> categoryList = [];
  List<ProjectStatusModel> projectStatusList = [];

  String? selectedCountry;
  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;
  String? selectedArea;

  String? selectedRegion;
  String? selectedSubregion;

  String? selectedIndustry;
  String? selectedCategory;
  String? selectedProjectStatus;

  String? selectedIndustrySrNo;
  String? selectedCategorySrNo;
  String? selectedProjectStatusSrNo;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    try {
      final user = await AppPref.getUser();

      final userSrNo = user?['usersrno'] ?? "";
      final regionSrNo = user?['region_srno'] ?? "";
      final subregionSrNo = user?['subregion_srno'] ?? "";

      /// REGION
      try {
        regionList = await ApiService.getRegion();

        selectedRegion = regionSrNo;
      } catch (e) {
        debugPrint("REGION API ERROR : $e");
      }

      /// SUBREGION
      try {
        subregionList = await ApiService.getSubregion(
          userSrNo: userSrNo,
          regionSrNo: selectedRegion ?? "",
        );

        selectedSubregion = subregionSrNo;

        industryList = await ApiService.getIndustry(userSrNo: userSrNo);

        categoryList = await ApiService.getCategory(userSrNo: userSrNo);

        projectStatusList = await ApiService.getProjectStatus(
          userSrNo: userSrNo,
        );
      } catch (e) {
        debugPrint("SUBREGION API ERROR : $e");
      }

      /// COUNTRY
      try {
        countryList = await ApiService.getCountry(
          userSrNo: userSrNo,
          regionSrNo: selectedRegion ?? "",
          subregionSrNo: selectedSubregion ?? "",
        );

        if (countryList.isNotEmpty) {
          selectedCountry = countryList.first.id;

          await loadStates(selectedCountry!);
        }
      } catch (e) {
        debugPrint("COUNTRY API ERROR : $e");
      }
    } catch (e) {
      debugPrint("MAIN ERROR : $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadStates(String countrySrNo) async {
    final user = await AppPref.getUser();

    stateList = await ApiService.getState(
      userSrNo: user?['usersrno'] ?? "",
      regionSrNo: selectedRegion ?? "",
      subregionSrNo: selectedSubregion ?? "",
      countrySrNo: countrySrNo,
    );

    setState(() {});
  }

  Future<void> loadDistricts(String stateSrNo) async {
    final user = await AppPref.getUser();

    districtList = await ApiService.getDistrict(
      userSrNo: user?['usersrno'] ?? "",
      stateSrNo: stateSrNo,
    );

    setState(() {});
  }

  Future<void> loadCities(String districtSrNo) async {
    final user = await AppPref.getUser();

    cityList = await ApiService.getCity(
      userSrNo: user?['usersrno'] ?? "",
      districtSrNo: districtSrNo,
    );

    setState(() {});
  }

  Future<void> loadAreas(String citySrNo) async {
    final user = await AppPref.getUser();

    areaList = await ApiService.getArea(
      userSrNo: user?['usersrno'] ?? "",
      citySrNo: citySrNo,
    );

    setState(() {});
  }

  Future<void> loadSubregions(String regionSrNo) async {
    final user = await AppPref.getUser();

    subregionList = await ApiService.getSubregion(
      userSrNo: user?['usersrno'] ?? "",
      regionSrNo: regionSrNo,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,

      /// APP BAR
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

            /// TITLE
            Text(
              "Add Project Plan",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textDark,
              ),
            ),

            SizedBox(height: 20.h),

            /// FORM
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Date"),
                      _dateField(date, (d) => setState(() => date = d)),

                      SizedBox(height: 18.h),
                      _label("Project Title"),
                      _textField(projectNameCtrl, "Enter Project Title"),

                      SizedBox(height: 18.h),
                      _label("Project Value"),
                      _textField(projectValueCtrl, "Enter Project Value"),

                      SizedBox(height: 18.h),
                      _label("Project Owner / Client Name"),
                      _textField(projectOwnerCtrl, "Enter Client Name"),

                      SizedBox(height: 18.h),
                      _label("Client Contact Number"),
                      _textField(clientContactCtrl, "Enter Contact Number"),

                      SizedBox(height: 18.h),
                      _label("Client Email"),
                      _textField(clientEmailCtrl, "Enter Client Email"),

                      SizedBox(height: 18.h),
                      _label("Start Date"),
                      _dateField(
                        startDate,
                        (d) => setState(() => startDate = d),
                      ),
                      SizedBox(height: 18.h),

                      _label("Industry"),

                      Container(
                        height: 46.h,
                        margin: EdgeInsets.only(top: 6.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedIndustrySrNo,
                            hint: const Text("Select Industry"),
                            isExpanded: true,
                            items: industryList.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.industrySrNo,
                                child: Text(
                                  e.industryName.replaceAll("\n", " "),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedIndustrySrNo = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),

                      _label("Project Status"),

                      Container(
                        height: 46.h,
                        margin: EdgeInsets.only(top: 6.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedProjectStatusSrNo,
                            hint: const Text("Select Project Status"),
                            isExpanded: true,
                            items: projectStatusList.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.statusSrNo,
                                child: Text(e.statusName.replaceAll("\n", " ")),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedProjectStatusSrNo = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),

                      _label("Category"),

                      Container(
                        height: 46.h,
                        margin: EdgeInsets.only(top: 6.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColor.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategorySrNo,
                            hint: const Text("Select Category"),
                            isExpanded: true,
                            items: categoryList.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.categorySrNo,
                                child: Text(
                                  e.categoryName.replaceAll("\n", " "),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategorySrNo = value;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 18.h),

                      SizedBox(height: 16.h),

                      _dropdownField(
                        hint: "Select Region",
                        value: selectedRegion,
                        items: regionList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          selectedRegion = value;

                          selectedSubregion = null;
                          selectedCountry = null;
                          selectedState = null;
                          selectedDistrict = null;
                          selectedCity = null;
                          selectedArea = null;

                          subregionList.clear();
                          countryList.clear();
                          stateList.clear();
                          districtList.clear();
                          cityList.clear();
                          areaList.clear();

                          setState(() {});

                          await loadSubregions(value!);
                        },
                      ),

                      SizedBox(height: 16.h),

                      _dropdownField(
                        hint: "Select Subregion",
                        value: selectedSubregion,
                        items: subregionList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          final user = await AppPref.getUser();

                          selectedSubregion = value;

                          selectedCountry = null;
                          selectedState = null;
                          selectedDistrict = null;
                          selectedCity = null;
                          selectedArea = null;

                          countryList.clear();
                          stateList.clear();
                          districtList.clear();
                          cityList.clear();
                          areaList.clear();

                          setState(() {});

                          countryList = await ApiService.getCountry(
                            userSrNo: user?['usersrno'] ?? "",
                            regionSrNo: selectedRegion ?? "",
                            subregionSrNo: selectedSubregion ?? "",
                          );

                          setState(() {});
                        },
                      ),

                      SizedBox(height: 16.h),

                      _dropdownField(
                        hint: "Select Country",
                        value: selectedCountry,
                        items: countryList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          selectedCountry = value;

                          selectedState = null;
                          selectedDistrict = null;
                          selectedCity = null;
                          selectedArea = null;

                          stateList.clear();
                          districtList.clear();
                          cityList.clear();
                          areaList.clear();

                          setState(() {});

                          await loadStates(value!);
                        },
                      ),

                      SizedBox(height: 16.h),

                      _dropdownField(
                        hint: "Select State",
                        value: selectedState,
                        items: stateList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          selectedState = value;

                          selectedDistrict = null;
                          selectedCity = null;
                          selectedArea = null;

                          districtList.clear();
                          cityList.clear();
                          areaList.clear();

                          setState(() {});

                          await loadDistricts(value!);
                        },
                      ),

                      SizedBox(height: 16.h),

                      _dropdownField(
                        hint: "Select District",
                        value: selectedDistrict,
                        items: districtList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          selectedDistrict = value;

                          selectedCity = null;
                          selectedArea = null;

                          cityList.clear();
                          areaList.clear();

                          setState(() {});

                          await loadCities(value!);
                        },
                      ),

                      SizedBox(height: 16.h),

                      _dropdownField(
                        hint: "Select City",
                        value: selectedCity,
                        items: cityList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          selectedCity = value;

                          selectedArea = null;

                          areaList.clear();

                          setState(() {});

                          await loadAreas(value!);
                        },
                      ),

                      SizedBox(height: 16.h),

                      _dropdownField(
                        hint: "Select Area",
                        value: selectedArea,
                        items: areaList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedArea = value;
                          });
                        },
                      ),

                      SizedBox(height: 18.h),

                      _label("Follow-up Date"),

                      _dateField(
                        followupDate,
                        (d) => setState(() => followupDate = d),
                      ),

                      SizedBox(height: 18.h),
                      _label("Comments"),
                      _commentField(),

                      SizedBox(height: 30.h),

                      /// ACTION BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: isSaving
                                  ? null
                                  : () async {
                                      if (selectedRegion == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select Region",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedSubregion == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select Subregion",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedCountry == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select Country",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedState == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select State",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedDistrict == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select District",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedCity == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Please select City"),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedArea == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Please select Area"),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedIndustrySrNo == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select Industry",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedProjectStatusSrNo == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select Project Status",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedCategorySrNo == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select Category",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (!_formKey.currentState!.validate())
                                        return;

                                      try {
                                        setState(() => isSaving = true);

                                        final user = await AppPref.getUser();

                                        final success =
                                            await ApiService.addProject(
                                              userSrNo: user?['usersrno'] ?? "",

                                              projectTitle: projectNameCtrl.text
                                                  .trim(),

                                              projectValue: projectValueCtrl
                                                  .text
                                                  .trim(),

                                              clientName: projectOwnerCtrl.text
                                                  .trim(),

                                              clientContactNumber:
                                                  clientContactCtrl.text.trim(),

                                              clientEmail: clientEmailCtrl.text
                                                  .trim(),

                                              projectDate: date != null
                                                  ? _formatter.format(date!)
                                                  : "",

                                              projectStartDate:
                                                  startDate != null
                                                  ? _formatter.format(
                                                      startDate!,
                                                    )
                                                  : "",

                                              followupDate: followupDate != null
                                                  ? _formatter.format(
                                                      followupDate!,
                                                    )
                                                  : "",

                                              industrySrNo:
                                                  selectedIndustrySrNo ?? "",

                                              statusSrNo:
                                                  selectedProjectStatusSrNo ??
                                                  "",

                                              categorySrNo:
                                                  selectedCategorySrNo ?? "",

                                              regionSrNo: selectedRegion ?? "",

                                              subregionSrNo:
                                                  selectedSubregion ?? "",

                                              countrySrNo:
                                                  selectedCountry ?? "",

                                              stateSrNo: selectedState ?? "",

                                              districtSrNo:
                                                  selectedDistrict ?? "",

                                              citySrNo: selectedCity ?? "",

                                              areaSrNo: selectedArea ?? "",

                                              projectComments: commentsCtrl.text
                                                  .trim(),
                                            );

                                        setState(() => isSaving = false);

                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                "Project Added Successfully",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );

                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                "Failed to Add Project",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setState(() => isSaving = false);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              "Something went wrong",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
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
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
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
                        ],
                      ),

                      SizedBox(height: 20.h),
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

  // --------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateField(DateTime? value, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
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
        if (picked != null) onPicked(picked);
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
            Text(
              value == null ? "Select Date" : _formatter.format(value),
              style: TextStyle(fontSize: 14.sp),
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      height: 46.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget _commentField() {
    return Container(
      height: 80.h,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.grey),
      ),
      child: TextFormField(
        controller: commentsCtrl,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: "Description",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColor.lightGrey,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((e) => e.value == value) ? value : null,
          hint: Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

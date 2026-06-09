import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:positive_metering/api/api_service.dart';

import 'package:positive_metering/model/common_model.dart';
import 'package:positive_metering/model/product_model.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isSaving = false;

  // CONTROLLERS

  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController customerNameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController landlineCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController websiteCtrl = TextEditingController();
  final TextEditingController designationCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController departmentCtrl = TextEditingController();

  List<ProductModel> productList = [];

  final Set<String> selectedProducts = {};

  // DROPDOWN DATA

  List<CommonModel> countryList = [];
  List<CommonModel> stateList = [];
  List<CommonModel> districtList = [];
  List<CommonModel> cityList = [];
  List<CommonModel> areaList = [];
  List<CommonModel> regionList = [];
  List<CommonModel> subregionList = [];

  List<CommonModel> customerTypeList = [];
  List<CommonModel> groupList = [];
  List<CommonModel> sourceList = [];

  // SELECTED VALUES

  String? selectedCountry;
  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;
  String? selectedArea;
  String? selectedCustomerType;
  String? selectedGroup;
  String? selectedSource;
  String? selectedRegion;
  String? selectedSubregion;

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

      /// CUSTOMER TYPE
      try {
        customerTypeList = await ApiService.getCustomerType();
      } catch (e) {
        debugPrint("CUSTOMER TYPE API ERROR : $e");
      }

      /// SOURCE
      try {
        sourceList = await ApiService.getSource(userSrNo: userSrNo);
      } catch (e) {
        debugPrint("SOURCE API ERROR : $e");
      }

      /// PRODUCTS
      try {
        productList = await ApiService.getProducts();
      } catch (e) {
        debugPrint("PRODUCT API ERROR : $e");
      }

      /// GROUP
      try {
        groupList = await ApiService.getGroup();
      } catch (e) {
        debugPrint("GROUP API ERROR : $e");
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

  Future<void> addCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCountry == null ||
        selectedState == null ||
        selectedDistrict == null ||
        selectedCity == null ||
        selectedArea == null ||
        selectedCustomerType == null ||
        selectedSource == null ||
        selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all dropdowns")),
      );
      return;
    }

    setState(() => isSaving = true);

    final user = await AppPref.getUser();

    final success = await ApiService.addCustomer(
      // regionSrNo: user?['region_srno'] ?? "",
      // subregionSrNo: user?['subregion_srno'] ?? "",
      regionSrNo: selectedRegion ?? "",
      subregionSrNo: selectedSubregion ?? "",
      countrySrNo: selectedCountry!,
      stateSrNo: selectedState!,
      districtSrNo: selectedDistrict!,
      citySrNo: selectedCity!,
      areaSrNo: selectedArea!,
      customerTypeSrNo: selectedCustomerType!,
      groupSrNo: selectedGroup!,
      companyName: companyCtrl.text.trim(),
      customerName: customerNameCtrl.text.trim(),
      mobileNo: mobileCtrl.text.trim(),
      landlineNo: landlineCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      website: websiteCtrl.text.trim(),
      designation: designationCtrl.text.trim(),
      department: departmentCtrl.text.trim(),
      sourceSrNo: selectedSource!,
      address: addressCtrl.text.trim(),
      productSrNo: selectedProducts.join(","),
    );

    setState(() => isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer Added Successfully")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to Add Customer")));
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
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Customer",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    _textField(companyCtrl, "Company Name"),

                    SizedBox(height: 16.h),

                    _textField(customerNameCtrl, "Customer Name"),

                    SizedBox(height: 16.h),

                    _textField(
                      mobileCtrl,
                      "Mobile Number",
                      keyboard: TextInputType.phone,
                    ),

                    SizedBox(height: 16.h),

                    _textField(
                      landlineCtrl,
                      "Landline Number",
                      keyboard: TextInputType.phone,
                    ),

                    SizedBox(height: 16.h),

                    _textField(
                      emailCtrl,
                      "Email",
                      keyboard: TextInputType.emailAddress,
                    ),

                    SizedBox(height: 16.h),

                    _textField(websiteCtrl, "Website"),

                    SizedBox(height: 16.h),

                    _textField(designationCtrl, "Designation"),
                    SizedBox(height: 16.h),

                    _textField(departmentCtrl, "Department"),
                    SizedBox(height: 16.h),

                    _dropdownField(
                      hint: "Select Source",
                      value: selectedSource,
                      items: sourceList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSource = value;
                        });
                      },
                    ),

                    SizedBox(height: 16.h),

                    _textField(addressCtrl, "Address", maxLines: 4),

                    SizedBox(height: 16.h),

                    Text(
                      "Product Interest",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    _productGrid(),

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

                    SizedBox(height: 16.h),

                    _dropdownField(
                      hint: "Select Customer Type",
                      value: selectedCustomerType,
                      items: customerTypeList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCustomerType = value;
                        });
                      },
                    ),

                    SizedBox(height: 16.h),

                    _dropdownField(
                      hint: "Select Group",
                      value: selectedGroup,
                      items: groupList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGroup = value;
                        });
                      },
                    ),

                    SizedBox(height: 30.h),

                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: isSaving ? null : addCustomer,
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Add Customer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Required";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColor.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
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

  Widget _productGrid() {
    if (productList.isEmpty) {
      return const Text("No Products Available");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 3,
      ),
      itemBuilder: (context, index) {
        final item = productList[index];

        final isSelected = selectedProducts.contains(item.productSrNo);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedProducts.remove(item.productSrNo);
              } else {
                selectedProducts.add(item.productSrNo);
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.primaryBlue.withOpacity(0.12)
                  : AppColor.lightGrey,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? AppColor.primaryBlue : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              item.productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColor.primaryBlue : AppColor.textDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

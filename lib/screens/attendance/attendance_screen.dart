import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:positive_metering/api/api_service.dart';

import 'package:positive_metering/screens/attendance/attendance_report_screen.dart';
import 'package:positive_metering/shared_pref/app_pref.dart';
import 'package:positive_metering/utils/animation_helper/animated_page_route.dart';
import 'package:positive_metering/utils/app_colors.dart';
import 'package:positive_metering/utils/battery_optimization_helper.dart';
import 'package:positive_metering/utils/widgets/common_app_bar.dart';
import 'package:positive_metering/utils/widgets/common_drawer.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File? _capturedImage;

  String? _usersrno;
  bool _isLoading = true;
  bool _isApiCalling = false;

  bool isDayCompleted = false;
  bool isPunchedIn = false;
  String? punchInTime;
  String? punchOutTime;

  double? _lat;
  double? _lng;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadUser();
  }

  Future<void> _loadUser() async {
    final srno = await AppPref.getUserSrNo();
    if (mounted) {
      setState(() {
        _usersrno = srno;
        _isLoading = false;
      });
      if (_usersrno != null) {
        await _fetchPunchStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found. Please login again.'),
          ),
        );
      }
    }
  }

  Future<void> _fetchPunchStatus() async {
    if (_usersrno == null) return;

    final res = await ApiService.getAttendanceStatus(usersrno: _usersrno!);

    if (!mounted) return;

    if (res['status'] == 0) {
      final status = (res['punch_status'] ?? '').toString().toLowerCase();
      final inTime = (res['punch_in_time'] ?? '').toString();
      final outTime = (res['punch_out_time'] ?? '').toString();

      setState(() {
        punchInTime = inTime.isNotEmpty ? inTime : null;
        punchOutTime = outTime.isNotEmpty ? outTime : null;

        if (status.contains('punch in')) {
          // Server returns "Punch In" → user has NOT punched in yet
          isPunchedIn = false;
          isDayCompleted = false;
        } else if (status.contains('punch out')) {
          // Server returns "Punch Out" → user HAS punched in
          isPunchedIn = true;
          isDayCompleted = false;
        } else if (status.contains('attendance marked')) {
          isPunchedIn = false;
          isDayCompleted = true;
        } else {
          isPunchedIn = false;
          isDayCompleted = false;
        }
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  String _todayFormatted() {
    // API expects bill_date; adjust format if your API needs something different
    return DateFormat('dd-MMM-yyyy').format(DateTime.now());
  }

  String _formattedTimeNow() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  Future<void> _handlePunchIn() async {
    if (_isApiCalling || isPunchedIn || _usersrno == null) return;

    final picker = ImagePicker();

    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 60, // compression (same as timus)
    );

    if (photo == null) return;

    ///  Preview + Confirm Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Punch In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(photo.path), height: 250, fit: BoxFit.cover),
              const SizedBox(height: 12),
              const Text('Do you want to confirm this punch in?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Retake'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryRed,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    /// Retake
    if (confirm == false) {
      return _handlePunchIn();
    }

    _capturedImage = File(photo.path);

    await _getLocation();

    await _submitPunch('IN', imageFile: _capturedImage);
  }

  Future<void> _handlePunchOut() async {
    if (_isApiCalling || !isPunchedIn || _usersrno == null) return;
    await _getLocation();
    await _submitPunch('OUT');
  }

  Future<void> _submitPunch(String inOut, {File? imageFile}) async {
    if (_usersrno == null) return;

    setState(() => _isApiCalling = true);
    _rotationController.repeat();

    try {
      final res = await ApiService.markAttendance(
        usersrno: _usersrno!,
        billDate: _todayFormatted(),
        inOut: inOut,
        lat: (_lat?.toString() ?? '0'),
        lng: (_lng?.toString() ?? '0'),
      );

      if (!mounted) return;

      final isSuccess =
          res['status'] == 0 ||
          (res['message']?.toString().toLowerCase().contains('success') ??
              false);

      if (isSuccess) {
        final currentTime = _formattedTimeNow();

        setState(() {
          if (inOut == 'IN') {
            isPunchedIn = true;
            isDayCompleted = false;
            punchInTime = currentTime;
            punchOutTime = null;
          } else {
            isPunchedIn = false;
            punchOutTime = currentTime;
          }
        });

        // Background service control
        if (inOut == 'IN') {
          final service = FlutterBackgroundService();
          await service.startService();
          await Future.delayed(const Duration(seconds: 1));
          service.invoke('startTracking');

          _checkBatteryOptimization();
        } else {
          FlutterBackgroundService().invoke('stopTracking');
        }

        await _fetchPunchStatus(); // sync final state
      } else {
        final msg = res['message'] ?? 'Failed to mark attendance';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('Submit punch error: $e');
    } finally {
      if (mounted) {
        _rotationController.stop();
        setState(() => _isApiCalling = false);
      }
    }
  }

  Future<void> _checkBatteryOptimization() async {
    final isIgnored = await BatteryOptimizationHelper.isIgnored();
    if (isIgnored) return;

    final brand = await BatteryOptimizationHelper.getBrand();

    String extra = '';
    if (brand.contains('vivo')) {
      extra = '\n\nVivo: Battery → App battery management → No restrictions';
    } else if (brand.contains('realme')) {
      extra =
          '\n\nRealme: Battery → App battery usage → Allow background activity';
    } else if (brand.contains('xiaomi') || brand.contains('redmi')) {
      extra = '\n\nRedmi: Battery saver → No restrictions + Enable Autostart';
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Allow Background Tracking'),
        content: Text(
          'To track your location continuously during working hours, '
          'please allow Battery Usage as "No restrictions".'
          '$extra',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await BatteryOptimizationHelper.request();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      key: _scaffoldKey,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      appBar: CommonAppBar(scaffoldKey: _scaffoldKey, showDrawer: true),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),

            Text(
              "Mark Attendance",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 80.h),

            // ── Punch circle (animated switch) ──────────────────────────────
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_usersrno == null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: const Text(
                  'Error: User data unavailable. Please login again.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: isDayCompleted
                    ? _DayCompletedBadge(key: const ValueKey('done'))
                    : isPunchedIn
                    ? GestureDetector(
                        key: const ValueKey('punchOut'),
                        onTap: _isApiCalling ? null : _handlePunchOut,
                        child: _PunchCircle(
                          label: _isApiCalling
                              ? 'PUNCHING\nOUT...'
                              : 'PUNCH\nOUT',
                          iconColor: Colors.green,
                          borderColor: AppColor.primaryBlue,
                          rotation: _rotationController,
                        ),
                      )
                    : GestureDetector(
                        key: const ValueKey('punchIn'),
                        onTap: _isApiCalling ? null : _handlePunchIn,
                        child: _PunchCircle(
                          label: _isApiCalling
                              ? 'PUNCHING\nIN...'
                              : 'PUNCH\nIN',
                          iconColor: AppColor.primaryRed,
                          borderColor: AppColor.primaryBlue,
                          rotation: _isApiCalling ? _rotationController : null,
                        ),
                      ),
              ),

            SizedBox(height: 80.h),

            // ── Time info row ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _timeInfo(punchInTime ?? '--:--', 'Punch In'),
                  _timeInfo(punchOutTime ?? '--:--', 'Punch Out'),
                ],
              ),
            ),

            const Spacer(),

            // ── View report button ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 15, 16.w, 50.h),
              child: SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      AnimatedPageRoute(page: AttendanceReportScreen()),
                    );
                  },
                  child: const Text(
                    "View Attendance report",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeInfo(String time, String label) {
    return Column(
      children: [
        Icon(Icons.access_time, color: AppColor.primaryRed, size: 22.sp),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColor.grey),
        ),
      ],
    );
  }
}

// ── DAY COMPLETED BADGE ──────────────────────────────────────────────────────

class _DayCompletedBadge extends StatelessWidget {
  const _DayCompletedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 48.sp),
          SizedBox(height: 10.h),
          Text(
            'Attendance Marked for the Day',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PUNCH CIRCLE ─────────────────────────────────────────────────────────────

class _PunchCircle extends StatelessWidget {
  final String label;
  final Color iconColor;
  final Color borderColor;
  final AnimationController? rotation;

  const _PunchCircle({
    super.key,
    required this.label,
    required this.iconColor,
    required this.borderColor,
    this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Spinning outer ring (visible only when animating)
        AnimatedBuilder(
          animation: rotation ?? kAlwaysCompleteAnimation,
          builder: (context, child) {
            final isAnimating = rotation != null && (rotation!.isAnimating);
            return Transform.rotate(
              angle: (rotation?.value ?? 0) * 2 * math.pi,
              child: Opacity(
                opacity: isAnimating ? 1.0 : 0.0,
                child: Container(
                  width: 160.w,
                  height: 160.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        iconColor.withOpacity(0.9),
                        iconColor.withOpacity(0.9),
                        iconColor.withOpacity(0.9),
                        iconColor.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.25, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Static outer ring border
        Container(
          width: 160.w,
          height: 160.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 6.w),
          ),
        ),
        // Inner circle with icon + label
        Container(
          width: 130.w,
          height: 130.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade100,
            border: Border.all(color: borderColor, width: 4.w),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, color: iconColor, size: 36.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:positive_metering/api/api_service.dart';

import 'package:positive_metering/shared_pref/app_pref.dart';

DateTime? lastRecordedTime;
const Duration updateInterval = Duration(minutes: 15);

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  WidgetsFlutterBinding.ensureInitialized();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
  );
}

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 3));

    if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

StreamSubscription<Position>? positionSub;
bool _locationStreamPaused = false;

void _startLocationStream(ServiceInstance service) {
  positionSub?.cancel();

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );

  positionSub = Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen(
        (position) async {
          _locationStreamPaused = false;

          if (service is AndroidServiceInstance) {
            if (await service.isForegroundService()) {
              service.setForegroundNotificationInfo(
                title: "Positive Metering – Application Active",
                content:
                    "Location tracking is running. Please keep your GPS on.",
              );
            }
          }

          final now = DateTime.now();

          if (lastRecordedTime == null ||
              now.difference(lastRecordedTime!) >= updateInterval) {
            lastRecordedTime = now;

            bool isOnline = await hasNetwork();

            if (!isOnline) {
              if (service is AndroidServiceInstance) {
                service.setForegroundNotificationInfo(
                  title: "Positive Metering – Internet OFF",
                  content:
                      "Please turn ON mobile data or WiFi to send location.",
                );
              }
              return;
            }

            // API call only if net is available
            String? usersrno = await AppPref.getUserSrNo();

            if (usersrno != null) {
              await ApiService.sendLiveLocation(
                usersrno: usersrno,
                lat: position.latitude.toString(),
                lng: position.longitude.toString(),
              );
            }
          }

          service.invoke('update', {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': DateTime.now().toIso8601String(),
          });
        },
        onError: (err) {
          _locationStreamPaused = true;
        },
      );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Periodic checker to auto-restart dead stream
  Timer.periodic(const Duration(seconds: 20), (timer) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Positive Metering – GPS OFF",
          content: "Please turn ON location to continue tracking.",
        );
      }
      return;
    }

    if (_locationStreamPaused) {
      _startLocationStream(service);
    }
  });

  // Start tracking command from Flutter
  service.on('startTracking').listen((event) async {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }
    _startLocationStream(service);
  });

  // Stop tracking
  service.on('stopTracking').listen((event) async {
    positionSub?.cancel();
    service.stopSelf();
  });
}

import 'package:EMallApp/utils/HelperFunction.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppScreen.dart';

class ScreenLocationPermission extends StatefulWidget {
  @override
  _ScreenLocationPermissionState createState() =>
      _ScreenLocationPermissionState();
}

class _ScreenLocationPermissionState extends State<ScreenLocationPermission> {
  String pincode;
  bool isLoading = true, isDisposed = false;
  showDeniedLocationDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Denied location Permission"),
          content: const Text(
              'You had permanently denied location permission,Sorry'),
        );
      },
    ).then((value) {
      showDeniedLocationDialog();
    });
  }

  Future<Position> getcurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      showDeniedLocationDialog();
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        showDeniedLocationDialog();
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  checkIsGpsOn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await HelperFunction.isGps().then((val) {
      if (val == true) {
        getcurrentLocation().then((value) async {
          final coordinates = new Coordinates(value.latitude, value.longitude);

          await Geocoder.local
              .findAddressesFromCoordinates(coordinates)
              .then((value) {
            print('inside assign pincode');
            var first = value.first;
            pincode = first.postalCode;
            preferences.setString("pincode", pincode);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AppScreen(),
              ),
            );
          });
        });
      } else {
        HelperFunction.gpsAlert(context).then((val) {
          Future.delayed(const Duration(seconds: 2), () {
            checkIsGpsOn();
          });
        });
      }
    });
  }

  @override
  void initState() {
    print('assss');
    checkIsGpsOn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
            ),
            Text('We are fetching your location...')
          ],
        ),
      ),
    ));
  }
}

import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/services/PushNotificationsManager.dart';
import 'package:EMallApp/utils/HelperFunction.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/AppScreen.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppTheme.dart';
import 'AppThemeNotifier.dart';

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    String langCode = await AllLanguage.getLanguage();
    await Translator.load(langCode);

    runApp(ChangeNotifierProvider<AppThemeNotifier>(
      create: (context) => AppThemeNotifier(),
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: MyHomePage());
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ThemeData themeData;
  String pincode;
  bool isLoading = true;

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
            setState(() {
              isLoading = false;
            });
            initFCM();
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
    super.initState();
    checkIsGpsOn();
  }

  initFCM() async {
    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager();
    await pushNotificationsManager.init(context: context);
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    themeData = Theme.of(context);
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return FutureBuilder<bool>(
        future: AuthController.isLoginUser(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return AppScreen();
            } else {
              return LoginScreen();
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

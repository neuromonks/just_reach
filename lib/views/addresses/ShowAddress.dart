import 'dart:collection';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';

class ShowAddressScreen extends StatefulWidget {
  final UserAddress userAddress;

  const ShowAddressScreen({Key key, this.userAddress}) : super(key: key);

  @override
  _ShowAddressScreenState createState() => _ShowAddressScreenState();
}

class _ShowAddressScreenState extends State<ShowAddressScreen> {
  //UI variables
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Google Maps
  bool loaded = false;
  final Set<Marker> _markers = HashSet();
  LatLng currentPosition;

  //Other
  bool isInProgress = false;

  UserAddress userAddress;

  @override
  void initState() {
    super.initState();
    userAddress = widget.userAddress;
    WidgetsBinding.instance.addPostFrameCallback((_) => {_changeLoaded()});
  }

  _changeLoaded() {
    setState(() {
      loaded = true;
    });
  }

  _initUI() {
    Marker marker = Marker(
      markerId: MarkerId('1'),
      position: LatLng(userAddress.latitude, userAddress.longitude),
    );
    currentPosition = LatLng(userAddress.latitude, userAddress.longitude);
    _markers.add(marker);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        _initUI();
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                key: _scaffoldKey,
                body: Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: loaded
                            ? Stack(
                              children: [
                                GoogleMap(
                                    markers: _markers,
                                    initialCameraPosition: CameraPosition(
                                      target: currentPosition,
                                      zoom: 11.0,
                                    ),
                                  ),
                                Positioned(
                                  top: MySize.size40,
                                  left: MySize.size20,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: customAppTheme.bgLayer1.withAlpha(100),
                                        borderRadius: BorderRadius.all(Radius.circular(MySize.size4)),
                                        border: Border.all(color: customAppTheme.bgLayer1.withAlpha(160))
                                      ),
                                      padding: Spacing.all(6),
                                      child: Icon(
                                        MdiIcons.chevronLeft,
                                        color:
                                        themeData.colorScheme.onBackground,size: MySize.size20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Container(),
                      ),
                    ],
                  ),
                )));
      },
    );
  }

  void showMessage({String message = "Something wrong", Duration duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}

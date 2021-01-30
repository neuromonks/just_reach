
import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/controllers/AddressController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:EMallApp/views/addresses/AddAddress.dart';
import 'package:EMallApp/views/addresses/ShowAddress.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class AllAddressScreen extends StatefulWidget {
  @override
  _AllAddressScreenState createState() => _AllAddressScreenState();
}

class _AllAddressScreenState extends State<AllAddressScreen> {

  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<UserAddress> userAddress;


  @override
  void initState() {
    super.initState();
    _loadAllAddresses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadAllAddresses() async {

    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<UserAddress>> myResponse = await AddressController.getMyAddresses();
    if(myResponse.success) {
      userAddress = myResponse.data;
    }else{
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if(mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    _loadAllAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                appBar: AppBar(
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      MdiIcons.chevronLeft,
                      size: MySize.size24,
                      color: themeData.colorScheme.onBackground,
                    ),
                  ),
                  title: Text(
                    Translator.translate("address"),
                    style: AppTheme.getTextStyle(themeData.textTheme.headline6,
                        fontWeight: 600),
                  ),
                ),
                body: RefreshIndicator(
                  onRefresh: _refresh,
                  backgroundColor: customAppTheme.bgLayer1,
                  color: themeData.colorScheme.primary,
                  key: _refreshIndicatorKey,
                  child: ListView(
                    padding: Spacing.zero,
                    children: [
                      Container(
                        height: MySize.size3,
                        child: isInProgress
                            ? LinearProgressIndicator(
                                minHeight: MySize.size3,
                              )
                            : Container(
                                height: MySize.size3,
                              ),
                      ),
                      _buildBody(),
                      Container(
                        margin: Spacing.top(16),
                        child: Center(
                          child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(MySize.size4)),
                              color: themeData.colorScheme.primary,
                              splashColor: Colors.white.withAlpha(150),
                              highlightColor: themeData.colorScheme.primary,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddAddressScreen()));

                              },
                              padding: Spacing.horizontal(24),
                              child: Text(Translator.translate("add_new_address").toUpperCase(),
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.caption,
                                      fontSize: 12,
                                      fontWeight: 600,
                                      letterSpacing: 0.5,
                                      color:
                                          themeData.colorScheme.onPrimary))),
                        ),
                      )
                    ],
                  ),
                )));
      },
    );
  }

  _buildBody(){
    if(userAddress!=null){
      return _showAddresses(userAddress);
    }else if(isInProgress){
      return LoadingScreens.getAddressLoadingScreen(context, themeData, customAppTheme);
    }else{
      return Center(child: Text(Translator.translate("there_is_no_saved_address")),);
    }
  }


  Widget _showAddresses(List<UserAddress> addresses) {
    List<Widget> listWidgets = [];

    for (UserAddress address in addresses) {
      listWidgets.add(InkWell(
        onTap: () async {
          bool refresh = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ShowAddressScreen(userAddress: address,)));
          if(refresh!=null){
            if(refresh)
              _refresh();
          }

        },
        child: Container(
            margin: Spacing.bottom(16),
            child: _singleAddress(
              pincode: address.pincode,
              city: address.city,
              address2: address.address2,
              address: address.address,
            )),
      ));
    }

    return Container(
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: listWidgets,
      ),
    );
  }

  Widget _singleAddress(
      {String address, String address2, String city, int pincode}) {
    return Container(
      decoration: BoxDecoration(
        color: themeData.cardTheme.color,
        border: Border.all(color: customAppTheme.bgLayer4,width: 1),
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),

      ),
      padding: Spacing.all(16),
      child: Row(
        children: <Widget>[
          Container(
            child: Icon(
              MdiIcons.mapMarkerOutline,
              size: MySize.size28,
              color: themeData.colorScheme.onBackground,
            ),
          ),
          Expanded(
            child: Container(
              margin: Spacing.left(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(address,
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle2,
                          fontWeight: 500,
                          letterSpacing: 0)),
                  address2 == null
                      ? Container()
                      : Container(
                        margin: Spacing.top(4),
                        child: Text(address2,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.subtitle2,
                                fontWeight: 500,
                                letterSpacing: 0)),
                      ),
                  Container(
                    margin: Spacing.top(8),
                    child: Row(
                      children: <Widget>[
                        Text(city,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2,
                                fontWeight: 500,
                                letterSpacing: 0)),
                        Container(
                          margin: Spacing.left(4),
                          child: Text(" - " +pincode.toString(),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  fontWeight: 500,
                                  letterSpacing: 0)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
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

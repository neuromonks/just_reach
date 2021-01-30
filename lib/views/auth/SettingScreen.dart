import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/Account.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/addresses/AllAddressScreen.dart';
import 'package:EMallApp/views/auth/EditProfileScreen.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../OrderScreen.dart';
import '../SelectLanguageDialog.dart';
import '../SelectThemeDialog.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //User
  Account account;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    Account cacheAccount = await AuthController.getAccount();
    setState(() {
      account = cacheAccount;
    });
  }

  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: Scaffold(
                backgroundColor: customAppTheme.bgLayer1,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(Translator.translate("setting"),
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.headline6,
                          fontWeight: 600)),
                ),
                body: buildBody()));
      },
    );
  }

  buildBody() {
    if (account != null) {
      return ListView(
        children: <Widget>[
          Container(
            margin: Spacing.fromLTRB(24, 0, 24, 0),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => EditProfileScreen(),
                  ),
                );
                _initData();
              },
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(MySize.getScaledSizeWidth(24))),
                    child: Image.network(
                      account.getAvatarUrl(),
                      height: MySize.getScaledSizeWidth(48),
                      width: MySize.getScaledSizeWidth(48),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: Spacing.left(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(account.name,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.subtitle1,
                                fontWeight: 700,
                                letterSpacing: 0)),
                        Text(account.email,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                fontWeight: 600,
                                letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: Icon(
                          MdiIcons.chevronRight,
                          color: themeData.colorScheme.onBackground,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(24, 40, 24, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      color: themeData.cardTheme.color,
                      border: Border.all(
                          width: 1.2, color: customAppTheme.bgLayer4),
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllAddressScreen()));
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(
                            MdiIcons.mapMarkerOutline,
                            color: themeData.colorScheme.onBackground,
                          ),
                          Container(
                              margin: Spacing.top(8),
                              child: Text(
                                Translator.translate("address"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 600),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size16,
                ),
                Expanded(
                  child: Container(
                    padding: Spacing.all(16),
                    decoration: BoxDecoration(
                      color: themeData.cardTheme.color,
                      border: Border.all(
                          width: 1.2, color: customAppTheme.bgLayer4),
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    OrderScreen()));
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(
                            MdiIcons.contentPaste,
                            color: themeData.colorScheme.onBackground,
                          ),
                          Container(
                              margin: Spacing.top(8),
                              child: Text(
                                Translator.translate("orders"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 600),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size16,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              SelectThemeDialog());
                    },
                    child: Container(
                      padding: Spacing.all(16),
                      decoration: BoxDecoration(
                        color: themeData.cardTheme.color,
                        border: Border.all(
                            width: 1.2, color: customAppTheme.bgLayer4),
                        borderRadius:
                            BorderRadius.all(Radius.circular(MySize.size8)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            MdiIcons.eyeOutline,
                            color: themeData.colorScheme.onBackground,
                          ),
                          Container(
                              margin: Spacing.top(8),
                              child: Text(
                                Translator.translate("theme"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 700),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 8, 16, 0),
            child: ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        SelectLanguageDialog());
              },
              title: Text(
                Translator.translate("select_language"),
                style: AppTheme.getTextStyle(
                    themeData.textTheme.subtitle2,
                    fontWeight: 600),
              ),
              trailing: Icon(Icons.chevron_right,
                  color: themeData.colorScheme.onBackground),
            ),
          ),
          Container(
            margin: Spacing.top(16),
            child: Center(
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () async {
                  await AuthController.logoutUser();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen(),
                    ),
                  );
                },
                color: themeData.colorScheme.primary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.logoutVariant,
                        size: MySize.size20,
                        color: themeData.colorScheme.onPrimary),
                    Container(
                      margin: Spacing.left(16),
                      child: Text(Translator.translate("logout").toUpperCase(),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              fontWeight: 600,
                              color: themeData.colorScheme.onPrimary,
                              letterSpacing: 0.3)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }

}

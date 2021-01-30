import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/controllers/CategoryController.dart';
import 'package:EMallApp/controllers/ShopController.dart';
import 'package:EMallApp/models/Category.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/ColorUtils.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/CategoryProductScreen.dart';
import 'package:EMallApp/views/ShopScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<Shop> shops;
  List<Category> categories;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadHomeData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Shop>> myResponse = await ShopController.getAllShop();
    if (myResponse.success) {
      shops = myResponse.data;
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    MyResponse<List<Category>> myResponseCategory =
        await CategoryController.getAllCategory();
    if (myResponseCategory.success) {
      categories = myResponseCategory.data;
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponseCategory.responseCode);
      showMessage(message: myResponseCategory.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    _loadHomeData();
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
            home: SafeArea(
              child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: customAppTheme.bgLayer1,
                  body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
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
                        Expanded(
                          child: _buildBody(),
                        )
                      ],
                    ),
                  )),
            ));
      },
    );
  }

  _buildBody() {
    if (shops != null && categories != null) {
      return Container(
          child: ListView(
        children: [
          _categoriesWidget(categories),
          shops.length == 0
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Text('No shops found'),
                ))
              : _shopsWidget(shops),
        ],
      ));
    } else if (isInProgress) {
      return Container();
    } else {
      return Container();
    }
  }

  showMessage({String message = "Something wrong", Duration duration}) {
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

  _shopsWidget(List<Shop> shops) {
    List<Widget> listWidgets = [];

    for (Shop shop in shops) {
      listWidgets.add(InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShopScreen(
                        shopId: shop.id,
                      )));
        },
        child: Container(
          margin: Spacing.bottom(24),
          child: _singleShop(shop),
        ),
      ));
    }

    return Container(
      margin: Spacing.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: listWidgets,
      ),
    );
  }

  _singleShop(Shop shop) {
    return Container(
      decoration: BoxDecoration(
        color: customAppTheme.bgLayer2,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: themeData.cardTheme.shadowColor.withAlpha(32),
            blurRadius: 6,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(MySize.size16),
                  topRight: Radius.circular(MySize.size16)),
              child: Image.network(
                shop.imageUrl,
                width: MySize.safeWidth,
                fit: BoxFit.cover,
              )),
          Container(
            padding: Spacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Text(shop.name,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle1,
                              fontWeight: 600)),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Generator.buildRatingStar(
                              rating: shop.rating,
                              activeColor: ColorUtils.getColorFromRating(
                                  shop.rating.ceil(),
                                  customAppTheme,
                                  themeData)),
                          Text(
                            "(" + shop.totalRating.toString() + ")",
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin: Spacing.top(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  MdiIcons.mapMarkerOutline,
                                  color: themeData.colorScheme.onBackground,
                                  size: MySize.size14,
                                ),
                                Expanded(
                                  child: Container(
                                      margin: Spacing.left(8),
                                      child: Text(
                                        shop.address,
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.caption,
                                            fontWeight: 500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                ),
                              ],
                            ),
                            Container(
                              margin: Spacing.top(4),
                              child: Row(
                                children: <Widget>[
                                  Icon(MdiIcons.phoneOutline,
                                      color: themeData.colorScheme.onBackground,
                                      size: 14),
                                  Container(
                                    margin: Spacing.left(8),
                                    child: Text(
                                      shop.mobile,
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.caption,
                                          color: themeData
                                              .colorScheme.onBackground),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      FlatButton(
                          padding: Spacing.horizontal(12),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(MySize.size4)),
                          color: shop.isOpen
                              ? themeData.colorScheme.primary.withAlpha(28)
                              : customAppTheme.colorError.withAlpha(28),
                          splashColor: shop.isOpen
                              ? themeData.colorScheme.primary.withAlpha(100)
                              : customAppTheme.colorError.withAlpha(100),
                          highlightColor: shop.isOpen
                              ? themeData.colorScheme.primary.withAlpha(28)
                              : customAppTheme.colorError.withAlpha(28),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShopScreen(
                                          shopId: shop.id,
                                        )));
                          },
                          child: Text(
                            shop.isOpen
                                ? Translator.translate("open").toUpperCase()
                                : Translator.translate("close").toUpperCase(),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.caption,
                                fontWeight: 600,
                                color: shop.isOpen
                                    ? themeData.colorScheme.primary
                                    : customAppTheme.colorError),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _categoriesWidget(List<Category> categories) {
    List<Widget> list = [];
    for (Category category in categories) {
      list.add(InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryProductScreen(
                          category: category,
                        )));
          },
          child: _singleCategory(category)));
      list.add(SizedBox(width: MySize.size24));
    }
    return Container(
      margin: Spacing.fromLTRB(24, 16, 0, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: list,
        ),
      ),
    );
  }

  _singleCategory(Category category) {
    return Container(
      child: Column(
        children: <Widget>[
          ClipOval(
            child: Container(
              height: MySize.size60,
              width: MySize.size60,
              color: themeData.colorScheme.primary.withAlpha(20),
              child: Center(
                child: Image.network(
                  category.imageUrl,
                  color: themeData.colorScheme.primary,
                  width: MySize.getScaledSizeWidth(28),
                  height: MySize.getScaledSizeWidth(28),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: Spacing.top(8),
            child: Text(
              category.title,
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  fontWeight: 600, letterSpacing: 0),
            ),
          )
        ],
      ),
    );
  }
}

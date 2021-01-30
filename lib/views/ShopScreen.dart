import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/ShopController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/UrlUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'LoadingScreens.dart';
import 'ProductScreen.dart';

class ShopScreen extends StatefulWidget {
  final int shopId;

  const ShopScreen({Key key, this.shopId}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Other variables
  Shop shop;
  bool isInProgress = false;

  @override
  void initState() {
    super.initState();
    _getShopData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getShopData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Shop> myResponse =
        await ShopController.getSingleShop(widget.shopId);
    if (myResponse.success) {
      shop = myResponse.data;
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget child) {
      themeData = AppTheme.getThemeFromThemeMode(value.themeMode());
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
              key: _scaffoldKey,

              appBar: AppBar(
                backgroundColor: customAppTheme.bgLayer1,
                elevation: 0,
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(MdiIcons.chevronLeft),
                ),
                centerTitle: true,
                title: Text(
                    shop != null ? shop.name : Translator.translate("loading"),
                    style: AppTheme.getTextStyle(
                        themeData.appBarTheme.textTheme.headline6,
                        fontWeight: 600)),
              ),
              backgroundColor: customAppTheme.bgLayer1,
              body: Container(
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
                    _buildBody()
                  ],
                ),
              )));
    });
  }

  _buildBody() {
    if (shop != null) {
      return _buildShop();
    } else {
      return Container();
    }
  }

  _buildShop() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Center(
              child: Image.network(
                shop.imageUrl,
                width: MySize.safeWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: Spacing.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: shop.availableForDelivery
                                    ? themeData.colorScheme.primary
                                        .withAlpha(150)
                                    : customAppTheme.colorError.withAlpha(150),
                                width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(MySize.size4)),
                            color: shop.availableForDelivery
                                ? themeData.colorScheme.primary.withAlpha(40)
                                : customAppTheme.colorError.withAlpha(40)),
                        child: Column(
                          children: [
                            Icon(
                              shop.availableForDelivery
                                  ? MdiIcons.check
                                  : MdiIcons.close,
                              color: shop.availableForDelivery
                                  ? themeData.colorScheme.primary
                                  : customAppTheme.colorError,
                            ),
                            Text(
                              Translator.translate("delivery"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: shop.availableForDelivery
                                      ? themeData.colorScheme.primary
                                      : customAppTheme.colorError),
                            )
                          ],
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
                            border: Border.all(
                                color: themeData.colorScheme.primary
                                    .withAlpha(150),
                                width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(MySize.size4)),
                            color: themeData.colorScheme.primary.withAlpha(40)),
                        child: Column(
                          children: [
                            Text(
                              CurrencyApi.getSign(afterSpace: true) +
                                  CurrencyApi.doubleToString(shop.deliveryFee),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText1,
                                  fontWeight: 600,
                                  color: themeData.colorScheme.primary),
                            ),
                            Text(
                              Translator.translate("charges"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.primary),
                            )
                          ],
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
                            border: Border.all(
                                color: shop.isOpen
                                    ? themeData.colorScheme.primary
                                        .withAlpha(150)
                                    : customAppTheme.colorError.withAlpha(150),
                                width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(MySize.size4)),
                            color: shop.isOpen
                                ? themeData.colorScheme.primary.withAlpha(40)
                                : customAppTheme.colorError.withAlpha(40)),
                        child: Column(
                          children: [
                            Icon(
                              shop.isOpen ? MdiIcons.check : MdiIcons.close,
                              color: shop.isOpen
                                  ? themeData.colorScheme.primary
                                  : customAppTheme.colorError,
                            ),
                            Text(
                              shop.isOpen
                                  ? Translator.translate("open")
                                  : Translator.translate("close"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: shop.isOpen
                                      ? themeData.colorScheme.primary
                                      : customAppTheme.colorError),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      UrlUtils.callFromNumber(shop.mobile);
                    },
                    padding: Spacing.fromLTRB(0, 12, 0, 12),
                    color: themeData.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.size4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.phoneOutline,
                            size: MySize.size18,
                            color: themeData.colorScheme.onPrimary),
                        SizedBox(
                          width: MySize.size8,
                        ),
                        Text(
                          Translator.translate("call_to_shop"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MySize.size16,
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      UrlUtils.openMap(shop.latitude, shop.longitude);
                    },
                    padding: Spacing.fromLTRB(0, 12, 0, 12),
                    color: themeData.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.size4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.mapMarkerOutline,
                            size: MySize.size18,
                            color: themeData.colorScheme.onPrimary),
                        SizedBox(
                          width: MySize.size8,
                        ),
                        Text(
                          Translator.translate("go_to_shop"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            padding: Spacing.all(8),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer1,
                borderRadius: BorderRadius.all(Radius.circular(MySize.size4)),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
            child: Html(
              shrinkWrap: true,
              data: shop.description,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translator.translate("products"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
                Container(
                    margin: Spacing.top(16),
                    child: shop.products.length != 0
                        ? _showProducts(shop.products)
                        : Container(
                            child: Text("This shop doesn\'t have any product."),
                          ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showProducts(List<Product> products) {
    List<Widget> listWidgets = [];

    for (int i = 0; i < products.length; i++) {
      listWidgets.add(InkWell(
        onTap: () async {
          Product newProduct = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductScreen(
                        productId: products[i].id,
                      )));

          if (newProduct != null) {
            setState(() {
              products[i] = newProduct;
            });
          }
        },
        child: Container(
          margin: Spacing.bottom(16),
          child: _singleProduct(products[i]),
        ),
      ));
    }

    return Container(
      child: Column(
        children: listWidgets,
      ),
    );
  }

  _singleProduct(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: customAppTheme.bgLayer1,
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
        border: Border.all(color: customAppTheme.bgLayer4),
        boxShadow: [
          BoxShadow(
            color: customAppTheme.shadowColor,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(MySize.size16),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
            child: product.productImages.length != 0
                ? Image.network(
              product.productImages[0].url,
              loadingBuilder: (BuildContext ctx, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return LoadingScreens.getSimpleImageScreen(
                      context, themeData, customAppTheme,
                      width: MySize.size90, height: MySize.size90);
                }
              },
              height: MySize.size90,
              width: MySize.size90,
              fit: BoxFit.cover,
            )
                : Image.asset(
              Product.getPlaceholderImage(),
              height: MySize.size90,
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Container(
              height: MySize.size90,
              margin: EdgeInsets.only(left: MySize.size16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle2,
                              fontWeight: 600,
                              letterSpacing: 0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        product.isFavorite
                            ? MdiIcons.heart
                            : MdiIcons.heartOutline,
                        color: product.isFavorite
                            ? themeData.colorScheme.primary
                            : themeData.colorScheme.onBackground.withAlpha(100),
                        size: 22,
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Generator.buildRatingStar(
                          rating: product.rating,
                          size: MySize.size16,
                          inactiveColor: themeData.colorScheme.onBackground),
                      Container(
                        margin: EdgeInsets.only(left: MySize.size4),
                        child: Text("(" + product.totalRating.toString() + ")",
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                fontWeight: 600)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Product.getTextFromQuantity(
                            product.quantity,
                            AppTheme.getTextStyle(themeData.textTheme.caption,
                                letterSpacing: 0),
                            themeData,
                            customAppTheme),
                      ),
                      Text(
                        CurrencyApi.getSign(afterSpace: true) +
                            CurrencyApi.doubleToString(Product.getOfferedPrice(
                                product.price, product.offer)),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            fontWeight: 700),
                      )
                    ],
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

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/CartController.dart';
import 'package:EMallApp/models/Cart.dart';
import 'package:EMallApp/models/CustomCart.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/AppScreen.dart';
import 'package:EMallApp/views/CheckoutOrderScreen.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:EMallApp/views/ProductScreen.dart';
import 'package:EMallApp/views/ScreenLocationPermission.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other variables
  bool isInProgress = false;
  List<CustomCart> customCarts = [];

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadCartData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }
    MyResponse<List<Cart>> myResponse =
        await CartController.getAllCartProduct();
    if (myResponse.success) {
      customCarts = CustomCart.fromCarts(myResponse.data);
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

  Future<void> _refresh() async {
    if (!isInProgress) _loadCartData();
  }

  _changeQuantity({@required int cartId, @required int quantity}) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
        await CartController.changeCartQuantity(cartId, quantity);

    if (myResponse.success) {
      _loadCartData();
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

  _deleteCart(cartId) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await CartController.deleteCart(cartId);

    if (myResponse.success) {
      _loadCartData();
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

  void _checkoutCart(List<Cart> carts) async {
    await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => CheckoutOrderScreen(
                  carts: carts,
                )));

    _refresh();
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
            theme: themeData,
            home: Scaffold(
                backgroundColor: customAppTheme.bgLayer1,
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  leading: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(MdiIcons.chevronLeft),
                  ),
                  centerTitle: true,
                  title: Text(Translator.translate("cart"),
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.headline6,
                          fontWeight: 600)),
                ),
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
                )));
      },
    );
  }

  _buildBody() {
    if (customCarts.length != 0) {
      return _showCustomCarts(customCarts);
    } else if (isInProgress) {
      return LoadingScreens.getCartLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Container(
        margin: Spacing.top(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image(
                image: AssetImage(
                  './assets/images/empty-cart.png',
                ),
                height: MySize.safeWidth * 0.5,
                width: MySize.safeWidth * 0.5,
              ),
            ),
            Container(
              margin: Spacing.only(top: 24),
              child: Text(
                Translator.translate("your_cart_is_empty"),
                style: AppTheme.getTextStyle(themeData.textTheme.subtitle1,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600,
                    letterSpacing: 0),
              ),
            ),
            Container(
              margin: Spacing.only(top: 24),
              child: FlatButton(
                  padding: Spacing.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  color: themeData.colorScheme.primary,
                  highlightColor: themeData.colorScheme.primary,
                  splashColor: Colors.white.withAlpha(100),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ScreenLocationPermission()));
                  },
                  child: Text(Translator.translate("lets_shopping"),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyText2,
                          fontWeight: 600,
                          color: themeData.colorScheme.onPrimary,
                          letterSpacing: 0.5))),
            )
          ],
        ),
      );
    }
  }

  Widget _showCustomCarts(List<CustomCart> customCarts) {
    List<Widget> listWidgets = [];
    for (CustomCart customCart in customCarts) {
      listWidgets.add(InkWell(
        onTap: () {},
        child: Container(
          margin: Spacing.fromLTRB(16, 0, 16, 24),
          padding: Spacing.all(16),
          decoration: BoxDecoration(
              color: customAppTheme.bgLayer1,
              boxShadow: [
                BoxShadow(
                  color: customAppTheme.shadowColor,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
              border: Border.all(color: customAppTheme.bgLayer4, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translator.translate("from") + " " + customCart.shopName,
                style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                    color: themeData.colorScheme.onBackground, fontWeight: 600),
              ),
              Container(
                  margin: Spacing.top(12),
                  child: showCartProducts(customCart.carts)),
              Center(
                child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.size4)),
                    color: themeData.colorScheme.primary,
                    splashColor: Colors.white.withAlpha(150),
                    highlightColor: themeData.colorScheme.primary,
                    onPressed: () {
                      _checkoutCart(customCart.carts);
                    },
                    padding: Spacing.horizontal(24),
                    child: Text(Translator.translate("checkout").toUpperCase(),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            fontSize: 12,
                            fontWeight: 600,
                            letterSpacing: 0.5,
                            color: themeData.colorScheme.onPrimary))),
              )
            ],
          ),
        ),
      ));
    }

    return Container(
      margin: Spacing.vertical(8),
      child: ListView(
        children: listWidgets,
      ),
    );
  }

  Widget showCartProducts(List<Cart> carts) {
    List<Widget> listWidgets = [];

    for (Cart cart in carts) {
      listWidgets.add(InkWell(
        onTap: () {},
        child: Container(
          margin: Spacing.bottom(16),
          child: singleCartProduct(cart),
        ),
      ));
    }

    return Container(
      child: Column(
        children: listWidgets,
      ),
    );
  }

  Widget singleCartProduct(Cart cart) {
    bool isDecrease = cart.quantity > 1;
    bool isIncrease = cart.quantity < cart.product.quantity;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductScreen(
                      productId: cart.product.id,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: customAppTheme.bgLayer4, width: 1),
        ),
        padding: Spacing.all(8),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
              child: cart.product.productImages.length != 0
                  ? Image.network(
                      cart.product.productImages[0].url,
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
                height: MySize.getScaledSizeHeight(90),
                margin: Spacing.left(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(cart.product.name,
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText1,
                            fontWeight: 600,
                            letterSpacing: 0)),
                    Text(
                      CurrencyApi.getSign(afterSpace: true) +
                          CurrencyApi.doubleToString(Product.getOfferedPrice(
                              cart.product.price, cart.product.offer)),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle2,
                          fontWeight: 500,
                          letterSpacing: 0),
                    ),
                    Container(
                      margin: Spacing.top(8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                _deleteCart(cart.id);
                              },
                              child: Container(
                                  margin: Spacing.horizontal(12),
                                  child: Icon(
                                    MdiIcons.deleteOutline,
                                    color: themeData.colorScheme.primary,
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                if (!isInProgress && isDecrease)
                                  _changeQuantity(
                                      cartId: cart.id,
                                      quantity: cart.quantity - 1);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: isDecrease
                                        ? themeData.colorScheme.primary
                                        : customAppTheme.disabledColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(MySize.size16))),
                                padding: Spacing.all(8),
                                margin: Spacing.right(8),
                                child: Icon(
                                  MdiIcons.minus,
                                  color: (cart.quantity < 2)
                                      ? customAppTheme.onDisabled
                                      : themeData.colorScheme.onPrimary,
                                  size: MySize.size14,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                cart.quantity.toString(),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    fontWeight: 600,
                                    color: themeData.colorScheme.onBackground),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (!isInProgress && isIncrease)
                                  _changeQuantity(
                                      cartId: cart.id,
                                      quantity: cart.quantity + 1);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: isIncrease
                                        ? themeData.colorScheme.primary
                                        : customAppTheme.disabledColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(MySize.size16))),
                                padding: Spacing.all(8),
                                margin: Spacing.left(8),
                                child: Icon(MdiIcons.plus,
                                    color: themeData.colorScheme.onPrimary,
                                    size: MySize.size14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
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

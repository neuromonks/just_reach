import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/AddressController.dart';
import 'package:EMallApp/controllers/OrderController.dart';
import 'package:EMallApp/models/Cart.dart';
import 'package:EMallApp/models/Coupon.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Order.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/CouponScreen.dart';
import 'package:EMallApp/views/OrderScreen.dart';
import 'package:EMallApp/views/addresses/AddAddress.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'OrderPaymentScreen.dart';

class CheckoutOrderScreen extends StatefulWidget {
  final List<Cart> carts;

  const CheckoutOrderScreen({Key key, this.carts}) : super(key: key);

  @override
  _CheckoutOrderScreenState createState() => _CheckoutOrderScreenState();
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey _addressSelectionKey = new GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<Cart> carts = [];
  List<UserAddress> userAddresses = [];
  Coupon coupon;
  int selectedAddress = 0, selectedPaymentMethod = 1, selectedOrderType = 1;
  int orderCost;
  Shop shop;

  //Order cost
  double order = 0;
  double shopTax = 0;
  double tax = 0;
  double couponDiscount = 0;
  double deliveryFee = 0;
  double total = 0;

  @override
  void initState() {
    super.initState();
    carts = widget.carts;
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _createBillData() {
    setState(() {
      order = 0;
      shop = carts[0].product.shop;
      shopTax = shop.tax;
      tax = 0;
      deliveryFee =
          Order.isPickUpOrder(selectedOrderType) ? 0 : shop.deliveryFee;
      total = 0;
      for (int i = 0; i < carts.length; i++) {
        order += Product.getOfferedPrice(
                carts[i].product.price, carts[i].product.offer) *
            carts[i].quantity;
      }
      tax = order * (shopTax) / 100;

      if (coupon != null) {
        couponDiscount = coupon.getDiscountValue(order);
      }
      total = order + tax + deliveryFee - couponDiscount;
    });
  }

  _changePaymentMethod(int method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  _changeOrderType(int type) {
    setState(() {
      selectedOrderType = type;
    });
    _createBillData();
  }

  _initData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<UserAddress>> myResponse =
        await AddressController.getMyAddresses();

    if (myResponse.success) {
      userAddresses = myResponse.data;
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    _createBillData();

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    _initData();
  }

  _makeOrder() async {
    int addressId;

    if (selectedOrderType == 2) {
      if (userAddresses.length != 0) {
        addressId = userAddresses[selectedAddress].id;
      } else {
        showMessage(message: Translator.translate("please_select_address"));
        return;
      }
    }

    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    int status = selectedPaymentMethod == 1 ? 1 : 0;

    MyResponse<Order> myResponse = await OrderController.addOrder(
        order,
        tax,
        deliveryFee,
        total,
        carts,
        selectedPaymentMethod,
        status,
        selectedOrderType,
        couponId: coupon != null ? coupon.id : null,
        addressId: addressId,
        couponDiscount: couponDiscount);

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }

    if (myResponse.success) {
      if (Order.isPaymentByCOD(selectedPaymentMethod)) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OrderScreen()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OrderPaymentScreen(
                      orderId: myResponse.data.id,
                    )));
      }
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }
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
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: customAppTheme.bgLayer2,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: customAppTheme.bgLayer2,
                  leading: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      MdiIcons.chevronLeft,
                      color: themeData.colorScheme.onBackground,
                    ),
                  ),
                  centerTitle: true,
                  title: Text(Translator.translate("checkout"),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle1,
                          fontWeight: 600)),
                ),
                body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: ListView(
                      padding: Spacing.zero,
                      children: <Widget>[
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
                        Container(
                          margin: Spacing.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                Translator.translate("delivery"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    fontWeight: 600),
                              ),
                            ],
                          ),
                        ),
                        _deliveryWidget(),
                        Container(
                          margin: Spacing.fromLTRB(16, 24, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                Translator.translate("coupon_and_payment"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    fontWeight: 600),
                              ),
                            ],
                          ),
                        ),
                        _couponAndPayment(),
                        Container(
                          margin: Spacing.fromLTRB(16, 24, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                Translator.translate("order"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    fontWeight: 600),
                              ),
                              Text(
                                " - " +
                                    carts.length.toString() +
                                    " " +
                                    Translator.translate("item"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    color: themeData.colorScheme.onBackground
                                        .withAlpha(150),
                                    fontWeight: 500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(16, 16, 16, 0),
                          padding: Spacing.all(16),
                          decoration: BoxDecoration(
                              color: customAppTheme.bgLayer1,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              border: Border.all(
                                  color: customAppTheme.bgLayer4, width: 1)),
                          child: Column(
                            children: <Widget>[
                              _productsWidget(),
                              Container(
                                margin: Spacing.top(16),
                                child: _billWidget(),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(16, 24, 16, 16),
                          child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              color: isInProgress
                                  ? customAppTheme.disabledColor
                                  : themeData.colorScheme.primary,
                              splashColor: themeData.splashColor,
                              highlightColor: themeData.colorScheme.primary,
                              onPressed: isInProgress
                                  ? () {}
                                  : () {
                                _makeOrder();
                                    },
                              child: Text(
                                Order.isPaymentByCOD(selectedPaymentMethod)
                                    ? Translator.translate("place_order")
                                        .toUpperCase()
                                    : Translator.translate("proceed_to_payment")
                                        .toUpperCase(),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    letterSpacing: 0.6,
                                    fontWeight: 600,
                                    color: isInProgress
                                        ? customAppTheme.onDisabled
                                        : themeData.colorScheme.onPrimary),
                              ),
                              padding: Spacing.vertical(16)),
                        )
                      ],
                    ))));
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

  _deliveryWidget() {
    return Container(
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      padding: Spacing.all(16),
      decoration: BoxDecoration(
        color: customAppTheme.bgLayer1,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: customAppTheme.bgLayer4, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              _selectOrderType(context);
            },
            child: Container(
                margin: Spacing.top(4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Order.getTextFromOrderType(selectedOrderType),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 600),
                          ),
                        ],
                      ),
                      Text(
                        Translator.translate("change"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.primary,
                            fontWeight: 600),
                      ),
                    ])),
          ),
          (selectedOrderType == 2)
              ? Column(
                  children: [
                    Divider(
                      height: MySize.size24,
                    ),
                    _addressWidget()
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  _addressWidget() {
    if (userAddresses.length == 0) {
      if (isInProgress) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: customAppTheme.bgLayer1,
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: customAppTheme.bgLayer4, width: 1),
            ),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: Image.asset(
                    './assets/other/map-snap.png',
                    height: 60.0,
                    width: 86,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: Spacing.left(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        Translator.translate("loading"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.subtitle1,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 600),
                      ),
                      Text(
                        Translator.translate("wait_until_fetching"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            color: themeData.colorScheme.onBackground
                                .withAlpha(150),
                            fontWeight: 500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      } else {
        return GestureDetector(
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddAddressScreen()));
            _refresh();
          },
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: Image.asset(
                  './assets/other/map-snap.png',
                  height: 60.0,
                  width: 86,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Container(
                  margin: Spacing.left(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        Translator.translate("no_saved_address"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.subtitle1,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 600),
                      ),
                      Text(
                        Translator.translate("click_to_add_one"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            color: themeData.colorScheme.onBackground
                                .withAlpha(150),
                            fontWeight: 500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return GestureDetector(
        onTap: () {
          dynamic state = _addressSelectionKey.currentState;
          state.showButtonMenu();
        },
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: Image.asset(
                './assets/other/map-snap.png',
                height: 60.0,
                width: 86,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Container(
                margin: Spacing.left(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      userAddresses[selectedAddress].address,
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.subtitle1,
                          color: themeData.colorScheme.onBackground,
                          fontWeight: 600),
                    ),
                    Text(
                      userAddresses[selectedAddress].city +
                          " - " +
                          userAddresses[selectedAddress].pincode.toString(),
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          color:
                              themeData.colorScheme.onBackground.withAlpha(150),
                          fontWeight: 500),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton(
              key: _addressSelectionKey,
              icon: Icon(
                MdiIcons.chevronDown,
                color: themeData.colorScheme.onBackground,
                size: MySize.size20,
              ),
              onSelected: (value) async {
                if (value == -1) {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddAddressScreen()));
                  _refresh();
                } else {
                  setState(() {
                    selectedAddress = value;
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                var list = List<PopupMenuEntry<Object>>();
                for (int i = 0; i < userAddresses.length; i++) {
                  list.add(PopupMenuItem(
                    value: i,
                    child: Container(
                      margin: Spacing.vertical(2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userAddresses[i].address,
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.subtitle2,
                                fontWeight: 600,
                                color: themeData.colorScheme.onBackground,
                              )),
                          Container(
                            margin: Spacing.top(2),
                            child: Text(
                                userAddresses[i].city +
                                    " - " +
                                    userAddresses[i].pincode.toString(),
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ));
                  list.add(
                    PopupMenuDivider(
                      height: 10,
                    ),
                  );
                }
                list.add(PopupMenuItem(
                  value: -1,
                  child: Container(
                    margin: Spacing.vertical(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MdiIcons.plus,
                          color: themeData.colorScheme.onBackground,
                          size: MySize.size20,
                        ),
                        Container(
                          margin: Spacing.left(4),
                          child: Text(Translator.translate("add_new_address"),
                              style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2,
                                color: themeData.colorScheme.onBackground,
                              )),
                        ),
                      ],
                    ),
                  ),
                ));
                return list;
              },
              color: themeData.backgroundColor,
            ),
          ],
        ),
      );
    }
  }

  _productsWidget() {
    List<Widget> productList = [];
    for (int i = 0; i < carts.length; i++) {
      productList.add(Container(
        margin: Spacing.vertical(4),
        padding: Spacing.all(12),
        decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            border: Border.all(color: customAppTheme.bgLayer3, width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size4))),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(carts[i].product.name,
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                      color: themeData.colorScheme.onBackground,
                      letterSpacing: 0,
                      fontWeight: 600)),
            ),
            Text(
                CurrencyApi.getSign(afterSpace: true) +
                    CurrencyApi.doubleToString(Product.getOfferedPrice(
                            carts[i].product.price, carts[i].product.offer)) +
                    " (x " +
                    carts[i].quantity.toString() +
                    ")",
                style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                    color: themeData.colorScheme.primary, fontWeight: 600))
          ],
        ),
      ));
    }
    return Column(
      children: productList,
    );
  }

  _billWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(Translator.translate("order"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      muted: true,
                      letterSpacing: 0,
                      fontWeight: 600)),
              Text(CurrencyApi.getSign(afterSpace: true) + CurrencyApi.doubleToString(order),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      muted: true,
                      letterSpacing: 0,
                      fontWeight: 600)),
            ],
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("coupon_discount"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        muted: true,
                        letterSpacing: 0,
                        fontWeight: 600)),
                Text(
                    "-" +
                        CurrencyApi.getSign(afterSpace: true) +
                        CurrencyApi.doubleToString(couponDiscount),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        muted: true,
                        fontWeight: 600)),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("tax"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        muted: true,
                        letterSpacing: 0,
                        fontWeight: 600)),
                Text(CurrencyApi.getSign(afterSpace: true) + CurrencyApi.doubleToString(tax),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        muted: true,
                        fontWeight: 600)),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("delivery_fee"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        muted: true,
                        letterSpacing: 0,
                        fontWeight: 600)),
                Text(
                    CurrencyApi.getSign(afterSpace: true) +
                        CurrencyApi.doubleToString(deliveryFee),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        muted: true,
                        fontWeight: 600)),
              ],
            ),
          ),
          Container(
            margin: Spacing.top(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Expanded(
                  child: Divider(),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("total"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        fontWeight: 700)),
                Text(CurrencyApi.getSign(afterSpace: true) + CurrencyApi.doubleToString(total),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        fontWeight: 700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _couponAndPayment() {
    return Container(
        margin: Spacing.fromLTRB(16, 16, 16, 0),
        padding: Spacing.all(16),
        decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
        child: Column(children: <Widget>[
          InkWell(
            onTap: () async {
              Coupon newCoupon = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => CouponScreen(
                            order: order,shopId: shop.id,
                          )));
              if (newCoupon != null) {
                setState(() {
                  coupon = newCoupon;
                  _createBillData();
                });
              }
            },
            child: Container(
              margin: Spacing.fromLTRB(0, 0, 0, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  coupon != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "#" + coupon.code,
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            ),
                            Text(
                                "- " +
                                    coupon.offer.toString() +
                                    "% " +
                                    Translator.translate("off").toUpperCase(),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontSize: 12,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500,
                                    letterSpacing: 0))
                          ],
                        )
                      : Container(
                          child: Text(
                          isInProgress
                              ? Translator.translate("please_wait")
                              : Translator.translate(
                                  "there_is_no_coupon_applied"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),
                        )),
                  Text(
                    Translator.translate("change_coupon"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.primary, fontWeight: 600),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              _selectPaymentMethod(context);
            },
            child: Container(
                margin: Spacing.top(4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Order.getPaymentTypeText(selectedPaymentMethod),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 600),
                          ),
                        ],
                      ),
                      Text(
                        Translator.translate("change"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.primary,
                            fontWeight: 600),
                      ),
                    ])),
          )
        ]));
  }

  _selectPaymentMethod(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                decoration: BoxDecoration(
                    color: themeData.backgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(MySize.size16),
                        topRight: Radius.circular(MySize.size16))),
                padding: EdgeInsets.symmetric(
                    vertical: MySize.size24, horizontal: MySize.size16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        Translator.translate("select_option").toUpperCase(),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground
                                .withAlpha(220)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _changePaymentMethod(1);
                                Navigator.pop(context);
                              },
                              child: Container(
                                  child: _optionWidget(
                                iconData: MdiIcons.homeOutline,
                                text: "COD",
                                isSelected: selectedPaymentMethod == 1,
                              )),
                            ),
                          ),
                          SizedBox(
                            width: MySize.size16,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                _changePaymentMethod(2);
                                Navigator.pop(context);
                              },
                              child: Container(
                                  child: _optionWidget(
                                iconData: MdiIcons.creditCardOutline,
                                text: "Razorpay",
                                isSelected: selectedPaymentMethod == 2,
                              )),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  _selectOrderType(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                decoration: BoxDecoration(
                    color: themeData.backgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(MySize.size16),
                        topRight: Radius.circular(MySize.size16))),
                padding: EdgeInsets.symmetric(
                    vertical: MySize.size24, horizontal: MySize.size16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        Translator.translate("select_option").toUpperCase(),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground
                                .withAlpha(220)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MySize.size16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _changeOrderType(1);
                                Navigator.pop(context);
                              },
                              child: Container(
                                  child: _optionWidget(
                                iconData: MdiIcons.storeOutline,
                                text: "Self Pickup",
                                isSelected: selectedOrderType == 1,
                              )),
                            ),
                          ),
                          SizedBox(
                            width: MySize.size16,
                          ),
                          shop.availableForDelivery
                              ? Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _changeOrderType(2);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        child: _optionWidget(
                                      iconData: MdiIcons.mopedOutline,
                                      text: "Delivery",
                                      isSelected: selectedOrderType == 2,
                                    )),
                                  ),
                                )
                              : Expanded(
                                  child: Container(
                                      child: _optionWidget(
                                          iconData: MdiIcons.mopedOutline,
                                          text: "Delivery",
                                          isSelected: selectedOrderType == 2,
                                          isDisabled: true)),
                                ),
                        ],
                      ),
                    ),
                    shop.availableForDelivery
                        ?  Container()
                        : Container(
                      margin: Spacing.top(8),
                      child: Text(
                        Translator.translate("this_shop_is_not_currently_available_for_delivery"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            color: customAppTheme.colorError,letterSpacing: 0),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  _optionWidget(
      {IconData iconData,
      String text,
      bool isSelected,
      bool isDisabled = false}) {
    return Container(
      decoration: BoxDecoration(
          color: isDisabled
              ? customAppTheme.disabledColor
              : (isSelected
                  ? themeData.colorScheme.primary
                  : themeData.backgroundColor),
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
          border: Border.all(
              color: isDisabled
                  ? customAppTheme.disabledColor
                  : (isSelected
                      ? themeData.colorScheme.primary
                      : customAppTheme.bgLayer4),
              width: 1)),
      padding: EdgeInsets.all(MySize.size8),
      child: Column(
        children: <Widget>[
          Icon(
            iconData,
            color: isDisabled
                ? customAppTheme.onDisabled
                : (isSelected
                    ? themeData.colorScheme.onPrimary
                    : themeData.colorScheme.onBackground),
            size: 30,
          ),
          Container(
            margin: EdgeInsets.only(top: MySize.size8),
            child: Text(
              text,
              style: AppTheme.getTextStyle(
                themeData.textTheme.caption,
                fontWeight: 600,
                color: isDisabled
                    ? customAppTheme.onDisabled
                    : (isSelected
                        ? themeData.colorScheme.onPrimary
                        : themeData.colorScheme.onBackground),
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:collection';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/OrderController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Order.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/GoogleMapUtils.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/UrlUtils.dart';
import 'package:EMallApp/views/OrderReviewScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class SingleOrderScreen extends StatefulWidget {
  final int orderId;

  const SingleOrderScreen({Key key, this.orderId}) : super(key: key);

  @override
  _SingleOrderScreenState createState() => _SingleOrderScreenState();
}

class _SingleOrderScreenState extends State<SingleOrderScreen> {
  //ThemeData
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Google Maps
  BitmapDescriptor shopPinIcon, deliveryPinIcon, deliveryBoyPinIcon;
  GoogleMapController mapController;
  bool loaded = false;
  final Set<Marker> _markers = HashSet();
  final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng currentPosition;
  String mapDarkStyle;

  //Locations
  LatLng deliveryLocation;
  LatLng deliveryBoyLocation;
  LatLng shopLocation;

  //Other variables
  bool isInProgress = false;
  Order order;

  Timer _timer;

  @override
  void initState() {
    super.initState();
    currentPosition = _center;
    _getOrderData();
    _setCustomPin();
    _setTimer();
  }

  _getOrderData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Order> myResponse =
        await OrderController.getSingleOrder(widget.orderId);
    if (myResponse.success) {
      order = myResponse.data;
      shopLocation = LatLng(order.shop.latitude, order.shop.longitude);
      if(!Order.isPickUpOrder(order.orderType)){
        deliveryLocation =
            LatLng(order.address.latitude, order.address.longitude);
      }

      if (order.deliveryBoy != null) {
        if(order.deliveryBoy.latitude!=null && order.deliveryBoy.longitude!=null) {
          deliveryBoyLocation =
              LatLng(order.deliveryBoy.latitude, order.deliveryBoy.longitude);
          _changeDeliveryPin();
        }
      }
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

  _setCustomPin() async {
    shopPinIcon = BitmapDescriptor.fromBytes(
        await GoogleMapUtils.getBytesFromAsset('assets/map/shop-pin.png',
            MySize.getScaledSizeHeight(128).floor()));

    deliveryPinIcon = BitmapDescriptor.fromBytes(
        await GoogleMapUtils.getBytesFromAsset('assets/map/delivery-pin.png',
            MySize.getScaledSizeHeight(100).floor()));

    deliveryBoyPinIcon = BitmapDescriptor.fromBytes(
        await GoogleMapUtils.getBytesFromAsset(
            'assets/map/delivery-boy-pin.png',
            MySize.getScaledSizeHeight(60).floor()));

    String mapStyle =
        await rootBundle.loadString('assets/map/map-dark-style.txt');

    if (mounted) {
      setState(() {
        mapDarkStyle = mapStyle;
      });
    }
  }

  _changeDeliveryPin(){
    Marker deliveryBoyMarker;
    if (deliveryBoyLocation != null) {
      deliveryBoyMarker = Marker(
          markerId: MarkerId('delivery_boy_location'),
          position: deliveryBoyLocation,
          icon: deliveryBoyPinIcon);
    }

    if(mounted){
      setState(() {
        _markers.add(deliveryBoyMarker);
      });
    }

  }

  _onMarkerTapped(LatLng latLng) async{
    double zoom = await (mapController.getZoomLevel());
    zoom = zoom>17 ? zoom : 17;
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: latLng, zoom: zoom)));
  }


  _setMapStyle(int themeMode) {
    if (themeMode == 2 && mapDarkStyle != null && mapController != null) {
      mapController.setMapStyle(mapDarkStyle);
    } else if (mapController != null) {
      mapController.setMapStyle("[]");
    }
  }

  _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    mapController.setMapStyle(mapDarkStyle);
    Marker shopMarker = Marker(
        markerId: MarkerId('shop_location'),
        position: shopLocation,
        icon: shopPinIcon,
    onTap: (){
      _onMarkerTapped(shopLocation);
    });

    Marker locationMarker;
    if(deliveryLocation!=null) {
      locationMarker = Marker(
          markerId: MarkerId('delivery_location'),
          position: deliveryLocation,
          icon: deliveryPinIcon,
          onTap: (){
            _onMarkerTapped(deliveryLocation);
          });
    }

    Marker deliveryBoyMarker;
    if (deliveryBoyLocation != null) {
      deliveryBoyMarker = Marker(
          markerId: MarkerId('delivery_boy_location'),
          position: deliveryBoyLocation,
          icon: deliveryBoyPinIcon,
          onTap: (){
            _onMarkerTapped(deliveryBoyLocation);
          });
    }

    if (mounted) {
      setState(() {
        _markers.add(shopMarker);
        if(deliveryBoyLocation!=null) {
          _markers.add(locationMarker);
        }
        if(deliveryBoyLocation!=null){
          _markers.add(deliveryBoyMarker);
        }
      });
    }
  }

  _changeStatus(int status) async {
    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
    await OrderController.updateOrder(order.id,status);
    if (myResponse.success) {
        _refresh();
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }
    if(mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    if (_timer != null) _timer.cancel();
  }

  Future<void> _refresh() async {
    _getOrderData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        _setMapStyle(themeType);
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: customAppTheme.bgLayer1,
                body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: order != null
                              ? GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  markers: _markers,
                                  initialCameraPosition: CameraPosition(
                                    target: _center,
                                    zoom: 11.0,
                                  ),
                                )
                              : Container(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: Spacing.bottom(16),
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
                        )
                      ],
                    ))));
      },
    );
  }

  _buildBody() {
    if (order != null) {
      return Column(
        children: [
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          MdiIcons.chevronLeft,
                          size: MySize.size20,
                          color: themeData.colorScheme.onBackground,
                        )),
                  ),
                ),
                Container(
                  width: MySize.size16,
                  height: MySize.size16,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size8)),
                      border: Border.all(
                          color: Order.getColorFromOrderStatus(order.status)
                              .withAlpha(40),
                          width: MySize.size4)),
                  child: Container(
                      width: MySize.size8,
                      height: MySize.size8,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size4)),
                          color: Order.getColorFromOrderStatus(order.status))),
                ),
                Container(
                  margin: Spacing.left(8),
                  child: Text(Order.getTextFromOrderStatus(order.status,order.orderType)),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                        onTap: () {
                          _refresh();
                        },
                        child: Icon(
                          MdiIcons.refresh,
                          size: MySize.size20,
                          color: themeData.colorScheme.onBackground,
                        )),
                  ),
                )
              ],
            ),
          ),
          _billWidget(),
          _buttonForStatus()
        ],
      );
    } else {
      return Center(
        child: Text("Something wrong"),
      );
    }
  }

  _buttonForStatus() {
    if (Order.isPickUpOrder(order.orderType)) {
      if (order.status == 1) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Center(child: Text(
              Translator.translate("your_order_is_not_confirmed_by_shop"))),
        );
      }
      else if (order.status == 2) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlineButton(
                borderSide: BorderSide(
                    color: themeData.colorScheme.primary,
                    style: BorderStyle.solid,
                    width: 1),
                splashColor: themeData.colorScheme.primary.withAlpha(100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  UrlUtils.openMap(order.shop.latitude, order.shop.longitude);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.mapMarkerOutline,
                      color: themeData.colorScheme.onBackground,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("go_to_shop"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground),
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                color: themeData.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  UrlUtils.callFromNumber(order.shop.mobile);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.phoneOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("call_at_shop"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
      else if (order.status == 3) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlineButton(
                borderSide: BorderSide(
                    color: themeData.colorScheme.primary,
                    style: BorderStyle.solid,
                    width: 1),
                splashColor: themeData.colorScheme.primary.withAlpha(100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  UrlUtils.openMap(order.shop.latitude, order.shop.longitude);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.mapMarkerOutline,
                      color: themeData.colorScheme.onBackground,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("go_to_shop"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground),
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                color: themeData.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  _changeStatus(5);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.shoppingOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("pickup_order"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
      else if (order.status == 5) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                color: themeData.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          OrderReviewScreen(
                            orderId: order.id,
                          ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.starOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("Review order"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
      else {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Center(child: Text("Something wrong")),
        );
      }
    }
    else {
      if (order.status == 2) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlineButton(
                borderSide: BorderSide(
                    color: themeData.colorScheme.primary,
                    style: BorderStyle.solid,
                    width: 1),
                splashColor: themeData.colorScheme.primary.withAlpha(100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  UrlUtils.openMap(order.shop.latitude, order.shop.longitude);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.mapMarkerOutline,
                      color: themeData.colorScheme.onBackground,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("go_to_shop"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground),
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                color: themeData.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  UrlUtils.callFromNumber(order.shop.mobile);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.phoneOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("call_at_shop"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (order.status == 3 || order.status == 4) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlineButton(
                borderSide: BorderSide(
                    color: themeData.colorScheme.primary,
                    style: BorderStyle.solid,
                    width: 1),
                splashColor: themeData.colorScheme.primary.withAlpha(100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  if (deliveryBoyLocation != null) {
                    UrlUtils.openMap(
                        order.deliveryBoy.latitude,
                        order.deliveryBoy.longitude);
                  } else {
                    showMessage(message: Translator.translate(
                        "perhaps_delivery_boy_is_on_another_order"));
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.mapMarkerOutline,
                      color: themeData.colorScheme.onBackground,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("delivery_boy"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onBackground),
                      ),
                    )
                  ],
                ),
              ),
              FlatButton(
                color: themeData.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  UrlUtils.callFromNumber(order.deliveryBoy.mobile);
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.phoneOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("call_delivery_boy"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
      else if (order.status == 5) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                color: themeData.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size4)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          OrderReviewScreen(
                            orderId: order.id,
                          ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.starOutline,
                      color: themeData.colorScheme.onPrimary,
                      size: MySize.size18,
                    ),
                    Container(
                      margin: Spacing.left(8),
                      child: Text(
                        Translator.translate("Review order"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (order.status == 1) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Center(child: Text(
              Translator.translate("your_order_is_not_confirmed_by_shop"))),
        );
      } else if (order.status == 0) {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Center(child: Text(
              Translator.translate("your_payment_is_not_confirmed_yet"))),
        );
      } else {
        return Container(
          margin: Spacing.fromLTRB(16, 8, 16, 8),
          child: Center(child: Text("Something wrong")),
        );
      }
    }
  }

  _billWidget() {
    return Container(
      margin: Spacing.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
          border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
      padding: Spacing.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translator.translate("billing_information"),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                color: themeData.colorScheme.onBackground,
                fontWeight: 600,
                muted: true),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("order"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) + order.order.toString(),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("tax"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) + order.tax.toString(),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("delivery_fee"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) + order.deliveryFee.toString(),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(),
                ),
                Expanded(
                  child: Divider(),
                )
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 4, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("total"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
                Text(
                  CurrencyApi.getSign(afterSpace: true) + order.total.toString(),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _setTimer() {
    //Every 20 sec delivery boy and order location updated
    _timer = new Timer.periodic(
        Duration(seconds: 20),
        (Timer timer) =>
              _getOrderData()
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

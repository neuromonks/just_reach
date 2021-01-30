import 'dart:async';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/CartController.dart';
import 'package:EMallApp/controllers/FavoriteController.dart';
import 'package:EMallApp/controllers/ProductController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/models/ProductImage.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:EMallApp/views/CartScreen.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:EMallApp/views/ProductReviewsScreen.dart';
import 'package:EMallApp/views/ShopScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  final int productId;

  const ProductScreen({Key key, @required this.productId}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Other Variables
  Product product;
  bool isInProgress = false;
  bool addingIntoCart = false;
  List<int> ratingList;
  int maxRating;


  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage= 0;
  Timer timerAnimation;


  @override
  void initState() {
    super.initState();
    _getProductDetail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProductDetail() async {

    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Product> myResponse =
        await ProductController.getSingleProduct(widget.productId);


    if (myResponse.success) {
      product = myResponse.data;
      _makingRatingList();
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

  _makingRatingList() {
    if (ratingList == null) {
      ratingList = [0, 0, 0, 0, 0, 0];
      for (int i = 0; i < product.reviews.length; i++) {
        ratingList[product.reviews[i].rating]++;
      }
      int max = 0;
      for (int i = 1; i < 6; i++) {
        if (ratingList[i] > max) max = ratingList[i];
      }

      setState(() {
        maxRating = max;
      });
    }
  }

  _addInCart() async {

    if(mounted) {
      setState(() {
        addingIntoCart = true;
      });
    }

    MyResponse myResponse = await CartController.addIntoCart(product.id);

    if(mounted) {
      setState(() {
        addingIntoCart = false;
      });
    }

    if (myResponse.success) {
      showMessage(message: Translator.translate("product_added"));
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }
  }

  _toggleFavorite() async {

    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse = await FavoriteController.toggleFavorite(product.id);
    if (myResponse.success) {
      product.isFavorite =
          TextUtils.parseBool(myResponse.data['is_favorite'].toString());
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


  addTimers(int totalPages){
    if(timerAnimation==null) {
      timerAnimation = Timer.periodic(Duration(seconds: 5), (Timer timer) {
        if (_currentPage < totalPages - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 600),
          curve: Curves.ease,
        );
      });
    }
  }

  List<Widget> _buildPageIndicatorAnimated(int totalPages,ThemeData themeData) {
    List<Widget> list = [];
    if(totalPages>1) {
      addTimers(totalPages);

      for (int i = 0; i < totalPages; i++) {
        list.add(i == _currentPage ? _indicator(true, themeData) : _indicator(
            false, themeData));
      }

    }else{
      list.add(Container());
    }
    return list;
  }

  Widget _indicator(bool isActive,ThemeData themeData) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: Spacing.horizontal(4),
      height: MySize.size8,
      width: MySize.size8,
      decoration: BoxDecoration(
        color: isActive
            ? themeData.colorScheme.onBackground
            : themeData.colorScheme.onBackground.withAlpha(140),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget child) {
      themeData = AppTheme.getThemeFromThemeMode(value.themeMode());
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context,product);
          return false;
        },
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(

                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context, product);
                    },
                    child: Icon(MdiIcons.chevronLeft),
                  ),
                  centerTitle: true,
                  title: Text(product != null ? product.name : "Loading...",
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.headline6,
                          fontWeight: 600)),
                ),
                backgroundColor:customAppTheme.bgLayer1,
                body: Container(
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
                      Expanded(child: buildBody()),
                    ],
                  ),
                ))),
      );
    });
  }

  buildBody() {
    if (product != null) {
      List<Widget> carouselItems = [];
      if(product.productImages.length!=0){
        for(ProductImage productImage in product.productImages){
          carouselItems.add(Container(
            child: Center(
              child: Image.network(
                productImage.url,
                fit: BoxFit.cover,
              ),
            ),
          ));
        }
      }else{
        carouselItems.add(Image.asset(
          Product.getPlaceholderImage(),
        ));

      }
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: Spacing.zero,
              children: [
                Container(
                  height: MediaQuery.of(context)
                      .size
                      .height *
                      0.3,
                  child: PageView(
                    pageSnapping: true,
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: carouselItems,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: _buildPageIndicatorAnimated(product.productImages.length,themeData),
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 0),
                  padding: Spacing.all(16),
                  decoration: BoxDecoration(
                      color: customAppTheme.bgLayer1,
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size4)),
                      border:
                          Border.all(color: customAppTheme.bgLayer4, width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          product.name,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText1,
                              color: themeData.colorScheme.onBackground),
                        ),
                      ),
                      Container(
                        margin: Spacing.top(2),
                        child: Product.getTextFromQuantity(
                            product.quantity,
                            AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2),
                            themeData,
                            customAppTheme),
                      ),
                      Container(
                        margin: Spacing.top(2),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ShopScreen(
                                          shopId: product.shopId,
                                        )));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                MdiIcons.storeOutline,
                                color: themeData.colorScheme.primary,
                                size: MySize.size20,
                              ),
                              Container(
                                margin: Spacing.left(8),
                                child: Text(
                                  product.shop.name,
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color: themeData.colorScheme.primary,
                                      fontWeight: 500),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                          alignment: Alignment.centerRight,
                          margin: Spacing.top(4),
                          child: Product.offerTextWidget(
                              originalPrice: product.price,
                              offer: product.offer,
                              fontSize: 20,
                              customAppTheme: customAppTheme,
                              themeData: themeData)),
                    ],
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 0),
                  padding: Spacing.all(0),
                  decoration: BoxDecoration(
                      color: customAppTheme.bgLayer1,
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size4)),
                      border:
                          Border.all(color: customAppTheme.bgLayer4, width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: Spacing.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          Translator.translate("description"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),
                        ),
                      ),
                      Container(
                        margin: Spacing.fromLTRB(16, 0, 16, 0),
                        child: Html(
                          shrinkWrap: true,
                          data: product.description,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 16),
                  padding: Spacing.all(0),
                  decoration: BoxDecoration(
                      color: customAppTheme.bgLayer1,
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size4)),
                      border:
                          Border.all(color: customAppTheme.bgLayer4, width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: Spacing.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Translator.translate("ratings_and_reviews"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => ProductReviewsScreen(productId:widget.productId)));
                              },
                              child: Text(
                                Translator.translate("view_more"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    color: themeData.colorScheme.primary,
                                    fontWeight: 600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: Spacing.fromLTRB(16, 8, 16, 8),
                        child: _buildRatingWidget(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          _makeBottomBar()
        ],
      );
    } else if (isInProgress) {
      return LoadingScreens.getProductLoadingScreen(
          context, themeData, customAppTheme);
    } else {
      return Center(
        child: Text("Something wrong"),
      );
    }
  }

  _makeBottomBar() {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: customAppTheme.shadowColor,
                blurRadius: MySize.size2,
                offset: Offset(0, 0))
          ],
          border: Border.all(color: customAppTheme.bgLayer4,width: 1),
          color: customAppTheme.bgLayer1,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MySize.size16),
              topRight: Radius.circular(MySize.size16))),
      padding: Spacing.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: () {
                _toggleFavorite();
              },
              child: Container(
                margin: Spacing.right(16),
                padding: Spacing.all(16),
                decoration: BoxDecoration(
                    color: themeData.colorScheme.primary.withAlpha(40),
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size8))),
                child: Icon(
                  product.isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
                  size: MySize.size24,
                  color: themeData.colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                  boxShadow: [
                    BoxShadow(
                      color: themeData.colorScheme.primary.withAlpha(40),
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySize.size8)),
                  color: themeData.colorScheme.primary,
                  splashColor: themeData.splashColor,
                  highlightColor: themeData.colorScheme.primary,
                  onPressed: () {
                    _addInCart();
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            CurrencyApi.getSign(afterSpace: true) +
                                Product.getOfferedPrice(
                                        product.price, product.offer)
                                    .toString(),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.subtitle1,
                                letterSpacing: 0.4,
                                fontWeight: 700,
                                color: themeData.colorScheme.onPrimary),
                          ),
                        ),
                      ),
                      Container(
                        child: addingIntoCart
                            ? Container(
                                width: MySize.size22,
                                height: MySize.size22,
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeData.colorScheme.onPrimary),
                                    strokeWidth: 1.4),
                              )
                            : ClipOval(
                                child: Container(
                                  color: themeData.colorScheme.primaryVariant,
                                  child: SizedBox(
                                      width: MySize.size26,
                                      height: MySize.size26,
                                      child: Icon(
                                        MdiIcons.cartArrowDown,
                                        color: themeData.colorScheme.onPrimary,
                                        size: MySize.size14,
                                      )),
                                ),
                              ),
                      )
                    ],
                  ),
                  padding: EdgeInsets.only(
                      top: MySize.size12,
                      bottom: MySize.size12,
                      right: MySize.size16),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CartScreen()));
              },
              child: Container(
                margin: Spacing.left(16),
                padding: Spacing.all(16),
                decoration: BoxDecoration(
                    color: themeData.colorScheme.primary.withAlpha(40),
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size8))),
                child: Icon(
                  MdiIcons.shoppingOutline,
                  size: MySize.size24,
                  color: themeData.colorScheme.primary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showMessage({String message = "Something wrong", Duration duration}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
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

  _buildRatingWidget() {
    List<Widget> list = [];
    maxRating = maxRating == 0 ? 1 : maxRating;
    for (int i = 5; i > 0; i--) {
      int progress = ((ratingList[i] / maxRating) * 100).ceil();
      list.add(Row(
        children: [
          Container(
            child: Text(
              i.toString(),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  fontSize: 12,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600),
            ),
          ),
          Container(
            margin: Spacing.left(2),
            child: Icon(
              MdiIcons.star,
              color: themeData.colorScheme.onBackground,
              size: MySize.size12,
            ),
          ),
          Expanded(
            child: Container(
              margin: Spacing.left(8),
              height: 4,
              decoration: BoxDecoration(
                  color: themeData.colorScheme.onBackground.withAlpha(60),
                  borderRadius:
                      BorderRadius.all(Radius.circular(MySize.size4))),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                          color: Generator.getColorByRating(customAppTheme)[i],
                          borderRadius:
                              BorderRadius.all(Radius.circular(MySize.size4))),
                    ),
                  ),
                  Expanded(
                    flex: 100 - progress,
                    child: Container(),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: Spacing.left(8),
            child: Text(
              ratingList[i].toString(),
              style: AppTheme.getTextStyle(themeData.textTheme.caption,
                  color: themeData.colorScheme.onBackground, muted: true),
            ),
          )
        ],
      ));
    }

    return Container(
        margin: Spacing.top(8),
        child: Row(
          children: [
            Container(
              margin: Spacing.fromLTRB(8, 0, 16, 0),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: Spacing.fromLTRB(0, 4, 2, 0),
                          child: Text(
                            TextUtils.doubleToString(product.rating),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText2,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 600,
                                letterSpacing: 0.25),
                          ),
                        ),
                        Icon(
                          MdiIcons.star,
                          color: themeData.colorScheme.onBackground,
                          size: MySize.size20,
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: Spacing.top(4),
                    child: Text(
                      product.totalRating.toString() + " Ratings",
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyText2,
                          color: themeData.colorScheme.onBackground,
                          muted: true),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: list,
              ),
            ),
          ],
        ));
  }
}

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/CategoryController.dart';
import 'package:EMallApp/controllers/ProductController.dart';
import 'package:EMallApp/models/Category.dart';
import 'package:EMallApp/models/Filter.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/ColorUtils.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:EMallApp/views/ProductScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<bool> _dataExpansionPanel = [true];
  List<Product> products = [];
  List<Category> categories = [];

  //Filter Variable
  Filter filter = Filter();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _filterProductData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Pull to refresh call this function
  Future<void> _refresh() async {
    _filterProductData();
  }

  //Get all filter product data
  _filterProductData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Product>> myResponseProduct =
        await ProductController.getFilteredProduct(filter);

    if (myResponseProduct.success) {
      products = myResponseProduct.data;
    } else {
      if (mounted) {
        ApiUtil.checkRedirectNavigation(
            context, myResponseProduct.responseCode);
        showMessage(message: myResponseProduct.errorText);
      }
    }

    if (categories.length == 0) {
      MyResponse<List<Category>> myResponseCategory =
          await CategoryController.getAllCategory();
      if (myResponseCategory.success) {
        categories = myResponseCategory.data;
      } else {
        if (mounted) {
          ApiUtil.checkRedirectNavigation(
              context, myResponseCategory.responseCode);
          showMessage(message: myResponseCategory.errorText);
        }
      }
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  _clearFilter() {
    setState(() {
      filter = Filter();
    });
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
                  backgroundColor: customAppTheme.bgLayer1,
                  resizeToAvoidBottomInset: false,
                  endDrawer: _endDrawer(),
                  key: _scaffoldKey,
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
                            child: Column(
                          children: [
                            searchBar(),
                            Expanded(child: buildBody()),
                          ],
                        ))
                      ],
                    ),
                  )),
            ));
      },
    );
  }

  Widget buildBody() {
    if (products.length != 0) {
      return Container(margin: Spacing.top(4), child: _showProducts(products));
    } else if (isInProgress) {
      return Container(
          margin: Spacing.top(16),
          child: LoadingScreens.getSearchLoadingScreen(
              context, themeData, customAppTheme,
              itemCount: 5));
    } else {
      return Center(
          child: Container(
              margin: Spacing.top(16), child: Text('No products found')));
    }
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
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      child: ListView(
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
                          activeColor: ColorUtils.getColorFromRating(
                              product.rating.ceil(), customAppTheme, themeData),
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

  Widget searchBar() {
    return Padding(
        padding: Spacing.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                    letterSpacing: 0, fontWeight: 500),
                decoration: InputDecoration(
                  hintText: Translator.translate("search"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle2,
                      letterSpacing: 0,
                      fontWeight: 500),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(MySize.size8),
                      ),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(MySize.size8),
                      ),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(MySize.size8),
                      ),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: themeData.colorScheme.background,
                  prefixIcon: Icon(
                    MdiIcons.magnify,
                    size: MySize.size22,
                    color: themeData.colorScheme.onBackground.withAlpha(200),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.only(right: MySize.size16),
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (value) {
                  filter.name = value;
                  _filterProductData();
                },
              ),
            ),
            InkWell(
              onTap: () {
                _scaffoldKey.currentState.openEndDrawer();
              },
              child: Container(
                margin: EdgeInsets.only(left: MySize.size16),
                decoration: BoxDecoration(
                  color: customAppTheme.bgLayer1,
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
                  border: Border.all(color: customAppTheme.bgLayer4),
                  boxShadow: [
                    BoxShadow(
                      color: customAppTheme.shadowColor,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                padding: Spacing.all(12),
                child: Icon(
                  MdiIcons.tune,
                  color: themeData.colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ));
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

  _endDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      color: themeData.backgroundColor,
      child: ListView(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translator.translate("filter").toUpperCase(),
                    style: AppTheme.getTextStyle(themeData.textTheme.subtitle1,
                        fontWeight: 700, color: themeData.colorScheme.primary),
                  ),
                  InkWell(
                    onTap: () {
                      _clearFilter();
                    },
                    child: Text(
                      Translator.translate("clear"),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyText2,
                          fontWeight: 500,
                          color: themeData.colorScheme.onBackground),
                    ),
                  ),
                ],
              )),
          Container(
            margin: Spacing.top(24),
            child: ExpansionPanelList(
              expandedHeaderPadding: Spacing.all(0),
              dividerColor: Colors.transparent,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _dataExpansionPanel[index] = !isExpanded;
                });
              },
              animationDuration: Duration(milliseconds: 500),
              children: <ExpansionPanel>[
                ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(Translator.translate("category"),
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                color: isExpanded
                                    ? themeData.colorScheme.primary
                                    : themeData.colorScheme.onBackground,
                                fontWeight: isExpanded ? 700 : 600)),
                      );
                    },
                    body: Container(
                        padding: Spacing.fromLTRB(16, 0, 0, 0),
                        child: categoryFilterList()),
                    isExpanded: _dataExpansionPanel[0]),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(20, 8, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("only_offer"),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 600),
                ),
                Switch(
                    value: filter.isInOffer,
                    onChanged: (value) {
                      setState(() {
                        filter.setIsInOffer(value);
                      });
                    })
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(MySize.size24),
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size4)),
                    boxShadow: [
                      BoxShadow(
                        color: themeData.colorScheme.primary.withAlpha(24),
                        blurRadius: 3,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.size8)),
                    color: themeData.colorScheme.primary,
                    splashColor: Colors.white.withAlpha(40),
                    highlightColor: themeData.colorScheme.primary,
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                      _filterProductData();
                    },
                    child: Text(
                      Translator.translate("apply").toUpperCase(),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyText2,
                          fontWeight: 600,
                          color: themeData.colorScheme.onPrimary,
                          letterSpacing: 0.3),
                    ),
                    padding: EdgeInsets.only(
                        top: MySize.size12, bottom: MySize.size12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget categoryFilterList() {
    List<Widget> list = [];
    for (Category category in categories) {
      list.add(Container(
        child: InkWell(
          onTap: () {
            setState(() {
              filter.toggleCategory(category.id);
            });
          },
          child: Row(
            children: <Widget>[
              Checkbox(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: filter.categories.contains(category.id),
                activeColor: themeData.colorScheme.primary,
                onChanged: (bool value) {
                  setState(() {
                    filter.toggleCategory(category.id);
                  });
                },
              ),
              Container(
                  margin: Spacing.left(4),
                  child: Text(
                    category.title,
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.bodyText2,
                      fontWeight: 500,
                    ),
                  ))
            ],
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }
}

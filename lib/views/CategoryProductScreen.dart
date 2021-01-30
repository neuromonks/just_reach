import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/ProductController.dart';
import 'package:EMallApp/models/Category.dart';
import 'package:EMallApp/models/Filter.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'ProductScreen.dart';

class CategoryProductScreen extends StatefulWidget {
  final Category category;

  const CategoryProductScreen({Key key, this.category}) : super(key: key);

  @override
  _CategoryProductScreenState createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<Product> products;

  @override
  void initState() {
    super.initState();
    _getProduct();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProduct() async {
    if(mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    Filter filter = new Filter();
    filter.toggleCategory(widget.category.id);

    MyResponse<List<Product>> myResponse =
        await ProductController.getFilteredProduct(filter);

    if (myResponse.success) {
      products = myResponse.data;
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

  Future<void> _refresh() async {
    if (!isInProgress) _getProduct();
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
                elevation: 0,
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(MdiIcons.chevronLeft),
                ),
                centerTitle: true,
                title: Text(widget.category.title,
                    style: AppTheme.getTextStyle(
                        themeData.appBarTheme.textTheme.headline6,
                        fontWeight: 600)),
              ),
              backgroundColor: themeData.backgroundColor,
              body:  RefreshIndicator(
          onRefresh: _refresh,
          backgroundColor: customAppTheme.bgLayer1,
          color: themeData.colorScheme.primary,
          key: _refreshIndicatorKey,
          child: Container(
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
                Expanded(child: _buildBody()),
              ],
            ),
          ))));
    });
  }

  _buildBody() {
    if (products != null) {
      if(products.length==0){
        return Center(child: Text(Translator.translate("there_is_no_product_with_this_category")),);
      }
      return _showProducts(products);
    } else if (isInProgress) {
      return LoadingScreens.getSearchLoadingScreen(
          context, themeData, customAppTheme);
    }
    else {
      return Center(
        child: Text(Translator.translate("something_wrong")),
      );
    }
  }

  Widget _showProducts(List<Product> products) {
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
          child: singleProduct(products[i]),
        ),
      ));
    }

    return Container(
      margin: Spacing.fromLTRB(16, 0, 16, 0),
      child: ListView(
        children: listWidgets,
      ),
    );
  }

  Widget singleProduct(Product product) {
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
      padding: Spacing.all(16),
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
              margin: Spacing.left(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(product.name,
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
                        margin: Spacing.left(4),
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
                            Product.getOfferedPrice(
                                product.price, product.offer)
                                .toString(),
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



}

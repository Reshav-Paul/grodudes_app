import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:grodudes/components/CategoryCard.dart';
import 'package:grodudes/components/ProductCard.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/models/Category.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/pages/HomeSpecialProductsPage.dart';
import 'package:provider/provider.dart';

import '../state/products_state.dart';

class Home extends StatefulWidget {
  final Function pageChangeCb;
  Home(this.pageChangeCb);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _openLatestProductsPage(productIds) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => HomeSpecialProductsPage(
          'Latest Products',
          productIds,
          () => Provider.of<ProductsManager>(context, listen: false)
              .fetchLatestProducts(shouldNotify: true),
        ),
      ),
    );
  }

  _openTopRatedProductsPage(productIds) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => HomeSpecialProductsPage(
          'Top Rated Products',
          productIds,
          () => Provider.of<ProductsManager>(context, listen: false)
              .fetchRatedProducts(shouldNotify: true),
        ),
      ),
    );
  }

  _openPopularProductsPage(productIds) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => HomeSpecialProductsPage(
          'Popular Products',
          productIds,
          () => Provider.of<ProductsManager>(context, listen: false)
              .fetchPopularProducts(shouldNotify: true),
        ),
      ),
    );
  }

  Future<List<Widget>> _getCarouselImages() async {
    try {
      var response = await http.get('https://grodudes.com/json/url.json');
      var resJson = json.decode(response.body);
      List<dynamic> imgUrls = resJson['url'].map((e) => e.toString()).toList();
      List<Widget> images = [];
      imgUrls.forEach(
        (url) => images.add(Image.network(
          url.toString(),
          fit: BoxFit.fitHeight,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 0.344,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text('Failed to get images'),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
        )),
      );
      return images;
    } catch (err) {
      print(err);
      throw err;
    }
  }

  List<Widget> _getDefaultCarouselImages() {
    List<String> defaultPaths = ['Banner1.jpg', 'Banner2.jpg'];
    return defaultPaths
        .map((path) => Image.asset(
              'assets/images/$path',
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text('Failed to get images'),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.344,
            ))
        .toList();
  }

  CarouselOptions _defaultCarouselOptions = CarouselOptions(
    aspectRatio: 2.912,
    viewportFraction: 1,
    enableInfiniteScroll: false,
    autoPlay: true,
    autoPlayInterval: Duration(seconds: 5),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<ProductsManager>(
      builder: (context, productsManager, child) {
        double carouselHeight = MediaQuery.of(context).size.width * 0.344;
        return ListView(
          cacheExtent: 2000,
          children: <Widget>[
            FutureBuilder(
              future: _getCarouselImages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return CarouselSlider(
                    items: _getDefaultCarouselImages(),
                    options: _defaultCarouselOptions,
                  );
                }

                if (snapshot.hasData) {
                  return CarouselSlider(
                    items: snapshot.data,
                    options: _defaultCarouselOptions,
                  );
                }

                return Container(
                  height: carouselHeight,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            _HeaderRow('Categories', this.widget.pageChangeCb),
            HomeCategory(productsManager),
            FutureBuilder(
              future: productsManager.fetchLatestProducts(),
              builder: (context, snapshot) => Column(
                children: <Widget>[
                  _HeaderRow(
                    'Latest Products',
                    snapshot.connectionState == ConnectionState.done
                        ? () => _openLatestProductsPage(
                            productsManager.latestProductIds)
                        : () {},
                  ),
                  Container(
                    // height: _screenHeight * 0.25,
                    height: 210,
                    child: snapshot.connectionState != ConnectionState.done
                        ? Center(child: CircularProgressIndicator())
                        : snapshot.hasData
                            ? _HorizontalProductRow(
                                productIds: productsManager.latestProductIds,
                                products: productsManager.products,
                              )
                            : snapshot.hasError
                                ? _SpecialProductsLoadError()
                                : Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: productsManager.fetchRatedProducts(),
              builder: (context, snapshot) => Column(
                children: <Widget>[
                  _HeaderRow(
                    'Top Rated Products',
                    snapshot.connectionState == ConnectionState.done
                        ? () => _openTopRatedProductsPage(
                            productsManager.topRatedProductIds)
                        : () {},
                  ),
                  Container(
                    // height: _screenHeight * 0.25,
                    height: 210,
                    child: snapshot.connectionState != ConnectionState.done
                        ? Center(child: CircularProgressIndicator())
                        : snapshot.hasData
                            ? _HorizontalProductRow(
                                productIds: productsManager.topRatedProductIds,
                                products: productsManager.products,
                              )
                            : snapshot.hasError
                                ? _SpecialProductsLoadError()
                                : Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: productsManager.fetchPopularProducts(),
              builder: (context, snapshot) => Column(
                children: <Widget>[
                  _HeaderRow(
                    'Popular Products',
                    snapshot.connectionState == ConnectionState.done
                        ? () => _openPopularProductsPage(
                            productsManager.popularProductIds)
                        : () {},
                  ),
                  Container(
                    height: 210,
                    child: snapshot.connectionState != ConnectionState.done
                        ? Center(child: CircularProgressIndicator())
                        : snapshot.hasData
                            ? _HorizontalProductRow(
                                productIds: productsManager.popularProductIds,
                                products: productsManager.products,
                              )
                            : snapshot.hasError
                                ? _SpecialProductsLoadError()
                                : Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        );
      },
      // child: ,
    );
  }
}

class HomeCategory extends StatefulWidget {
  final ProductsManager productsManager;
  HomeCategory(this.productsManager);
  @override
  _HomeCategoryState createState() => _HomeCategoryState();
}

class _HomeCategoryState extends State<HomeCategory> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.productsManager.fetchAllParentCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasData) {
          List<Category> categories =
              widget.productsManager.categories.values.toList();
          return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length > 6 ? 6 : categories.length,
            itemBuilder: (context, index) {
              return CategoryCard(categories[index]);
            },
          );
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Column(
              children: [
                Text('Failed to fetch categories'),
                RaisedButton(
                  child: Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => setState(() {}),
                )
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _SpecialProductsLoadError extends StatelessWidget {
  const _SpecialProductsLoadError({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.6,
          child: Text(
            'Failed to fetch data! You can try pressing the see all button to retry',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final Function cb;
  final String title;
  _HeaderRow(this.title, this.cb);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.all(0),
            child: Text(
              'See All',
              style: TextStyle(
                color: GrodudesPrimaryColor.primaryColor[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: this.cb,
          ),
        ],
      ),
    );
  }
}

class _HorizontalProductRow extends StatelessWidget {
  final Set<int> productIds;
  final Map<int, Product> products;
  _HorizontalProductRow({@required this.productIds, @required this.products});

  @override
  Widget build(BuildContext context) {
    if (productIds == null || products == null) {
      return Center(
        child: Text(
          'There was an Error! You can try pressing the see all button to retry',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (productIds.length == 0) {
      return Center(
        child: Text(
          'Failed to fetch the products! You can try pressing the see all button to retry',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: productIds.length > 4 ? 4 : productIds.length,
      itemBuilder: (context, index) => Container(
        width: 150,
        child: ProductCard(products[productIds.elementAt(index)]),
      ),
    );
  }
}

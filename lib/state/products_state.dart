import 'package:flutter/cupertino.dart';
import 'package:grodudes/helper/WooCommerceAPI.dart';
import 'package:grodudes/models/Category.dart';
import 'package:grodudes/models/Product.dart';
import '../secrets.dart';

const productsPerPage = 50;

class ProductsManager with ChangeNotifier {
  Map<int, Product> products;
  Map<int, Category> categories;
  bool isFetchingCategories = false;
  Set<int> popularProductIds;
  Set<int> topRatedProductIds;
  Set<int> latestProductIds;
  int nextProductPage;
  bool allProductPagesFetched;
  WooCommerceAPI wooCommerceAPI;

  ProductsManager() {
    products = {};
    categories = {};
    nextProductPage = 1;
    allProductPagesFetched = false;
    popularProductIds = {};
    topRatedProductIds = {};
    latestProductIds = {};
    wooCommerceAPI = WooCommerceAPI(
      url: 'https://www.grodudes.com',
      consumerKey: secret['consumerKey'],
      consumerSecret: secret['consumerSecret'],
    );
  }

  setProductsFromLocalCart(List<Product> localCartProducts) {
    localCartProducts.forEach((item) => this._addProduct(item));
  }

  _addProduct(Product item) {
    if (this.products.containsKey(item.data['id'])) {
      return this.products[item.data['id']];
    }
    this.products[item.data['id']] = item;
    return item;
  }

  Future fetchAllParentCategories() async {
    if (this.categories.values.length > 0) return true;
    List<dynamic> fetchedCategories = [];

    fetchedCategories = await wooCommerceAPI
        .getAsync('products/categories?parent=0&per_page=50&page=1');
    if (fetchedCategories != null && fetchedCategories.length > 0) {
      fetchedCategories
          .where((element) =>
              element['name'].toString().toLowerCase() != 'uncategorized')
          .forEach(
              (category) => categories[category['id']] = Category(category));
      notifyListeners();
      return true;
    }
  }

  Future fetchNextProductsPage() async {
    if (allProductPagesFetched) return;
    List<dynamic> fetchedProducts = [];
    fetchedProducts = await wooCommerceAPI
        .getAsync('products?per_page=$productsPerPage&page=$nextProductPage')
        .timeout(Duration(seconds: 60));
    if (fetchedProducts == null) return;
    if (fetchedProducts.length > 0) nextProductPage++;
    if (fetchedProducts.length < productsPerPage) allProductPagesFetched = true;
    fetchedProducts.forEach((item) => _addProduct(Product(item)));
    notifyListeners();
  }

  Future fetchCategoryDetails(Category category) async {
    //fetch sub categories
    List<dynamic> data = await wooCommerceAPI
        .getAsync('products/categories?parent=${category.data['id']}')
        .catchError((err) => print(err));
    List<Category> categories = [];
    data.forEach((item) => categories.add(Category(item)));
    if (categories.length > 0) return {'categories': categories};

    // fetch products if there are no sub categories
    List<dynamic> productData = await wooCommerceAPI
        .getAsync('products?category=${category.data['id']}')
        .catchError((err) => print(err));
    List<Product> fetchedProducts = [];
    productData.forEach((product) {
      _addProduct(Product(product));
      fetchedProducts.add(this.products[product['id']]);
    });
    return {
      'categories': categories,
      'products': fetchedProducts,
    };
  }

  Future fetchLatestProducts({bool shouldNotify = false}) async {
    if (this.latestProductIds.length > 0) {
      if (shouldNotify) notifyListeners();
      return true;
    }
    List<dynamic> productsData = await this
        .wooCommerceAPI
        .getAsync('products?per_page=20&orderby=date&order=desc',
            apiVersion: 'v3')
        .timeout(Duration(seconds: 60))
        .catchError((err) {
      print('fetching latest products: $err');
      throw err;
    });
    if (productsData == null) throw Exception('Failed to fetch products');
    productsData.forEach((item) {
      item['in_stock'] = item['stock_status'] == 'instock';
      this._addProduct(Product(item));
      this.latestProductIds.add(item['id']);
    });
    if (shouldNotify) notifyListeners();
    return true;
  }

  Future fetchRatedProducts({bool shouldNotify = false}) async {
    if (this.topRatedProductIds.length > 0) {
      if (shouldNotify) notifyListeners();
      return true;
    }
    List<dynamic> productsData = await this
        .wooCommerceAPI
        .getAsync('products?per_page=20&orderby=rating&order=desc',
            apiVersion: 'v3')
        .timeout(Duration(seconds: 60))
        .catchError((err) {
      print('fetching top rated products: $err');
      throw err;
    });
    if (productsData == null) throw FlutterError('Failed to fetch products');
    productsData.forEach((item) {
      item['in_stock'] = item['stock_status'] == 'instock';
      this._addProduct(Product(item));
      this.topRatedProductIds.add(item['id']);
    });
    if (shouldNotify) notifyListeners();
    return true;
  }

  Future fetchPopularProducts({bool shouldNotify = false}) async {
    if (this.popularProductIds.length > 0) {
      if (shouldNotify) notifyListeners();
      return true;
    }
    List<dynamic> productsData = await this
        .wooCommerceAPI
        .getAsync('products?per_page=20&orderby=popularity&order=desc',
            apiVersion: 'v3')
        .timeout(Duration(seconds: 60))
        .catchError((err) {
      print('fetching popular products: $err');
      throw err;
    });
    if (productsData == null) throw FlutterError('Failed to fetch products');
    productsData.forEach((item) {
      item['in_stock'] = item['stock_status'] == 'instock';
      this._addProduct(Product(item));
      this.popularProductIds.add(item['id']);
    });
    if (shouldNotify) notifyListeners();
    return true;
  }

  Future<List<Product>> searchProducts(String searchQuery) async {
    List<dynamic> searchedProductsData =
        await wooCommerceAPI.getAsync('products?search=$searchQuery');

    List<Product> searchedProducts = [];
    searchedProductsData.forEach((productData) {
      Product item = _addProduct(Product(productData));
      searchedProducts.add(item);
    });
    return searchedProducts;
  }

  Future<List<Product>> getProductsInOrder(Map<String, dynamic> order) async {
    List<int> productsIds = [];
    order['line_items'].forEach((item) {
      productsIds.add(item['product_id']);
    });
    String includeString = productsIds.join(',');
    List<dynamic> response =
        await wooCommerceAPI.getAsync('products?include=$includeString');
    List<Product> orderProducts = [];
    response.forEach((item) => orderProducts.add(_addProduct(Product(item))));
    return orderProducts;
  }
}

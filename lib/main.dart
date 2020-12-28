import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/helper/WooCommerceAPI.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/cart_state.dart';
import 'package:grodudes/state/products_state.dart';
import 'package:grodudes/state/user_state.dart';
import 'package:grodudes/Root.dart';
import 'secrets.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: GrodudesPrimaryColor.primaryColor[800],
    ),
  );
  ErrorWidget.builder = (FlutterErrorDetails details) => SizedBox(
        height: 0,
        width: 0,
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final WooCommerceAPI wooCommerceAPI = WooCommerceAPI(
    url: 'https://www.grodudes.com',
    consumerKey: secret['consumerKey'],
    consumerSecret: secret['consumerSecret'],
  );

  Future loadData() async {
    try {
      var response =
          await http.get('https://www.grodudes.com/json/maintenance.json');
      var responseJson = json.decode(response.body);
      var isInMaintenance = responseJson['maintenance'];

      if (isInMaintenance == null ||
          isInMaintenance == true ||
          isInMaintenance == "true") {
        return {"maintenance": true};
      }
    } catch (err) {
      print(err);
      return {"startup_fail": true};
    }
    // check if the user has cart items locally stored
    List<Product> localCartItems = [];
    try {
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      String cartData = prefs.getString(localCartStorageKey);
      if (cartData != null) {
        List<dynamic> items = json.decode(cartData);
        Map<int, int> itemIds = {};
        items.forEach((item) {
          if (item['id'] != null && item['id'] is int) {
            itemIds[item['id']] = item['quantity'] ?? 1;
          }
        });
        if (itemIds.length > 0) {
          List<dynamic> fetchedCartItems =
              await fetchCartItems(itemIds.keys.toList());
          fetchedCartItems.forEach((item) {
            Product product = Product(item);
            product.quantity = itemIds[item['id']] ?? 1;
            localCartItems.add(product);
          });
        }
      }
    } catch (err) {
      print(err);
      localCartItems = [];
    }

    try {
      // check for previous logins
      FlutterSecureStorage _storage = FlutterSecureStorage();
      var isLoggedIn = await _storage.read(key: 'grodudes_login_status');

      // fetch user details if the user was logged in
      if (isLoggedIn != null && isLoggedIn == 'true') {
        String wpUserInfoString = await _storage.read(key: 'grodudes_wp_info');

        Map<String, dynamic> wpUserInfo;
        Map<String, dynamic> wcUserInfo;
        if (wpUserInfoString != null) {
          wpUserInfo = json.decode(wpUserInfoString);
          String token = wpUserInfo['token'];
          if (token != null) {
            wcUserInfo = await fetchUserData(token);
          }
        }

        return {
          'success': true,
          'cartItems': localCartItems,
          'wcUser': wcUserInfo,
          'wpUser': wpUserInfo
        };
      }
    } catch (err) {
      print(err);
    }
    return {'success': true, 'cartItems': localCartItems};
  }

  Future fetchCartItems(List<int> ids) async {
    List<dynamic> fetchedProducts = [];
    try {
      String includeString = ids.join(',');
      fetchedProducts =
          await this.wooCommerceAPI.getAsync('products?include=$includeString');
      return fetchedProducts;
    } catch (err) {
      fetchedProducts = [];
      return fetchedProducts;
    }
  }

  Future fetchUserData(String token) async {
    int id = await this.wooCommerceAPI.getLoggedInUserId(token);
    if (id == null) return;
    var response = await this.wooCommerceAPI.getAsync('customers/$id');
    if (response['id'] == null) return;
    return response;
  }

  showPincodeDialog(BuildContext context) async {
    bool firstTime = false;

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var storedValue = prefs.get('grodudes_first_run');

    if (storedValue == null) firstTime = true;
    if (!firstTime) return;

    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(8),
          title: Text('Check if we can reach you'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'eg. 712201',
                  labelText: 'Pincode',
                  labelStyle:
                      TextStyle(color: GrodudesPrimaryColor.primaryColor[700]),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GrodudesPrimaryColor.primaryColor[600],
                          width: 2)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                onSubmitted: (value) {
                  bool isPresent = pincodes.contains(value);
                  registerFirstUsage(context, isPresent);
                  prefs
                      .setString('grodudes_first_run', 'true')
                      .catchError((err) => print(err));
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: MaterialButton(
                child: Text('Check'),
                onPressed: () {
                  String value = controller.text;
                  bool isPresent = pincodes.contains(value);
                  registerFirstUsage(context, isPresent);
                  prefs
                      .setString('grodudes_first_run', 'true')
                      .catchError((err) => print(err));
                },
              ),
            )
          ],
        );
      },
    );
  }

  registerFirstUsage(context, isPinPresent) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            content: Text(isPinPresent
                ? 'Great! Your pincode is available for delivery'
                : 'Sorry, we cant deliver to your region'),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsManager()),
        ChangeNotifierProvider(create: (_) => CartManager()),
        ChangeNotifierProvider(create: (_) => UserManager()),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          title: 'Grodudes',
          debugShowCheckedModeBanner: false,
          // showPerformanceOverlay: true,
          theme: ThemeData(
            fontFamily: 'Open Sans',
            primarySwatch: GrodudesPrimaryColor.customSwatch,
            primaryColor: Colors.white,
            backgroundColor: Colors.white,
            buttonColor: GrodudesPrimaryColor.primaryColor[700],
            cursorColor: GrodudesPrimaryColor.primaryColor[700],
            scaffoldBackgroundColor: Colors.white,
            // accentColor: GrodudesPrimaryColor.primaryColor[400],
            brightness: Brightness.light,
            textTheme: Typography.blackCupertino,
            iconTheme: IconThemeData(
              color: Color.fromRGBO(40, 40, 40, 1),
              size: 28,
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              brightness: Brightness.dark,
              color: Colors.white,
              textTheme: Theme.of(context).primaryTextTheme.copyWith(
                    headline6: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 20,
                    ),
                  ),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: FutureBuilder(
            future: loadData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Root();
              }
              if (snapshot.hasData) {
                SchedulerBinding.instance
                    .addPostFrameCallback((_) => showPincodeDialog(context));
                if (snapshot.data['maintenance'] == true) {
                  return _AppLoadException(
                      'We are currently in maintenance mode. Sorry for the inconvenience');
                }
                if (snapshot.data['startup_fail'] == true) {
                  return _AppLoadException(
                      'Failed to load data. Please Check your Internet Connection');
                }
                if (snapshot.data['wpUser'] != null &&
                    snapshot.data['wcUser'] != null) {
                  Provider.of<UserManager>(context, listen: false)
                      .initializeUser(
                          snapshot.data['wpUser'], snapshot.data['wcUser']);
                }
                if (snapshot.data['cartItems'] != null &&
                    snapshot.data['cartItems'] is List<Product>) {
                  List<Product> localCartProducts = snapshot.data['cartItems'];
                  Provider.of<ProductsManager>(context, listen: false)
                      .setProductsFromLocalCart(localCartProducts);
                  Provider.of<CartManager>(context, listen: false)
                      .setCartItemsFromLocalData(localCartProducts);
                }
                return Root();
              }
              return _AppLoadingScreen();
            },
          ),
        ),
      ),
    );
  }
}

class _AppLoadException extends StatelessWidget {
  final String title;
  _AppLoadException(this.title);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        color: GrodudesPrimaryColor.primaryColor[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/grodudes_logo_svg.svg',
              height: 150,
              width: 150,
              placeholderBuilder: (context) => Container(),
              alignment: Alignment.center,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GrodudesPrimaryColor.primaryColor[800],
      child: Center(
        child: SvgPicture.asset(
          'assets/images/grodudes_logo_svg.svg',
          height: 150,
          width: 150,
          placeholderBuilder: (context) => Container(),
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

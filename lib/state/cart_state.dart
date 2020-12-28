import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:grodudes/models/Product.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String localCartStorageKey = 'grodudes_cart_data';

class CartManager with ChangeNotifier {
  List<Product> cartItems;
  Future<SharedPreferences> _prefs;
  CartManager() {
    cartItems = [];
    this._prefs = SharedPreferences.getInstance();
  }

  setCartItemsFromLocalData(List<Product> products) {
    if (this.cartItems.length > 0) return;
    products.forEach((item) {
      if (!isPresentInCart(item)) {
        this.cartItems.add(item);
      }
    });
  }

  addCartItem(Product item, {int quantity = 1}) {
    if (isPresentInCart(item) == true) return;
    try {
      bool inStock = item.data['in_stock'];
      bool isPurchasable = item.data['purchasable'];
      if (inStock == null || isPurchasable == null) return;
      if (!inStock || !isPurchasable) return;
      double price = double.parse(item.data['price']);
      if (price <= 0) return;
    } catch (err) {
      print(err);
      return;
    }
    item.quantity = quantity;
    this.cartItems.add(item);
    notifyListeners();
    _storeCartLocally();
  }

  removeCartItem(Product item) {
    this.cartItems.remove(item);
    notifyListeners();
    _storeCartLocally();
  }

  clearCart() {
    cartItems.clear();
    notifyListeners();
    _storeCartLocally();
  }

  isPresentInCart(Product item) {
    for (final cartItem in cartItems) {
      if (cartItem.isSameAs(item)) return true;
    }
    return false;
  }

  incrementQuantityOfProduct(Product item) {
    for (final cartItem in cartItems) {
      if (cartItem.isSameAs(item)) {
        cartItem.quantity++;
        notifyListeners();
        _storeCartLocally();
        return;
      }
    }
  }

  decrementQuantityOfProduct(Product item) {
    for (final cartItem in cartItems) {
      if (cartItem.isSameAs(item)) {
        if (cartItem.quantity == 1) {
          removeCartItem(item);
          return;
        }
        cartItem.quantity--;
        notifyListeners();
        _storeCartLocally();
        return;
      }
    }
  }

  Future _storeCartLocally() async {
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.setString(localCartStorageKey, _getCartDataAsString());
    } catch (err) {
      print(err);
    }
  }

  String _getCartDataAsString() {
    List<dynamic> productsInCart = [];
    this.cartItems.forEach(
          (item) => productsInCart.add({
            'id': item.data['id'],
            'quantity': item.quantity,
          }),
        );
    return json.encode(productsInCart);
  }
}

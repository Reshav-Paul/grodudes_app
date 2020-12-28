import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/components/CartListItem.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/pages/checkout/ConfirmationPage.dart';
import 'package:grodudes/state/cart_state.dart';
import 'package:provider/provider.dart';

class CartItems extends StatefulWidget {
  @override
  _CartItemsState createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _calculateCartTotal(List<Product> items) {
    double total = 0;
    items.forEach(
        (item) => total += double.parse(item.data['price']) * item.quantity);
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Consumer<CartManager>(
        builder: (context, value, child) => ListView.builder(
          itemCount: value.cartItems.length,
          itemBuilder: (context, index) => CartListItem(value.cartItems[index]),
        ),
      ),
      bottomNavigationBar: Consumer<CartManager>(
        builder: (context, cart, child) => Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 2,
                color: Color(0xffcccccc),
              )
            ],
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Total   ₹${_calculateCartTotal(cart.cartItems)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${cart.cartItems.length} ${cart.cartItems.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Expanded(child: Container()),
              RaisedButton(
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ConfirmationPage()),
                ),
                child: Text('Checkout', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

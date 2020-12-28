import 'package:flutter/material.dart';
import 'package:grodudes/helper/WooCommerceAPI.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/cart_state.dart';
import 'package:provider/provider.dart';
import '../../secrets.dart';

class OrderPlacementPage extends StatefulWidget {
  final int customerId;
  final Map<String, dynamic> billingAddress;
  final Map<String, dynamic> shippingAddress;
  final List<Product> items;
  OrderPlacementPage({
    @required this.customerId,
    @required this.billingAddress,
    @required this.shippingAddress,
    @required this.items,
  });

  @override
  _OrderPlacementPageState createState() => _OrderPlacementPageState();
}

class _OrderPlacementPageState extends State<OrderPlacementPage> {
  Map<String, dynamic> orderDetails;

  @override
  initState() {
    this.orderDetails = {};
    super.initState();
  }

  Future _placeOrder() async {
    if (this.orderDetails['id'] != null) return this.orderDetails;

    List<dynamic> lineItems = [];
    for (Product item in this.widget.items) {
      lineItems.add({
        "product_id": item.data['id'],
        "quantity": item.quantity > 0 ? item.quantity : 1,
      });
    }

    Map<String, dynamic> orderBody = {
      "payment_method": "Cod",
      "payment_method_title": "Cash on delivery",
      "customer_id": this.widget.customerId,
      "billing": this.widget.billingAddress,
      "shipping": this.widget.shippingAddress,
      "line_items": lineItems,
    };

    WooCommerceAPI wooCommerceAPI = WooCommerceAPI(
      url: 'https://www.grodudes.com',
      consumerKey: secret['consumerKey'],
      consumerSecret: secret['consumerSecret'],
    );

    this.orderDetails = await wooCommerceAPI.postAsync('orders', orderBody);
    return this.orderDetails;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customerId == null ||
        widget.billingAddress == null ||
        widget.shippingAddress == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Order Placement')),
        body: Center(
          child: Text(
            'Sorry there was an error',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Order Placement')),
      body: FutureBuilder(
        future: _placeOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Failed to place order - Connection problem'),
                  MaterialButton(
                    child: Text('Retry'),
                    onPressed: () => setState(() {}),
                  )
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data['id'] == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Failed to place order. Something went wrong on our side',
                    ),
                    MaterialButton(
                      child: Text('Retry'),
                      onPressed: () => setState(() {}),
                    )
                  ],
                ),
              );
            } else {
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.check_circle, color: Colors.green[600]),
                        Text(
                          'Thank You For Shopping with Us!',
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your Order ID is ${snapshot.data['id']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your Order is due to be paid through Cash on Delivery (CoD)',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: RaisedButton(
                        child: Text(
                          "Finish",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Provider.of<CartManager>(context, listen: false)
                              .clearCart();
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
              );
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

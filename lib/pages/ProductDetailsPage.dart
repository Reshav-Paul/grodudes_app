import 'package:flutter/material.dart';
import 'package:grodudes/components/ProductDescriptionText.dart';
import 'package:grodudes/components/StyledProductPrice.dart';
import 'package:grodudes/helper/ImageFetcher.dart';

import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/cart_state.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product item;
  ProductDetailsPage(this.item);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: this.item == null
          ? Container(
              alignment: Alignment.center,
              child: Text(
                'Data Not Found',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              children: <Widget>[
                SizedBox(height: 8),
                LimitedBox(
                  maxHeight: 250,
                  child:
                      ImageFetcher.getImage(this.item.data['images'][0]['src']),
                ),
                SizedBox(height: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24),
                  child: Text(
                    this.item.data['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                this.item.data['purchasable'] != null &&
                        this.item.data['purchasable']
                    ? this.item.data['in_stock']
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: StyledProductPrice(
                              this.item.data['price'],
                              this.item.data['regular_price'],
                              priceFontSize: 18,
                              regularPriceFontSize: 14,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Out of Stock',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Currently Not Purchasable',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(height: 8),
                this.item.data['purchasable'] != null &&
                        this.item.data['purchasable'] &&
                        this.item.data['in_stock']
                    ? _CartHandler(this.item)
                    : SizedBox(height: 0),
                this.item.data['short_description'].length > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: ProductDescriptionText(
                          'About',
                          this.item.data['short_description'],
                        ),
                      )
                    : SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProductDescriptionText(
                    'Description',
                    this.item.data['description'],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
    );
  }
}

class _CartHandler extends StatefulWidget {
  final Product item;
  _CartHandler(this.item);
  @override
  __CartHandlerState createState() => __CartHandlerState();
}

class __CartHandlerState extends State<_CartHandler> {
  int quantity;

  @override
  initState() {
    quantity = 1;
    super.initState();
  }

  double getTotalPrice() {
    try {
      return this.quantity * double.parse(widget.item.data['price']) ?? 0;
    } catch (err) {
      print('error getting price');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, cart, child) {
        bool isInCart = cart.isPresentInCart(widget.item);
        if (isInCart) this.quantity = widget.item.quantity;
        return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        iconSize: 28,
                        icon: Icon(Icons.remove),
                        onPressed: () => isInCart
                            ? cart.decrementQuantityOfProduct(widget.item)
                            : setState(() => this.quantity =
                                this.quantity > 1 ? --this.quantity : 1),
                      ),
                      Text(
                        '${isInCart ? widget.item.quantity : this.quantity}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        iconSize: 28,
                        onPressed: () => isInCart
                            ? cart.incrementQuantityOfProduct(widget.item)
                            : setState(() => this.quantity++),
                      )
                    ],
                  ),
                ),
                !isInCart
                    ? RaisedButton(
                        onPressed: () {
                          cart.addCartItem(widget.item,
                              quantity: this.quantity);
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Item added to cart')));
                        },
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      )
                    : RaisedButton(
                        color: Colors.red[400],
                        onPressed: () {
                          cart.removeCartItem(widget.item);
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Item removed from cart')));
                        },
                        child: Text(
                          'Remove from Cart',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Total Amount - ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '₹ ${getTotalPrice()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

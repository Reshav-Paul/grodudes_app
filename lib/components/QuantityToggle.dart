import 'package:flutter/material.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/cart_state.dart';
import 'package:provider/provider.dart';

class QuantityToggle extends StatelessWidget {
  final Product item;
  final EdgeInsetsGeometry margin;
  final double iconSize;
  QuantityToggle(this.item,
      {this.margin = const EdgeInsets.symmetric(horizontal: 4),
      this.iconSize = 26});
  @override
  Widget build(BuildContext context) {
    if (this.item == null || this.item.data['id'] == null) {
      return SizedBox(height: 0);
    }
    return Consumer<CartManager>(
      builder: (context, cart, child) {
        if (cart.isPresentInCart(item)) {
          return Container(
            decoration: BoxDecoration(
                color: GrodudesPrimaryColor.primaryColor[700],
                borderRadius: BorderRadius.circular(14)),
            padding: EdgeInsets.all(2),
            margin: this.margin,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.remove_circle,
                      size: this.iconSize, color: Colors.white),
                  onTap: () => cart.decrementQuantityOfProduct(item),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    '${this.item.quantity}',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  child: Icon(Icons.add_circle,
                      size: this.iconSize, color: Colors.white),
                  onTap: () => cart.incrementQuantityOfProduct(item),
                ),
              ],
            ),
          );
        } else {
          return GestureDetector(
            child: Icon(Icons.add_shopping_cart, size: this.iconSize),
            onTap: () => cart.addCartItem(item),
          );
        }
      },
    );
  }
}

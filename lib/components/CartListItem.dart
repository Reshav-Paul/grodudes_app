import 'package:flutter/material.dart';
import 'package:grodudes/components/StyledProductPrice.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/helper/ImageFetcher.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/cart_state.dart';
import 'package:provider/provider.dart';

class CartListItem extends StatelessWidget {
  final Product item;
  CartListItem(this.item);

  String getTotalPrice() {
    return (double.parse(item.data['price']) * item.quantity)
        .toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (this.item == null || this.item.data['id'] == null) {
      return SizedBox(height: 0);
    }
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () =>
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
          leading: ImageFetcher.getImage(this.item.data['images'][0]['src']),
          title: Text(
            item.data['name'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: StyledProductPrice(
              this.item.data['price'],
              this.item.data['regular_price'],
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
                color: GrodudesPrimaryColor.primaryColor[700],
                borderRadius: BorderRadius.circular(14)),
            padding: EdgeInsets.all(2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child:
                      Icon(Icons.remove_circle, size: 26, color: Colors.white),
                  onTap: () {
                    Provider.of<CartManager>(context, listen: false)
                        .decrementQuantityOfProduct(item);
                  },
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    '${this.item.quantity}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  child: Icon(Icons.add_circle, size: 26, color: Colors.white),
                  onTap: () {
                    Provider.of<CartManager>(context, listen: false)
                        .incrementQuantityOfProduct(item);
                  },
                ),
              ],
            ),
          ),
        ),
        Row(
          children: <Widget>[
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '₹ ${getTotalPrice()}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: RaisedButton(
                color: Colors.white,
                elevation: 0,
                child: Text('Remove', style: TextStyle(color: Colors.red[700])),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xffdddddd), width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                onPressed: () =>
                    Provider.of<CartManager>(context, listen: false)
                        .removeCartItem(item),
              ),
            ),
            SizedBox(width: 8),
          ],
        )
      ],
    );
  }
}

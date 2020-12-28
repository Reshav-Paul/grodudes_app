import 'package:flutter/material.dart';

class StyledProductPrice extends StatelessWidget {
  final String price;
  final String regularPrice;
  final double priceFontSize;
  final double regularPriceFontSize;
  StyledProductPrice(this.price, this.regularPrice,
      {this.priceFontSize = 14, this.regularPriceFontSize = 12});

  bool shouldDisplayRegularPrice() {
    if (this.regularPrice == null || this.regularPrice.length == 0)
      return false;

    try {
      int regularPrice = double.parse(this.regularPrice).round();
      int currentPrice = double.parse(this.price).round();
      if (regularPrice == currentPrice) return false;
    } catch (err) {
      print(err);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          '₹ ${this.price}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[500],
            fontSize: this.priceFontSize,
          ),
        ),
        SizedBox(width: 4),
        shouldDisplayRegularPrice() == true
            ? Text(
                '₹ ${this.regularPrice}',
                style: TextStyle(
                  color: Colors.black54,
                  decoration: TextDecoration.lineThrough,
                  fontSize: this.regularPriceFontSize,
                ),
                overflow: TextOverflow.ellipsis,
              )
            : SizedBox(width: 0),
      ],
    );
  }
}

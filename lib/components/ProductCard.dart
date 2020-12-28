import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/components/QuantityToggle.dart';
import 'package:grodudes/components/StyledProductPrice.dart';
import 'package:grodudes/helper/ImageFetcher.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/pages/ProductDetailsPage.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  ProductCard(this.item);

  @override
  Widget build(BuildContext context) {
    if (this.item == null || this.item.data['id'] == null) {
      return SizedBox(height: 0);
    }
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ProductDetailsPage(this.item)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0xffe5e5e5), blurRadius: 3, spreadRadius: 1)
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ImageFetcher.getImage(item.data['images'][0]['src']),
                ),
                Text(
                  item.data['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                item.data['purchasable'] != null && item.data['purchasable']
                    ? item.data['in_stock']
                        ? StyledProductPrice(this.item.data['price'],
                            this.item.data['regular_price'])
                        : Text(
                            'Out of Stock',
                            style: TextStyle(color: Colors.red[600]),
                          )
                    : SizedBox(height: 0),
                SizedBox(height: 4)
              ],
            ),
            item.data['purchasable'] != null &&
                    item.data['purchasable'] &&
                    item.data['in_stock']
                ? Align(
                    alignment: Alignment.topRight,
                    child: QuantityToggle(
                      this.item,
                      margin: EdgeInsets.all(0),
                      iconSize: 24,
                    ),
                  )
                : SizedBox(height: 0)
          ],
        ),
      ),
    );
  }
}

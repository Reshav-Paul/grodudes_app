import 'package:flutter/material.dart';
import 'package:grodudes/components/ProductListTile.dart';
import 'package:grodudes/models/Product.dart';
import 'package:grodudes/state/products_state.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatelessWidget {
  final Map<String, dynamic> order;
  final TextStyle labelTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  OrderDetails(this.order);

  String _getQuantityById(int id) {
    List<dynamic> lineItems = this.order['line_items'];
    if (lineItems == null) return 'Not Found';
    String quantity = 'Not Found';
    lineItems.forEach((item) {
      if (item['product_id'] == id) {
        quantity = item['quantity'].toString();
      }
    });
    return quantity;
  }

  @override
  Widget build(BuildContext context) {
    if (order == null || order['id'] == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: Container(
          alignment: Alignment.center,
          child: Text(
            'Something went Wrong!',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // print(order);
    final String date = order['date_created'].toString().substring(0, 10);
    final Map<String, dynamic> shippingAddress = this.order['shipping'];
    final Map<String, dynamic> billingAddress = this.order['billing'];
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: ListView(
        padding: EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        children: [
          SizedBox(height: 15),
          Text(
            'Order ID ${order['id']}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Order Total', style: labelTextStyle),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  '₹${order['total']}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('Order Status', style: labelTextStyle),
              SizedBox(width: 16),
              Text(
                order['status'].split('-').join(' '),
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${order['line_items'].length} ${order['line_items'].length > 1 ? 'items' : 'item'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            'Placed on ' + date.split('-').reversed.join('-'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            'Payment Method - ' +
                (order['payment_method_title'] ?? 'Not Found'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text('Shipping Address', style: labelTextStyle),
          SizedBox(height: 8),
          Column(
            children: [
              ...(shippingAddress ?? {'error': 'Something went wrong'})
                  .entries
                  .map((e) => _OrderAddressRow(e.key, e.value)),
            ],
          ),
          SizedBox(height: 20),
          Text('Billing Address', style: labelTextStyle),
          SizedBox(height: 8),
          Column(
            children: [
              ...(billingAddress ?? {'error': 'Something went wrong'})
                  .entries
                  .map((e) => _OrderAddressRow(e.key, e.value)),
            ],
          ),
          SizedBox(height: 20),
          Text('Ordered Products', style: labelTextStyle),
          SizedBox(height: 8),
          FutureBuilder(
            future:
                Provider.of<ProductsManager>(context).getProductsInOrder(order),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    SizedBox(height: 20),
                    Icon(Icons.error, color: Colors.red[600], size: 36),
                    Text(
                      'Failed to fetch products',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                  ],
                );
              }
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => _OrderedProductListTile(
                      snapshot.data[index],
                      _getQuantityById(snapshot.data[index].data['id'])),
                );
              }
              return Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              );
            },
          )
        ],
      ),
    );
  }
}

class _OrderedProductListTile extends StatelessWidget {
  final Product item;
  final String orderQuantity;
  _OrderedProductListTile(this.item, this.orderQuantity);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ProductListTile(item),
        Text(
          "Order Quantity - " + orderQuantity ?? 'Not Found',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

class _OrderAddressRow extends StatelessWidget {
  final String addressKey;
  final String addressValue;
  _OrderAddressRow(this.addressKey, this.addressValue);

  _capitalize(String str) {
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }

  String _formatName(String name) {
    return name.split('_').map((e) => _capitalize(e)).join(' ');
  }

  final TextStyle labelTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(_formatName(this.addressKey), style: labelTextStyle),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: Text(this.addressValue, style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

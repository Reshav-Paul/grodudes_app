import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/pages/account/OrderDetails.dart';
import 'package:grodudes/state/user_state.dart';
import 'package:provider/provider.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  int _page;
  bool _isLoadingData;
  Map<int, dynamic> _orders;
  bool _allFetched;
  bool _dataInitialized;
  bool _errorAfterFetch;

  @override
  initState() {
    this._page = 1;
    this._isLoadingData = false;
    this._orders = {};
    this._allFetched = false;
    this._dataInitialized = false;
    this._errorAfterFetch = false;
    super.initState();
  }

  reload() {
    setState(() {
      this._page = 1;
      this._isLoadingData = false;
      this._orders = {};
      this._allFetched = false;
      this._dataInitialized = false;
      this._errorAfterFetch = false;
      this._orders.clear();
    });
  }

  showOrderCancelStatusDialog(bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(success
            ? 'Successfully requested order cancellation'
            : 'Failed to Cancel Order'),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok',
                style:
                    TextStyle(color: GrodudesPrimaryColor.primaryColor[600])),
          ),
        ],
      ),
    );
  }

  Future _cancelOrder(Map<String, dynamic> order) async {
    try {
      var response = await Provider.of<UserManager>(context, listen: false)
          .cancelOrder(order['id']);
      Navigator.pop(context);
      if (response is Map && response['id'] == order['id']) {
        showOrderCancelStatusDialog(true);
        reload();
      } else {
        throw Exception('cancellation failed');
      }
    } catch (err) {
      print(err);
      Navigator.pop(context);
      showOrderCancelStatusDialog(false);
      return;
    }
  }

  Future _cancelOrderConfirmation(Map<String, dynamic> order) async {
    bool isSure = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Are you Sure?'),
        actions: [
          FlatButton(
            onPressed: () async {
              isSure = true;
              _cancelOrder(order);
            },
            child: Text('Yes',
                style:
                    TextStyle(color: GrodudesPrimaryColor.primaryColor[600])),
          ),
          RaisedButton(
            onPressed: () {
              isSure = false;
              Navigator.pop(context);
            },
            child: Text('No', style: TextStyle(color: Colors.white)),
            elevation: 0,
          ),
        ],
      ),
    ).catchError((err) {
      isSure = false;
    });
    if (!isSure) {
      print('User is not sure');
      return;
    }
  }

  Future getMoreOrders() async {
    if (this._isLoadingData || this._allFetched) return;
    setState(() {
      this._isLoadingData = true;
    });
    try {
      var fetchedOrders = await Provider.of<UserManager>(context, listen: false)
          .getOrders(this._page);
      if (fetchedOrders != null) {
        this._dataInitialized = true;
        if (!(fetchedOrders is List) && fetchedOrders == false) {
          setState(() {
            this._isLoadingData = false;
            this._errorAfterFetch = true;
          });
          return;
        }
        if (fetchedOrders.length == 0) {
          setState(() {
            this._errorAfterFetch = false;
            this._isLoadingData = false;
            this._allFetched = true;
          });
        } else {
          setState(() {
            fetchedOrders.forEach((order) => this._orders[order['id']] = order);
            this._errorAfterFetch = false;
            this._isLoadingData = false;
            this._page++;
          });
        }
      } else {
        throw Exception('recieved null response');
      }
    } catch (err) {
      print(err);
      setState(() {
        this._errorAfterFetch = true;
        this._isLoadingData = false;
      });
    }
  }

  bool _scrollNotificationHandler(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final before = notification.metrics.extentBefore;
      final max = notification.metrics.maxScrollExtent;

      if (before == max) {
        getMoreOrders();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!this._dataInitialized &&
        !this._isLoadingData &&
        !this._errorAfterFetch) {
      getMoreOrders();
    }
    return Scaffold(
      appBar: AppBar(title: Text('Your orders')),
      body: this._dataInitialized
          ? this._orders.length == 0 && this._allFetched
              ? Center(
                  child: Text(
                    'You have no Orders',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : NotificationListener(
                  onNotification: _scrollNotificationHandler,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.vertical,
                    itemCount: this._orders.length + 1,
                    itemBuilder: (context, index) {
                      if (index == this._orders.length) {
                        if (this._errorAfterFetch) {
                          if (this._isLoadingData) {
                            return Container(
                              margin: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Container(
                            margin: this._orders.length == 0
                                ? EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.3)
                                : EdgeInsets.all(8),
                            child: _FetchErrorWidget(),
                          );
                        }

                        if (this._allFetched || !this._isLoadingData)
                          return SizedBox(height: 0);
                        return Center(child: CircularProgressIndicator());
                      }
                      return _OrderCard(
                        order: this._orders.values.elementAt(index),
                        cancelOrderCb: _cancelOrderConfirmation,
                      );
                    },
                  ),
                )
          : this._errorAfterFetch
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  child: _FetchErrorWidget(),
                )
              : Center(child: CircularProgressIndicator()),
    );
  }
}

class _FetchErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red[600], size: 36),
        Text(
          'There was an error in fetching the orders',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard(
      {Key key, @required this.order, @required this.cancelOrderCb})
      : super(key: key);

  final Map<String, dynamic> order;
  final Future Function(Map<String, dynamic>) cancelOrderCb;

  @override
  Widget build(BuildContext context) {
    final String date = order['date_created'].toString().substring(0, 10);
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Order ID ${order['id']}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Placed on ' + date.split('-').reversed.join('-'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${order['line_items'].length} ${order['line_items'].length > 1 ? 'items' : 'item'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 1,
                          spreadRadius: 1,
                        )
                      ],
                      border: Border.all(color: Colors.grey[300]),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Text(
                      order['status'].split('-').join(' '),
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${order['total']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: order['status'].toString().contains('cancel')
                    ? SizedBox(width: 0)
                    : RaisedButton(
                        onPressed: () {
                          if (order['status'] == 'dispatched') {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Dispatched Orders cannot be cancelled')));
                            return;
                          }
                          cancelOrderCb(order).catchError((err) => print(err));
                        },
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(color: Colors.grey[300]),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: GrodudesPrimaryColor.primaryColor[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: RaisedButton(
                  onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => OrderDetails(order),
                    ),
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    // side: BorderSide(color: Colors.grey[300]),
                  ),
                  child: Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

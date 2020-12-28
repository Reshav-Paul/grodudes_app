import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/pages/checkout/AddressUpdatePage.dart';
import 'package:grodudes/pages/checkout/OrderPlacementPage.dart';
import 'package:grodudes/state/cart_state.dart';
import 'package:grodudes/state/user_state.dart';
import 'package:provider/provider.dart';

class ConfirmationPage extends StatefulWidget {
  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  Map<String, dynamic> shippingAddress;
  Map<String, dynamic> billingAddress;
  UserManager userManager;
  TextEditingController _emailController;
  TextEditingController _phoneController;

  //styles
  final _textFieldDecoration = InputDecoration(
    labelStyle: TextStyle(color: GrodudesPrimaryColor.primaryColor[600]),
    alignLabelWithHint: true,
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: GrodudesPrimaryColor.primaryColor[600], width: 2)),
    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  );
  final _headerTextStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

  @override
  void initState() {
    this.userManager = Provider.of<UserManager>(context, listen: false);
    if (userManager.isLoggedIn() && this.userManager.wcUserInfo['id'] != null) {
      this.shippingAddress = new Map.from(userManager.wcUserInfo['shipping']);
      this.billingAddress = new Map.from(userManager.wcUserInfo['billing']);

      String wordpressEmail = userManager.wpUserInfo['user_email'] ?? '';
      String email = wordpressEmail;
      String woocommerceEmail = billingAddress['email'];
      String phone = billingAddress['phone'] ?? '';

      if (woocommerceEmail != null && woocommerceEmail.length > 0) {
        email = woocommerceEmail;
      }

      this._emailController = TextEditingController(text: email);
      this._phoneController = TextEditingController(text: phone);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (this._emailController != null) this._emailController.dispose();
    if (this._phoneController != null) this._phoneController.dispose();
    super.dispose();
  }

  _capitalize(String str) {
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    if (this.userManager.isLoggedIn() == false ||
        this.userManager.wcUserInfo['id'] == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Confirm your details'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Please login to proceed to checkout'),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Confirm your details'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          SizedBox(height: 6),
          TextField(
            controller: this._emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: this._textFieldDecoration.copyWith(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                ),
          ),
          SizedBox(height: 16),
          SizedBox(height: 6),
          TextField(
            controller: this._phoneController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            decoration: this._textFieldDecoration.copyWith(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon:
                      Icon(Icons.phone_android, color: Colors.green[700]),
                ),
          ),
          SizedBox(height: 16),
          Row(
            children: <Widget>[
              Text('Shipping Address', style: this._headerTextStyle),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green),
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => AddressUpdatePage(
                      this.shippingAddress,
                      (newAddress) {
                        setState(() => this.shippingAddress = newAddress);
                        // print(this.shippingAddress);
                      },
                      shouldDisplayPostcodeDropdown: true,
                    ),
                  ),
                ),
              )
            ],
          ),
          // SizedBox(height: 8),
          ...this.shippingAddress.entries.map(
                (e) => Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        e.key.split('_').map((e) => _capitalize(e)).join(' '),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 7,
                      child: Text(
                        e.value,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
          SizedBox(height: 16),
          Row(
            children: <Widget>[
              Text('Billing Address', style: this._headerTextStyle),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green),
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => AddressUpdatePage(
                      this.billingAddress,
                      (newAddress) {
                        setState(() => this.billingAddress = newAddress);
                        // print(this.billingAddress);
                      },
                      shouldDisplayPostcodeDropdown: false,
                    ),
                  ),
                ),
              )
            ],
          ),
          // SizedBox(height: 8),
          ...this.billingAddress.entries.map(
                (e) => Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        e.key.split('_').map((e) => _capitalize(e)).join(' '),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 7,
                      child: Text(
                        e.value,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
          Builder(builder: (context) {
            return Center(
              child: RaisedButton(
                child:
                    Text('Place Order', style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                onPressed: () {
                  if (this._emailController.text.length == 0 ||
                      this._phoneController.text.length == 0) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Please fill out your Email and Phone number')));
                    return;
                  }
                  if (this._emailController.text.contains('@') &&
                      billingAddress['email'] != this._emailController.text) {
                    billingAddress['email'] = this._emailController.text;
                  }
                  if (this._phoneController.text.indexOf(RegExp(r'[,. ]')) ==
                          -1 &&
                      billingAddress['phone'] != this._phoneController.text) {
                    billingAddress['phone'] = this._phoneController.text;
                  }
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => OrderPlacementPage(
                        customerId: userManager.wcUserInfo['id'],
                        billingAddress: this.billingAddress,
                        shippingAddress: this.shippingAddress,
                        items: Provider.of<CartManager>(context).cartItems,
                      ),
                    ),
                  );
                },
              ),
            );
          })
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:grodudes/components/CategoryCard.dart';
import 'package:grodudes/models/Category.dart';
import 'package:grodudes/pages/CartItems.dart';
import 'package:grodudes/pages/account/AccountRoot.dart';
import 'package:grodudes/pages/account/Orders.dart';
import 'package:grodudes/state/products_state.dart';
import 'package:grodudes/state/user_state.dart';

class RootDrawer extends StatelessWidget {
  final TextStyle _whiteText = TextStyle(color: Colors.white, fontSize: 15);

  String _formatName(String name) {
    return name.replaceAll('&amp;', '&');
  }

  Future _openSnapPage() async {
    String url = "https://www.grodudes.com/take-a-snap";
    try {
      if (await canLaunch(url)) {
        await launch(url, enableJavaScript: true);
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (context, userManager, child) {
        bool isLoggedIn = userManager.isLoggedIn();
        List<Category> categories =
            Provider.of<ProductsManager>(context, listen: false)
                .categories
                .values
                .toList();
        return Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Color(0xFF3a3a3a)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => AccountRoot()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      isLoggedIn
                          ? Image.network(
                              userManager.wcUserInfo['avatar_url'] ?? '',
                              height: 52,
                              width: 52,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person,
                                size: 52,
                                color: Colors.grey,
                              ),
                            )
                          : Icon(Icons.person, size: 52, color: Colors.white70),
                      SizedBox(width: 12),
                      isLoggedIn
                          ? Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      userManager.wcUserInfo['username'] ??
                                          'Username not found',
                                      style: _whiteText),
                                  Text(
                                      userManager.wcUserInfo['email'] ??
                                          'Email not found',
                                      style: _whiteText)
                                ],
                              ),
                            )
                          : Text('Guest', style: _whiteText)
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text('Your Orders'),
                leading: Icon(Icons.card_giftcard, color: Colors.orange[700]),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.green,
                ),
                onTap: () {
                  if (!isLoggedIn) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Login to track your Orders'),
                      ),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Orders(),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Cart'),
                leading: Icon(Icons.shopping_cart, color: Colors.blue[700]),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.green,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => CartItems()),
                  );
                },
              ),
              categories != null && categories is List
                  ? Theme(
                      data: Theme.of(context)
                          .copyWith(unselectedWidgetColor: Colors.green),
                      child: ExpansionTile(
                        title: Text('Categories'),
                        leading: Icon(Icons.category, color: Colors.amber[700]),
                        children: <Widget>[
                          ...categories
                              .map(
                                (e) => ListTile(
                                  title: Text(_formatName(e.data['name'])),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            CategoryContents(category: e),
                                      ),
                                    );
                                  },
                                ),
                              )
                              .toList()
                        ],
                      ),
                    )
                  : SizedBox(height: 0),
              ListTile(
                title: Text('Account'),
                leading: Icon(Icons.person, color: Colors.green[700]),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.green,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => AccountRoot()),
                  );
                },
              ),
              ListTile(
                title: Text('Order through Snap'),
                leading: Icon(Icons.camera_alt, color: Colors.brown),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.green,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openSnapPage();
                },
              ),
              isLoggedIn
                  ? ListTile(
                      title: Text('Logout'),
                      leading:
                          Icon(Icons.power_settings_new, color: Colors.red),
                      onTap: () {
                        Navigator.pop(context);
                        userManager.logOut();
                      },
                    )
                  : SizedBox(height: 0),
            ],
          ),
        );
      },
    );
  }
}

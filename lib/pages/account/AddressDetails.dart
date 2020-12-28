import 'package:flutter/material.dart';
import 'package:grodudes/helper/Constants.dart';
import 'package:grodudes/state/user_state.dart';
import 'package:provider/provider.dart';

class AddressDetails extends StatefulWidget {
  final String title;
  final String type;
  final Future<String> Function(Map<String, dynamic>) updateCb;
  AddressDetails({
    @required this.title,
    @required this.type,
    @required this.updateCb,
  });
  @override
  _AddressDetailsState createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {
  Map<String, TextEditingController> _textControllers;
  bool _isLoading;

  @override
  void initState() {
    this._textControllers = {};
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    this._textControllers.values.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  capitalize(String str) {
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }

  Map<String, dynamic> formatData() {
    Map<String, dynamic> data = {};
    this._textControllers.keys.forEach((key) {
      data[key] = this._textControllers[key].text;
    });
    return data;
  }

  String _formatName(String name) {
    return name.split('_').map((e) => capitalize(e)).join(' ');
  }

  List<DropdownMenuItem<String>> _getMenuItems(String value) {
    List<DropdownMenuItem<String>> menuItems = pincodes
        .map(
          (e) => DropdownMenuItem<String>(
            child: Text(e),
            value: e,
          ),
        )
        .toList();

    if (pincodes.contains(value)) return menuItems;
    menuItems.add(DropdownMenuItem<String>(
      child: Text('Not Specified'),
      value: value,
    ));
    return menuItems;
  }

  final headerTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (context, user, child) {
        Map<String, dynamic> address = user.wcUserInfo[widget.type];
        // print(address);
        if (address == null || address.length == 0) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: Center(child: Text('Address not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(this.widget.title),
            centerTitle: true,
          ),
          body: Stack(
            children: <Widget>[
              ListView.builder(
                itemCount: address.keys.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final key = address.keys.elementAt(index);
                  final text = address[key];

                  TextEditingController _controller;
                  _controller = TextEditingController(text: text);
                  this._textControllers[key] = _controller;

                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 6),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _formatName(address.keys.elementAt(index)),
                            style: headerTextStyle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 7,
                          child: address.keys.elementAt(index) == 'postcode' &&
                                  widget.type == 'shipping'
                              ? DropdownButtonFormField<String>(
                                  value: _controller.text,
                                  items: <DropdownMenuItem<String>>[
                                    ..._getMenuItems(_controller.text)
                                  ],
                                  onChanged: (value) =>
                                      _controller.text = value,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: GrodudesPrimaryColor
                                                .primaryColor[600],
                                            width: 2)),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                  ),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                )
                              : TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: GrodudesPrimaryColor
                                                .primaryColor[600],
                                            width: 2)),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                  ),
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                        SizedBox(width: 6),
                      ],
                    ),
                  );
                },
              ),
              _isLoading
                  ? Container(
                      color: Colors.white,
                      child: Center(child: CircularProgressIndicator()))
                  : SizedBox(height: 0, width: 0)
            ],
          ),
          bottomNavigationBar: Builder(builder: (context) {
            return Container(
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(
                          color: GrodudesPrimaryColor.primaryColor[700],
                          width: 2,
                        ),
                      ),
                      color: Colors.white,
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      child: Text(
                        'Update',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () async {
                        this.setState(() {
                          _isLoading = true;
                        });
                        String msg;
                        msg = await this
                            .widget
                            .updateCb(formatData())
                            .catchError((err) {
                          print(err);
                          msg = null;
                        });
                        this.setState(() {
                          _isLoading = false;
                        });
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text(msg ?? 'An error occured')));
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

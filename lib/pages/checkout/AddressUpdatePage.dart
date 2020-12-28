import 'package:flutter/material.dart';
import 'package:grodudes/helper/Constants.dart';

class AddressUpdatePage extends StatelessWidget {
  final Map<String, dynamic> address;
  final Function updateCb;
  final bool shouldDisplayPostcodeDropdown;
  AddressUpdatePage(this.address, this.updateCb,
      {@required this.shouldDisplayPostcodeDropdown});

  final List<TextEditingController> _textEditingControllers = [];

  _capitalize(String str) {
    return '${str[0].toUpperCase()}${str.substring(1)}';
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

  @override
  Widget build(BuildContext context) {
    if (address == null || address.length == 0) {
      return Scaffold(
        appBar: AppBar(title: Text('Update your address details')),
        body: Center(child: Text('Address not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Update your address details')),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: address.length,
        itemBuilder: (context, index) {
          String key = address.keys.elementAt(index);
          String keyText = key.split('_').map((e) => _capitalize(e)).join(' ');
          TextEditingController _controller =
              TextEditingController(text: address[key] ?? '');
          this._textEditingControllers.add(_controller);
          if (shouldDisplayPostcodeDropdown && key == 'postcode') {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      keyText,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ButtonTheme(
                  alignedDropdown: true,
                  child: Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: this.address[key],
                      dropdownColor: Color.fromRGBO(230, 230, 230, 1),
                      items: <DropdownMenuItem<String>>[
                        ..._getMenuItems(this.address[key])
                      ],
                      onChanged: (value) => this.address[key] = value,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: GrodudesPrimaryColor.primaryColor[600],
                              width: 2),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                )
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                keyText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GrodudesPrimaryColor.primaryColor[500],
                          width: 2)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                onChanged: (value) => this.address[key] = value,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  this.updateCb(this.address);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

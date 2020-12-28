import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';

class ProductDescriptionText extends StatelessWidget {
  final String title;
  final String htmlText;
  ProductDescriptionText(this.title, this.htmlText);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Html(
          data: htmlText ?? '',
          style: {
            'p': Style(fontSize: FontSize(16), margin: EdgeInsets.all(0))
          },
        ),
      ],
    );
  }
}

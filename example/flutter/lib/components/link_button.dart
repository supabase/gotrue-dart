import 'package:flutter/material.dart';

class LinkButton extends StatelessWidget {
  final String text;
  final Function press;
  final textColor;
  const LinkButton({
    Key key,
    this.text,
    this.press,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: press,
          child: Text(text),
        )
      ],
    );
  }
}

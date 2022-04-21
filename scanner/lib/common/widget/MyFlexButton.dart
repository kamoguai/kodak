import 'package:flutter/material.dart';

///
///滿版的button
///Date: 2022-01-08
///
class MyFlexButton extends StatelessWidget {
  final String text;

  final Color color;

  final Color textColor;

  final VoidCallback onPress;

  final double fontSize;
  final int maxLines;

  final MainAxisAlignment mainAxisAlignment;

  const MyFlexButton(
      {Key? key,
      required this.text,
      required this.color,
      required this.textColor,
      required this.onPress,
      this.fontSize = 20.0,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.maxLines = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Flex(
          mainAxisAlignment: mainAxisAlignment,
          direction: Axis.horizontal,
          children: <Widget>[
            Text(text,
                style: TextStyle(fontSize: fontSize, color: textColor),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis)
          ],
        ),
        style: ElevatedButton.styleFrom(primary: color),
        onPressed: () {
          onPress.call();
        });
  }
}

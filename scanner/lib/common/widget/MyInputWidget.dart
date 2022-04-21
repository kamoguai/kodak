import 'package:flutter/material.dart';

///
///自定義inputField
///
class MyInputWidget extends StatefulWidget {
  final bool obscureText;

  final String hintText;
  final String textTitle;

  final ValueChanged<String> onChanged;

  final TextStyle textStyle;

  final TextEditingController controller;

  const MyInputWidget(
      {Key? key,
      required this.hintText,
      required this.textTitle,
      required this.onChanged,
      required this.textStyle,
      required this.controller,
      this.obscureText = false})
      : super(key: key);

  @override
  _MyInputWidgetState createState() => _MyInputWidgetState();
}

class _MyInputWidgetState extends State<MyInputWidget> {
  _MyInputWidgetState() : super();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      style: widget.textStyle,
      decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.textTitle,
          filled: true,
          fillColor: Colors.white),
    );
  }
}

class ConnetInputWidget extends StatefulWidget {
  final bool obscureText;

  final String hintText;
  final String textTitle;

  final ValueChanged<String> onChanged;

  final TextStyle textStyle;

  final TextEditingController controller;

  final TextAlign textAlign;

  final String lableText;

  const ConnetInputWidget({
    Key? key,
    required this.hintText,
    required this.textTitle,
    required this.onChanged,
    required this.textStyle,
    required this.controller,
    this.obscureText = false,
    this.lableText = "",
    required this.textAlign,
  }) : super(key: key);

  @override
  State<ConnetInputWidget> createState() => _ConnetInputWidgetState();
}

class _ConnetInputWidgetState extends State<ConnetInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      style: widget.textStyle,
      textAlign: widget.textAlign,
      decoration: InputDecoration(
        hintText: widget.hintText,
        fillColor: Colors.white,
        filled: true,
        labelText: widget.lableText,
        // labelStyle: const TextStyle(color: Colors.white),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
      ),
    );
  }
}

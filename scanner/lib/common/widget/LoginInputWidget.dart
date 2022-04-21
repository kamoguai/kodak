import 'package:flutter/material.dart';

class LoginInputWidget extends StatefulWidget {
  final bool obscureText;

  final String hintText;
  final String textTitle;

  final ValueChanged<String> onChanged;

  final TextStyle textStyle;

  final TextEditingController controller;
  final FocusNode node;
  const LoginInputWidget(
      {Key? key,
      required this.obscureText,
      required this.hintText,
      required this.textTitle,
      required this.onChanged,
      required this.textStyle,
      required this.controller,
      required this.node})
      : super(key: key);

  @override
  _LoginInputWidgetState createState() => _LoginInputWidgetState();
}

class _LoginInputWidgetState extends State<LoginInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.node,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      style: widget.textStyle,
      decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.textTitle,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: const Color(0x21FFFFFF),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }
}

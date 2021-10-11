import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({required this.buttonColor, required this.buttonText, required this.buttonPressed, required this.minWidth});
  final Color buttonColor;
  final String buttonText;
  final double minWidth;
  final Function() buttonPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 10),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: buttonPressed,
          minWidth: minWidth,
          height: 10,
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
            ),
          ),
        ),
      ),
    );
  }
}

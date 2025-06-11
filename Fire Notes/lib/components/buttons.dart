import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final String title;
  final Color filledColor;
  final void Function()? onPressed;
  const Buttons({super.key, required this.title, required this.filledColor, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return MaterialButton(
      height: screenSize.height * 0.05,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: filledColor,
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text('$title ', style: TextStyle(fontSize: 18)),
    );
  }
}

import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Center(
      child: Container(
        padding: EdgeInsets.only(left: 9, right: 3, top: 3, bottom: 3),
        width: screenSize.width * 0.2,
        height: screenSize.width * 0.2,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Image.asset(
          'assets/images/icon_optimized.png',
          width: screenSize.width * 0.15,
          height: screenSize.height * 0.25,
        ),
      ),
    );
  }
}

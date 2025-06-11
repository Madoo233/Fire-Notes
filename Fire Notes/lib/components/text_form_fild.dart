import 'package:flutter/material.dart';

class CoustomTextFormFild extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String titleHintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool obscureText;

  const CoustomTextFormFild({
    super.key,
    required this.hintText,
    required this.controller,
    required this.titleHintText,
    this.keyboardType,
    required this.validator,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleHintText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          validator: validator,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: maxLines! > 1 ? 16 : 12,
              horizontal: 16,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines! > 1 ? 16 : 30),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines! > 1 ? 16 : 30),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines! > 1 ? 16 : 30),
              borderSide: BorderSide(
                color: Colors.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines! > 1 ? 16 : 30),
              borderSide: BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines! > 1 ? 16 : 30),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

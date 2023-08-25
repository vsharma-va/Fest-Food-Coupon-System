import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? textInputType;

  const CommonTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: textInputType ?? TextInputType.number,
      // textCapitalization: TextCapitalization.characters,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(1, 147, 252, 1),
            width: 3,
          ),
        ),
        border: const OutlineInputBorder(),
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Color.fromRGBO(1, 147, 252, 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(1, 147, 252, 1),
            width: 3,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
    var upTime = const Duration(milliseconds: 4000),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: upTime,
    ));
  }

  void showCommonSnackBar(
      {required String message,
      upTime = const Duration(milliseconds: 4000),
      backgroundColor = const Color.fromRGBO(255, 96, 79, 1)}) {
    showSnackBar(
        message: message, backgroundColor: backgroundColor, upTime: upTime);
  }
}

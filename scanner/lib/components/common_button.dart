import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius = BorderRadius.circular(10);
  final double? width = double.infinity;
  final double height = 62;
  final Gradient gradient = LinearGradient(
    colors: [
      Colors.blue.shade400,
      Colors.blue.shade900,
    ],
  );
  final VoidCallback? onPressed;
  final Widget child;

  CommonButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(0);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade900,
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          // backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}

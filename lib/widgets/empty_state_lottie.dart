import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateLottie extends StatelessWidget {
  const EmptyStateLottie({
    super.key,
    this.size = 160,
    this.asset = 'assets/lottie/empty_cart.json',
  });

  final double size;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        asset,
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}

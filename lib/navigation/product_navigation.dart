import 'package:flutter/material.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/screens/product_detail_screen.dart';

void openProductDetail(BuildContext context, Product product) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProductDetailScreen(product: product),
    ),
  );
}

class ProductReview {
  const ProductReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.dateLabel,
  });

  final String author;
  final int rating;
  final String comment;
  final String dateLabel;
}

/// No seeded product reviews — ratings come from Nest order feedback.
final mockReviewsByProduct = <String, List<ProductReview>>{};

List<ProductReview> reviewsForProduct(String productId) => const [];

class CourierEarningsWeek {
  const CourierEarningsWeek({
    required this.label,
    required this.amountGnf,
    this.highlighted = false,
  });

  final String label;
  final int amountGnf;
  final bool highlighted;
}

import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';

/// Centers content and caps width on tablet for form-style screens.
class TabletConstrainedContent extends StatelessWidget {
  const TabletConstrainedContent({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppBreakpoints.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}

/// Scrollable auth body: full-width on phone; max-width + vertically
/// centered on tablet (ConsentMD / EliteHome style).
class TabletAuthScrollBody extends StatelessWidget {
  const TabletAuthScrollBody({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  /// When null, uses generous top inset on phone so content clears the top.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final resolvedPadding = padding ??
        EdgeInsets.fromLTRB(
          24,
          isTablet ? 24 : 56,
          24,
          24,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight =
            (constraints.maxHeight - resolvedPadding.vertical)
                .clamp(0.0, double.infinity);

        return SingleChildScrollView(
          padding: resolvedPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Align(
              alignment:
                  isTablet ? Alignment.center : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth(context),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double topPadding;
  final double bottomPadding;

  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.topPadding = 16,
    this.bottomPadding = 110,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double sidePadding = 16;
    if (screenWidth > 600) {
      sidePadding = 32;
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          sidePadding,
          topPadding,
          sidePadding,
          bottomPadding,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}
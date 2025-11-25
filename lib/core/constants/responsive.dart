import 'package:flutter/widgets.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1000;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;
}

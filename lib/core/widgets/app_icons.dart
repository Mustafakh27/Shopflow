import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  static IconData getIcon(String? name, [int? codePoint]) {
    switch (name) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'watch':
        return Icons.watch;
      case 'shopping_bag':
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'directions_run':
        return Icons.directions_run;
      case 'wb_sunny_outlined':
        return Icons.wb_sunny_outlined;
      case 'work_outline':
        return Icons.work_outline;
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        if (codePoint != null) {
          if (codePoint == Icons.directions_walk.codePoint) return Icons.directions_walk;
          if (codePoint == Icons.watch.codePoint) return Icons.watch;
          if (codePoint == Icons.shopping_bag_outlined.codePoint || codePoint == Icons.shopping_bag.codePoint) {
            return Icons.shopping_bag_outlined;
          }
          if (codePoint == Icons.directions_run.codePoint) return Icons.directions_run;
          if (codePoint == Icons.wb_sunny_outlined.codePoint) return Icons.wb_sunny_outlined;
          if (codePoint == Icons.work_outline.codePoint) return Icons.work_outline;
          if (codePoint == Icons.male.codePoint) return Icons.male;
          if (codePoint == Icons.female.codePoint) return Icons.female;
        }
        return Icons.checkroom;
    }
  }

  static String getIconName(IconData icon) {
    if (icon == Icons.directions_walk) return 'directions_walk';
    if (icon == Icons.watch) return 'watch';
    if (icon == Icons.shopping_bag_outlined || icon == Icons.shopping_bag) return 'shopping_bag_outlined';
    if (icon == Icons.directions_run) return 'directions_run';
    if (icon == Icons.wb_sunny_outlined) return 'wb_sunny_outlined';
    if (icon == Icons.work_outline) return 'work_outline';
    if (icon == Icons.male) return 'male';
    if (icon == Icons.female) return 'female';
    return 'checkroom';
  }
}

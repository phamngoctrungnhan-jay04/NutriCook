import 'package:flutter/material.dart';

/// Token bo góc theo UI_UX_GUIDELINES.md mục Border Radius.
class AppRadius {
  const AppRadius._();

  static const double button = 12;
  static const double card = 16;
  static const double textField = 12;
  static const double dialog = 20;

  /// Bo tròn hoàn toàn (pill shape) cho Chip.
  static const double chip = 999;

  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius textFieldRadius = BorderRadius.all(Radius.circular(textField));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(dialog));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(chip));
}
